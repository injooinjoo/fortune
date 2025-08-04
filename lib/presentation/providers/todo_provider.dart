import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/error/failures.dart';
import 'package:fortune/data/datasources/remote/supabase_client.dart';
import 'package:fortune/data/repositories/todo_repository_impl.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';
import 'package:fortune/domain/usecases/todo/create_todo_usecase.dart';
import 'package:fortune/domain/usecases/todo/delete_todo_usecase.dart';
import 'package:fortune/domain/usecases/todo/get_todos_usecase.dart';
import 'package:fortune/domain/usecases/todo/toggle_todo_status_usecase.dart';
import 'package:fortune/domain/usecases/todo/update_todo_usecase.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';

// Repository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TodoRepositoryImpl(supabase: supabase);
});

// Use Case Providers
final createTodoUseCaseProvider = Provider<CreateTodoUseCase>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return CreateTodoUseCase(repository);
});

final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return GetTodosUseCase(repository);
});

final updateTodoUseCaseProvider = Provider<UpdateTodoUseCase>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return UpdateTodoUseCase(repository);
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return DeleteTodoUseCase(repository);
});

final toggleTodoStatusUseCaseProvider = Provider<ToggleTodoStatusUseCase>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return ToggleTodoStatusUseCase(repository);
});

// State for filter and search
class TodoFilter {
  final TodoStatus? status;
  final TodoPriority? priority;
  final String? searchQuery;
  final List<String>? tags;

  const TodoFilter({
    this.status,
    this.priority,
    this.searchQuery,
    this.tags,
  });

  TodoFilter copyWith({
    TodoStatus? Function()? status,
    TodoPriority? Function()? priority,
    String? Function()? searchQuery,
    List<String>? Function()? tags,
  }) {
    return TodoFilter(
      status: status != null ? status() : this.status,
      priority: priority != null ? priority() : this.priority,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      tags: tags != null ? tags() : this.tags,
    );
  }
}

// Filter state provider
final todoFilterProvider = StateProvider<TodoFilter>((ref) {
  return const TodoFilter();
});

// Todos list state
class TodosState {
  final List<Todo> todos;
  final bool isLoading;
  final Failure? failure;
  final bool hasMore;
  final int currentOffset;

  const TodosState({
    this.todos = const [],
    this.isLoading = false,
    this.failure,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    Failure? failure,
    bool? hasMore,
    int? currentOffset,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }

// Main todos provider
final todosProvider = StateNotifierProvider<TodosNotifier, TodosState>((ref) {
  return TodosNotifier(ref);
});

class TodosNotifier extends StateNotifier<TodosState> {
  final Ref _ref;
  static const int _pageSize = 20;

  TodosNotifier(this._ref) : super(const TodosState()) {
    loadTodos();
  }

  Future<void> loadTodos({bool refresh = false}) async {
    if (state.isLoading) return;

    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    final userId = user?.id;
    
    if (userId == null) {
      state = state.copyWith(
        failure: const AuthenticationFailure('User not authenticated'),
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      failure: null,
      currentOffset: refresh ? 0 : state.currentOffset,
    );

    final filter = _ref.read(todoFilterProvider);
    final getTodos = _ref.read(getTodosUseCaseProvider);

    final result = await getTodos(GetTodosParams(
      userId: userId,
      status: filter.status,
      priority: filter.priority,
      searchQuery: filter.searchQuery,
      tags: filter.tags,
      limit: _pageSize,
      offset: refresh ? 0 : state.currentOffset,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        failure: failure,
        isLoading: false,
      ),
      (todos) => state = state.copyWith(
        todos: refresh ? todos : [...state.todos, ...todos],
        isLoading: false,
        hasMore: todos.length == _pageSize,
        currentOffset: refresh ? _pageSize : state.currentOffset + _pageSize,
      ),
    );
  }

  Future<void> createTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    final userId = user?.id;
    
    if (userId == null) {
      state = state.copyWith(
        failure: const AuthenticationFailure('User not authenticated'));
      return;
    }

    final createTodo = _ref.read(createTodoUseCaseProvider);

    final result = await createTodo(CreateTodoParams(
      userId: userId,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      tags: tags,
    ));

    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (todo) {
        state = state.copyWith(
          todos: [todo, ...state.todos],
          failure: null,
        );
      },
    );
  }

  Future<void> updateTodo({
    required String todoId,
    String? title,
    String? description,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    final userId = user?.id;
    
    if (userId == null) {
      state = state.copyWith(
        failure: const AuthenticationFailure('User not authenticated'));
      return;
    }

    final updateTodo = _ref.read(updateTodoUseCaseProvider);

    final result = await updateTodo(UpdateTodoParams(
      todoId: todoId,
      userId: userId,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      tags: tags,
    ));

    result.fold(
      (failure) => state = state.copyWith(failure: failure),
      (updatedTodo) {
        final updatedTodos = state.todos.map((todo) {
          return todo.id == todoId ? updatedTodo : todo;
        }).toList();
        
        state = state.copyWith(
          todos: updatedTodos,
          failure: null,
        );
      },
    );
  }

  Future<void> toggleTodoStatus(String todoId) async {
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    final userId = user?.id;
    
    if (userId == null) {
      state = state.copyWith(
        failure: const AuthenticationFailure('User not authenticated'));
      return;
    }

    // Optimistic update
    final todoIndex = state.todos.indexWhere((todo) => todo.id == todoId);
    if (todoIndex != -1) {
      final todo = state.todos[todoIndex];
      final newStatus = todo.status == TodoStatus.completed
          ? TodoStatus.pending
          : TodoStatus.completed;
      
      final updatedTodo = todo.copyWith(status: newStatus);
      final updatedTodos = [...state.todos];
      updatedTodos[todoIndex] = updatedTodo;
      
      state = state.copyWith(todos: updatedTodos);
    }

    final toggleStatus = _ref.read(toggleTodoStatusUseCaseProvider);

    final result = await toggleStatus(ToggleTodoStatusParams(
      todoId: todoId,
      userId: userId,
    ));

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        loadTodos(refresh: true);
        state = state.copyWith(failure: failure);
      },
      (_) => state = state.copyWith(failure: null),
    );
  }

