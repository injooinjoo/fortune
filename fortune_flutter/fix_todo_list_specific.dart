#!/usr/bin/env dart

import 'dart:io';

void main() async {
  print('🔧 Fixing specific todo_list_page.dart syntax issues...');
  
  final file = File('lib/presentation/pages/todo/todo_list_page.dart');
  if (!file.existsSync()) {
    print('❌ File not found: lib/presentation/pages/todo/todo_list_page.dart');
    return;
  }

  try {
    String content = await file.readAsString();
    
    // Fix specific syntax issues found in the file
    content = content
        // Fix showModalBottomSheet syntax
        .replaceAll(
          'showModalBottomSheet(\n      context: context,\n    isScrollControlled: true,\n      backgroundColor: Colors.transparent)\n    builder: (context) => const TodoCreationDialog(),',
          'showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: Colors.transparent,\n      builder: (context) => const TodoCreationDialog(),')
        
        // Fix appBar properties
        .replaceAll(
          '        title: const Text(\'나의 할 일\'),\n    elevation: 0,',
          '        title: const Text(\'나의 할 일\'),\n        elevation: 0,')
        
        // Fix IconButton onPressed
        .replaceAll(
          '    onPressed: () {',
          '            onPressed: () {')
        
        // Fix trailing parentheses and commas in various places
        .replaceAll(RegExp(r'\)\$1,'), '),')
        .replaceAll(RegExp(r'\$1,'), ',')
        
        // Fix specific widget syntax issues
        .replaceAll(
          '          controller: _scrollController)\n    slivers: [',
          '          controller: _scrollController,\n          slivers: [')
        
        .replaceAll(
          '                  height: 50)\n    child: ListView(',
          '                  height: 50,\n                  child: ListView(')
        
        .replaceAll(
          '                    scrollDirection: Axis.horizontal)\n    padding: const EdgeInsets.symmetric(horizontal: 16),\n    children: [',
          '                    scrollDirection: Axis.horizontal,\n                    padding: const EdgeInsets.symmetric(horizontal: 16),\n                    children: [')
        
        .replaceAll(
          '                      if (filter.status != null)\n                        TodoFilterChip(',
          '                      if (filter.status != null)\n                        TodoFilterChip(')
        
        .replaceAll(
          '                          label: \'검색: \${filter.searchQuery}\')\n    onDeleted: () {',
          '                          label: \'검색: \${filter.searchQuery}\',\n                          onDeleted: () {')
        
        .replaceAll(
          '                  message: \'할 일을 불러올 수 없습니다\')\n    onRetry: () => ref.read(todosProvider.notifier).loadTodos(refresh: true),',
          '                  message: \'할 일을 불러올 수 없습니다\',\n                  onRetry: () => ref.read(todosProvider.notifier).loadTodos(refresh: true),')
        
        .replaceAll(
          '    title: \'할 일이 없습니다\')\n                  subtitle: \'새로운 할 일을 추가해보세요\')',
          '                  title: \'할 일이 없습니다\',\n                  subtitle: \'새로운 할 일을 추가해보세요\',')
        
        .replaceAll(
          '        onPressed: _showCreateTodoDialog)\n    icon: const Icon(Icons.add),',
          '        onPressed: _showCreateTodoDialog,\n        icon: const Icon(Icons.add),')
        
        // Fix showDialog syntax
        .replaceAll(
          '      context: context)\n    builder: (context) => AlertDialog(',
          '      context: context,\n      builder: (context) => AlertDialog(')
        
        .replaceAll(
          '        title: const Text(\'할 일 검색\'),\n    content: TextField(',
          '        title: const Text(\'할 일 검색\'),\n        content: TextField(')
        
        .replaceAll(
          '          controller: textController,\n    decoration: const InputDecoration(',
          '          controller: textController,\n          decoration: const InputDecoration(')
        
        .replaceAll(
          '            hintText: \'검색어를 입력하세요\')\n    prefixIcon: Icon(Icons.search),',
          '            hintText: \'검색어를 입력하세요\',\n            prefixIcon: Icon(Icons.search),')
        
        // Fix Container and showModalBottomSheet
        .replaceAll(
          '      context: context)\n    builder: (context) => Container(',
          '      context: context,\n      builder: (context) => Container(')
        
        .replaceAll(
          '        padding: const EdgeInsets.all(16),\n    child: Column(',
          '        padding: const EdgeInsets.all(16),\n        child: Column(')
        
        .replaceAll(
          '          mainAxisSize: MainAxisSize.min,\n    crossAxisAlignment: CrossAxisAlignment.start)\n          children: [',
          '          mainAxisSize: MainAxisSize.min,\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: [')
        
        .replaceAll(
          '              \'필터 옵션\')\n              style: Theme.of(context).textTheme.titleLarge?.copyWith(',
          '              \'필터 옵션\',\n              style: Theme.of(context).textTheme.titleLarge?.copyWith(')
        
        .replaceAll(
          '              spacing: 8)\n    children: [',
          '              spacing: 8,\n              children: [')
        
        .replaceAll(
          '    selected: ref.watch(todoFilterProvider).status == null,',
          '                  selected: ref.watch(todoFilterProvider).status == null,')
        
        .replaceAll(
          '                                status: selected ? status : null)\n                              ),',
          '                                status: selected ? status : null,\n                              ),')
        
        .replaceAll(
          '                                priority: selected ? priority : null)\n                              ),',
          '                                priority: selected ? priority : null,\n                              ),');

    await file.writeAsString(content);
    print('✅ Fixed todo_list_page.dart syntax issues');
    
  } catch (e) {
    print('❌ Error fixing todo_list_page.dart: $e');
  }
}