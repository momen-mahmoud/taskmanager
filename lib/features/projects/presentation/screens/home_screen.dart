import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_card.dart';

/// Projects grid with a colorful greeting banner, pull-to-refresh and
/// loading / error / empty states.
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CircleIconButton(
              icon: Icons.person_rounded,
              onTap: () => context.push(AppRoutes.profile),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _GreetingBanner(
                name: userName,
                count: projectsAsync.valueOrNull?.length,
              ),
            ),
            projectsAsync.when(
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingView(message: 'Loading projects…'),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.read(projectsProvider.notifier).refresh(),
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.folder_off_rounded,
                      title: 'No projects yet',
                      message: 'Pull down to refresh and load your projects.',
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return ProjectCard(
                          project: project,
                          onTap: () => context.push(
                            AppRoutes.projectDetailsPath(project.id),
                            extra: project,
                          ),
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Bright gradient welcome banner shown above the grid.
class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner({this.name, this.count});

  final String? name;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final subtitle = count == null
        ? 'Let’s get things done today'
        : 'You have $count project${count == 1 ? '' : 's'} to explore';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.seed, AppColors.accents[6]],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.seed.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name != null ? 'Hi, $name 👋' : 'Welcome 👋',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: scheme.primary, size: 22),
        ),
      ),
    );
  }
}