  Future<void> deleteTodo(String todoId) async {
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    final userId = user?.id;
    
    if (userId == null) {
      state = state.copyWith(
        failure: const AuthenticationFailure('User not authenticated'));
      return;
    }

    // Optimistic update
    final updatedTodos = state.todos.where((todo) => todo.id != todoId).toList();
    state = state.copyWith(todos: updatedTodos);

    final deleteTodo = _ref.read(deleteTodoUseCaseProvider);

    final result = await deleteTodo(DeleteTodoParams(
      todoId: todoId,
      userId: userId,
    ));

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        loadTodos(refresh: true);
        state = state.copyWith(failure: failure);
      },
      (_) => state = state.copyWith(failure: null),
    );
  }

  void setFilter(TodoFilter filter) {
    _ref.read(todoFilterProvider.notifier).state = filter;
    loadTodos(refresh: true);
  }

  void clearFilter() {
    _ref.read(todoFilterProvider.notifier).state = const TodoFilter();
    loadTodos(refresh: true);
  }
}

// Stream provider for real-time updates
final todosStreamProvider = StreamProvider.autoDispose<List<Todo>>((ref) {
  final user = ref.watch(supabaseClientProvider).auth.currentUser;
  final userId = user?.id;
  
  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(todoRepositoryProvider);
  final filter = ref.watch(todoFilterProvider);

  return repository
      .watchTodos(
        userId: userId,
        status: filter.status,
      )
      .map((either) => either.fold(
            (failure) => [],
            (todos) => todos,
          ));
});

// Stats provider
final todoStatsProvider = FutureProvider.autoDispose<Map<TodoStatus, int>>((ref) async {
  final user = ref.watch(supabaseClientProvider).auth.currentUser;
  final userId = user?.id;
  
  if (userId == null) {
    return {
      TodoStatus.pending: 0,
      TodoStatus.inProgress: 0,
      TodoStatus.completed: 0,
    };
  }

  final repository = ref.watch(todoRepositoryProvider);
  final result = await repository.getTodoStats(userId: userId);

  return result.fold(
    (failure) => {
      TodoStatus.pending: 0,
      TodoStatus.inProgress: 0,
      TodoStatus.completed: 0,
    },
    (stats) => stats,
  );
};