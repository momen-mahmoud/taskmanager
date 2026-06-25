import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';

/// Shows the "add task" modal bottom sheet for the given project.
Future<void> showAddTaskSheet(BuildContext context, TaskArgs args) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddTaskSheet(args: args),
  );
}

const _priorityColors = {
  TaskPriority.low: Color(0xFF4ECDC4),
  TaskPriority.medium: Color(0xFFFF9F1C),
  TaskPriority.high: Color(0xFFFF6B6B),
};

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, required this.args});

  final TaskArgs args;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await ref
          .read(tasksProvider(widget.args).notifier)
          .add(title: _titleController.text, priority: _priority);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_task_rounded,
                      color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text('New Task', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Title',
              controller: _titleController,
              hint: 'What needs to be done?',
              textInputAction: TextInputAction.done,
              validator: (v) => Validators.required(v, field: 'Title'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text('Priority',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Row(
              children: [
                for (final p in TaskPriority.values) ...[
                  Expanded(child: _PriorityPill(
                    priority: p,
                    selected: _priority == p,
                    onTap: () => setState(() => _priority = p),
                  )),
                  if (p != TaskPriority.values.last) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 26),
            AppButton(
              label: 'Add Task',
              icon: Icons.add_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final TaskPriority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColors[priority]!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.flag_rounded,
                size: 20, color: selected ? Colors.white : color),
            const SizedBox(height: 4),
            Text(
              priority.label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
