import 'package:flutter/material.dart';

import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/task.dart';

({Color color, IconData icon}) _statusStyle(TaskStatus status) =>
    switch (status) {
      TaskStatus.pending => (color: Colors.grey, icon: Icons.radio_button_unchecked),
      TaskStatus.inProgress => (color: Colors.blue, icon: Icons.timelapse),
      TaskStatus.done => (color: Colors.green, icon: Icons.check_circle),
    };

Color _priorityColor(TaskPriority p) => switch (p) {
      TaskPriority.low => Colors.teal,
      TaskPriority.medium => Colors.amber,
      TaskPriority.high => Colors.red,
    };

/// A single task row: a checkbox to toggle done, the title (struck through when
/// done), plus status and priority chips.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.isUpdating = false,
  });

  final Task task;
  final VoidCallback onToggle;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusStyle(task.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: isUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Checkbox(
                  value: task.isDone,
                  onChanged: (_) => onToggle(),
                ),
          title: Text(
            task.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              color: task.isDone ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: [
                StatusChip(
                  label: task.status.label,
                  color: status.color,
                  icon: status.icon,
                ),
                StatusChip(
                  label: '${task.priority.label} priority',
                  color: _priorityColor(task.priority),
                  icon: Icons.flag_outlined,
                ),
              ],
            ),
          ),
          onTap: isUpdating ? null : onToggle,
        ),
      ),
    );
  }
}
