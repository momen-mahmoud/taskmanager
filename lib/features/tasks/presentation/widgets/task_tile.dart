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

/// A playful task row. Tapping cycles the status (Pending → In Progress →
/// Done → …) via an animated indicator, alongside colorful status + priority
/// pills.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    this.isUpdating = false,
  });

  final Task task;
  final VoidCallback onTap;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusStyle(task.status);
    final priority = _priorityColor(task.priority);

    return BouncyTap(
      onTap: isUpdating ? null : onTap,
      pressedScale: 0.98,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusIndicator(status: task.status, busy: isUpdating),
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

/// Animated circular indicator with a distinct look per status:
/// empty (pending) · half/bolt (in progress) · filled check (done).
class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status, required this.busy});

  final TaskStatus status;
  final bool busy;

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
    final style = _statusStyle(status);
    final color = style.color;
    final filled = status == TaskStatus.done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: status == TaskStatus.pending
              ? Colors.grey.withValues(alpha: 0.6)
              : color,
          width: 2,
        ),
      ),
      child: switch (status) {
        TaskStatus.pending => null,
        TaskStatus.inProgress => Icon(Icons.bolt_rounded, size: 17, color: color),
        TaskStatus.done =>
          const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      },
    );
  }
}
