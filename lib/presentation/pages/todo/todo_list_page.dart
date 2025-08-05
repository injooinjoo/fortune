import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/presentation/pages/todo/widgets/todo_creation_dialog.dart';
import 'package:fortune/presentation/pages/todo/widgets/todo_filter_chip.dart';
import 'package:fortune/presentation/pages/todo/widgets/todo_list_item.dart';
import 'package:fortune/presentation/pages/todo/widgets/todo_stats_card.dart';
import 'package:fortune/presentation/providers/todo_provider.dart';
import 'package:fortune/presentation/widgets/common/empty_state_widget.dart';
import 'package:fortune/presentation/widgets/common/error_widget.dart';

class TodoListPage extends ConsumerStatefulWidget {
  const TodoListPage({super.key});

  @override
  ConsumerState<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends ConsumerState<TodoListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final todosState = ref.read(todosProvider);
      if (!todosState.isLoading && todosState.hasMore) {
        ref.read(todosProvider.notifier).loadTodos();
      }
    }
  }

  void _showCreateTodoDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TodoCreationDialog());
  }

  @override
  Widget build(BuildContext context) {
    final todosState = ref.watch(todosProvider);
    final filter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 할 일'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              _showSearchDialog();
            }),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions();
            })]),
      body: RefreshIndicator(
        onRefresh: () => ref.read(todosProvider.notifier).loadTodos(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Stats Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TodoStatsCard())),

            // Filter Chips
            if (filter.status != null ||
                filter.priority != null ||
                filter.searchQuery != null)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (filter.status != null)
                        TodoFilterChip(
                          label: _getStatusLabel(filter.status!),
                          onDeleted: () {
                            ref.read(todoFilterProvider.notifier).update(
                                  (state) => state.copyWith(status: () => null));
                            ref.read(todosProvider.notifier).loadTodos(refresh: true);
                          }),
                      if (filter.priority != null)
                        TodoFilterChip(
                          label: _getPriorityLabel(filter.priority!),
                          onDeleted: () {
                            ref.read(todoFilterProvider.notifier).update(
                                  (state) => state.copyWith(priority: () => null));
                            ref.read(todosProvider.notifier).loadTodos(refresh: true);
                          }),
                      if (filter.searchQuery != null)
                        TodoFilterChip(
                          label: '검색: ${filter.searchQuery}',
                          onDeleted: () {
                            ref.read(todoFilterProvider.notifier).update(
                                  (state) => state.copyWith(searchQuery: () => null));
                            ref.read(todosProvider.notifier).loadTodos(refresh: true);
                          })]))),

            // Error State
            if (todosState.failure != null && todosState.todos.isEmpty)
              SliverFillRemaining(
                child: CustomErrorWidget(
                  message: '할 일을 불러올 수 없습니다',
                  onRetry: () => ref.read(todosProvider.notifier).loadTodos(refresh: true))),

            // Empty State
            if (todosState.todos.isEmpty && !todosState.isLoading && todosState.failure == null)
              const SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.check_circle_outline,
                  title: '할 일이 없습니다',
                  subtitle: '새로운 할 일을 추가해보세요')),

            // Todo List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == todosState.todos.length) {
                    return todosState.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()))
                        : const SizedBox.shrink();
                  }

                  final todo = todosState.todos[index];
                  return TodoListItem(
                    key: ValueKey(todo.id),
                    todo: todo,
                    onToggle: () => ref.read(todosProvider.notifier).toggleTodoStatus(todo.id),
                    onDelete: () => ref.read(todosProvider.notifier).deleteTodo(todo.id),
                    onTap: () => _showTodoDetails(todo));
                },
                childCount: todosState.todos.length + (todosState.hasMore ? 1 : 0)))])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTodoDialog,
        icon: const Icon(Icons.add),
        label: const Text('새 할 일')));
  }

  void _showSearchDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 검색'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: '검색어를 입력하세요',
            prefixIcon: Icon(Icons.search)),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(todoFilterProvider.notifier).update(
                    (state) => state.copyWith(searchQuery: value.trim()));
              ref.read(todosProvider.notifier).loadTodos(refresh: true);
              Navigator.of(context).pop();
            }
          }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소')),
          TextButton(
            onPressed: () {
              final query = textController.text.trim();
              if (query.isNotEmpty) {
                ref.read(todoFilterProvider.notifier).update(
                      (state) => state.copyWith(searchQuery: query));
                ref.read(todosProvider.notifier).loadTodos(refresh: true);
                Navigator.of(context).pop();
              }
            },
            child: const Text('검색'))]));
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '필터 옵션',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('상태'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: ref.watch(todoFilterProvider).status == null,
                  onSelected: (selected) {
                    ref.read(todoFilterProvider.notifier).update(
                          (state) => state.copyWith(status: null));
                    ref.read(todosProvider.notifier).loadTodos(refresh: true);
                    Navigator.of(context).pop();
                  }),
                ...TodoStatus.values.map((status) => FilterChip(
                      label: Text(_getStatusLabel(status)),
                      selected: ref.watch(todoFilterProvider).status == status,
                      onSelected: (selected) {
                        ref.read(todoFilterProvider.notifier).update(
                              (state) => state.copyWith(
                                status: selected ? status : null));
                        ref.read(todosProvider.notifier).loadTodos(refresh: true);
                        Navigator.of(context).pop();
                      }))]),
            const SizedBox(height: 16),
            const Text('우선순위'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: ref.watch(todoFilterProvider).priority == null,
                  onSelected: (selected) {
                    ref.read(todoFilterProvider.notifier).update(
                          (state) => state.copyWith(priority: null));
                    ref.read(todosProvider.notifier).loadTodos(refresh: true);
                    Navigator.of(context).pop();
                  }),
                ...TodoPriority.values.map((priority) => FilterChip(
                      label: Text(_getPriorityLabel(priority)),
                      selected: ref.watch(todoFilterProvider).priority == priority,
                      onSelected: (selected) {
                        ref.read(todoFilterProvider.notifier).update(
                              (state) => state.copyWith(
                                priority: selected ? priority : null));
                        ref.read(todosProvider.notifier).loadTodos(refresh: true);
                        Navigator.of(context).pop();
                      }))])])));
  }

  void _showTodoDetails(Todo todo) {
    // Navigate to todo detail page or show dialog
    Logger.debug('Deleting todo: ${todo.id}');
  }

  String _getStatusLabel(TodoStatus status) {
    switch (status) {
      case TodoStatus.pending:
        return '대기중';
      case TodoStatus.inProgress:
        return '진행중';
      case TodoStatus.completed:
        return '완료';
    }
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return '높음';
      case TodoPriority.medium:
        return '중간';
      case TodoPriority.low:
        return '낮음';
    }
  }
}