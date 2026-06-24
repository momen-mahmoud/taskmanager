import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecase/usecase.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_projects.dart';

final getProjectsUseCaseProvider =
    Provider((ref) => GetProjects(ref.read(projectRepositoryProvider)));

/// Exposes the projects list as an `AsyncValue` so the UI can render loading /
/// error / data / empty states uniformly. `refresh()` powers pull-to-refresh.
class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  Future<List<Project>> _fetch() async {
    final result = await ref.read(getProjectsUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure.message, (projects) => projects);
  }

  @override
  Future<List<Project>> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);
