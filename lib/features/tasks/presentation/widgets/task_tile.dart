import 'package:flutter/material.dart';

import '../../../../core/widgets/bouncy_tap.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/task.dart';

({Color color, IconData icon}) _statusStyle(TaskStatus status) =>
    switch (status) {
      TaskStatus.pending => (color: Colors.grey, icon: Icons.schedule_rounded),
      TaskStatus.inProgress => (color: Colors.blue, icon: Icons.bolt_rounded),
      TaskStatus.done => (color: Color(0xFF2ED573), icon: Icons.check_rounded),
    };

Color _priorityColor(TaskPriority p) => switch (p) {
      TaskPriority.low => const Color(0xFF4ECDC4),
      TaskPriority.medium => const Color(0xFFFF9F1C),
      TaskPriority.high => const Color(0xFFFF6B6B),
    };

/// A playful task row: a tappable animated circular checkbox, the title
/// (struck through when done), and colorful status + priority pills.
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
    final priority = _priorityColor(task.priority);

    return BouncyTap(
      onTap: isUpdating ? null : onToggle,
      pressedScale: 0.98,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Check(done: task.isDone, busy: isUpdating, color: status.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: task.status.label,
                          color: status.color,
                          icon: status.icon,
                        ),
                        StatusChip(
                          label: task.priority.label,
                          color: priority,
                          icon: Icons.flag_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.done, required this.busy, required this.color});

  final bool done;
  final bool busy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        height: 28,
        width: 28,
        child: Padding(
          padding: EdgeInsets.all(3),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }
    final activeColor = done ? const Color(0xFF2ED573) : color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: done ? activeColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: done ? activeColor : Colors.grey.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : null,
    );
  }
}
