import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../projects/presentation/widgets/project_status_style.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';

/// Tasks for a selected project. Receives the [Project] via GoRouter `extra`,
/// falling back to a lookup in the cached projects list for deep links.
class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.project,
  });

  final int projectId;
  final Project? project;

  Project? _resolveProject(WidgetRef ref) {
    if (project != null) return project;
    final list = ref.watch(projectsProvider).valueOrNull ?? const [];
    for (final p in list) {
      if (p.id == projectId) return p;
    }
    return null;
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    TaskArgs args,
    Task task,
  ) async {
    try {
      await ref.read(tasksProvider(args).notifier).toggle(task);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = _resolveProject(ref);

    if (resolved == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorView(message: 'Project not found.'),
      );
    }

    final args = (projectId: resolved.id, userId: resolved.userId);
    final tasksAsync = ref.watch(tasksProvider(args));
    final style = projectStatusStyle(resolved.status);

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'project-title-${resolved.id}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              resolved.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTaskSheet(context, args),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProjectHeader(project: resolved, statusColor: style.color, statusIcon: style.icon),
          Expanded(
            child: tasksAsync.when(
              loading: () => const LoadingView(message: 'Loading tasks…'),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(tasksProvider(args)),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.checklist_rtl,
                    title: 'No tasks yet',
                    message: 'Tap "Add Task" to create your first one.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggle(context, ref, args, task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({
    required this.project,
    required this.statusColor,
    required this.statusIcon,
  });

  final Project project;
  final Color statusColor;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusChip(
            label: project.status.label,
            color: statusColor,
            icon: statusIcon,
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              project.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
