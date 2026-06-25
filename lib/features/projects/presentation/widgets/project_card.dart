import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncy_tap.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/project.dart';
import 'project_status_style.dart';

/// Playful project tile for the home grid: a bright colored icon badge, the
/// title (Hero-animated into details), a short description and a status pill.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = projectStatusStyle(project.status);
    final accent = AppColors.accentFor(project.id);

    return BouncyTap(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.folder_rounded, color: accent, size: 26),
              ),
              const SizedBox(height: 14),
              Hero(
                tag: 'project-title-${project.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    project.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusChip(
                    label: project.status.label,
                    color: status.color,
                    icon: status.icon,
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded,
                      size: 18, color: accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
