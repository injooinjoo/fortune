import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/presentation/providers/todo_provider.dart';
import 'package:intl/intl.dart';

class TodoCreationDialog extends ConsumerStatefulWidget {
  final Todo? todoToEdit;

  const TodoCreationDialog({
    super.key,
    this.todoToEdit});

  @override
  ConsumerState<TodoCreationDialog> createState() => _TodoCreationDialogState();
}

class _TodoCreationDialogState extends ConsumerState<TodoCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.todoToEdit != null) {
      _titleController.text = widget.todoToEdit!.title;
      _descriptionController.text = widget.todoToEdit!.description ?? '';
      _tagsController.text = widget.todoToEdit!.tags.join(': ');
      _selectedPriority = widget.todoToEdit!.priority;
      _selectedDueDate = widget.todoToEdit!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 2);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate);

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final tagsText = _tagsController.text.trim();
      
      // Parse tags
      final tags = tagsText.isEmpty
          ? <String>[]
          : tagsText
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .take(10)
              .toList();

      if (widget.todoToEdit != null) {
        // Update existing todo
        await ref.read(todosProvider.notifier).updateTodo(
          todoId: widget.todoToEdit!.id,
          title: title,
          description: description.isEmpty ? null : description,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          tags: tags);
      } else {
        // Create new todo
        await ref.read(todosProvider.notifier).createTodo(
          title: title,
          description: description.isEmpty ? null : description,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          tags: tags);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.todoToEdit != null
                  ? '할 일이 수정되었습니다'
                  : '새로운 할 일이 추가되었습니다')));
      }
    } catch (e) {
      Logger.error('Error saving todo', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('할 일 저장 중 오류가 발생했습니다'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20))),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                // Title
                Text(
                  widget.todoToEdit != null ? '할 일 수정' : '새 할 일 추가',
                  style: theme.textTheme.headlineSmall),
                const SizedBox(height: 20),

                // Title input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목',
                    hintText: '할 일을 입력하세요',
                    border: OutlineInputBorder()),
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '제목을 입력해주세요';
                    }
                    if (value.trim().length > 200) {
                      return '제목은 200자 이하로 입력해주세요';
                    }
                    return null;
                  }),
                const SizedBox(height: 16),

                // Description input
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명 (선택)',
                    hintText: '추가 설명을 입력하세요',
                    border: OutlineInputBorder()),
                  maxLines: 3,
                  maxLength: 1000,
                  validator: (value) {
                    if (value != null && value.length > 1000) {
                      return '설명은 1000자 이하로 입력해주세요';
                    }
                    return null;
                  }),
                const SizedBox(height: 16),

                // Priority selector
                const Text('우선순위'),
                const SizedBox(height: 8),
                SegmentedButton<TodoPriority>(
                  segments: const [
                    ButtonSegment(
                      value: TodoPriority.low,
                      label: Text('낮음'),
                      icon: Icon(Icons.arrow_downward)),
                    ButtonSegment(
                      value: TodoPriority.medium,
                      label: Text('중간'),
                      icon: Icon(Icons.remove)),
                    ButtonSegment(
                      value: TodoPriority.high,
                      label: Text('높음'),
                      icon: Icon(Icons.arrow_upward))],
                  selected: {_selectedPriority},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedPriority = selection.first;
                    });
                  }),
                const SizedBox(height: 16),

                // Due date selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('마감일'),
                  subtitle: Text(
                    _selectedDueDate != null
                        ? dateFormat.format(_selectedDueDate!)
                        : '선택하지 않음'),
                  trailing: _selectedDueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedDueDate = null;
                            });
                          })
                      : null,
                  onTap: _selectDueDate),
                const SizedBox(height: 16),

                // Tags input
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: '태그 (선택)',
                    hintText: '태그를 쉼표로 구분하여 입력 (최대 10개)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline)),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final tags = value.split(',');
                      if (tags.length > 10) {
                        return '태그는 최대 10개까지 입력 가능합니다';
                      }
                      for (final tag in tags) {
                        if (tag.trim().length > 50) {
                          return '각 태그는 50자 이하로 입력해주세요';
                        }
                      }
                    }
                    return null;
                  }),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('취소')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveTodo,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2))
                          : Text(widget.todoToEdit != null ? '수정' : '추가'))])])))));
  }
}