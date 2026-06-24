import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';

/// Projects list with pull-to-refresh, loading/error/empty states.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final userName = ref.watch(authProvider).valueOrNull?.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
        child: projectsAsync.when(
          loading: () => const LoadingView(message: 'Loading projects…'),
          error: (error, _) => _ScrollableFill(
            child: ErrorView(
              message: error.toString(),
              onRetry: () => ref.read(projectsProvider.notifier).refresh(),
            ),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return const _ScrollableFill(
                child: EmptyState(
                  icon: Icons.folder_off_outlined,
                  title: 'No projects yet',
                  message: 'Pull down to refresh and load your projects.',
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: projects.length + (userName != null ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (userName != null && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Hi, $userName 👋',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  );
                }
                final project = projects[index - (userName != null ? 1 : 0)];
                return ProjectCard(
                  project: project,
                  onTap: () => context.push(
                    AppRoutes.projectDetailsPath(project.id),
                    extra: project,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Wraps a centered child so it remains pull-to-refreshable even when short.
class _ScrollableFill extends StatelessWidget {
  const _ScrollableFill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
