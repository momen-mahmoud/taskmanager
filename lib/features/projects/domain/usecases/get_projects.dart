import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjects implements UseCase<List<Project>, NoParams> {
  const GetProjects(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Either<Failure, List<Project>>> call(NoParams params) {
    return _repository.getProjects();
  }
}
