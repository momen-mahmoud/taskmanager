import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  /// Fetches projects (network-first, falling back to local cache when offline).
  Future<Either<Failure, List<Project>>> getProjects();
}
