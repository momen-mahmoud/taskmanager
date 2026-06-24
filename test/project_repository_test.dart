import 'package:assessment/core/error/exceptions.dart';
import 'package:assessment/core/error/failures.dart';
import 'package:assessment/core/network/network_info.dart';
import 'package:assessment/features/projects/data/datasources/project_local_datasource.dart';
import 'package:assessment/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:assessment/features/projects/data/models/project_model.dart';
import 'package:assessment/features/projects/data/repositories/project_repository_impl.dart';
import 'package:assessment/features/projects/domain/entities/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements ProjectRemoteDataSource {}

class MockLocal extends Mock implements ProjectLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late MockNetworkInfo network;
  late ProjectRepositoryImpl repository;

  const tProjects = [
    ProjectModel(
      id: 1,
      userId: 1,
      title: 'Alpha',
      description: 'first',
      status: ProjectStatus.active,
    ),
  ];

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    network = MockNetworkInfo();
    repository = ProjectRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: network,
    );
  });

  group('getProjects (online)', () {
    test('returns remote data and caches it on success', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.getProjects()).thenAnswer((_) async => tProjects);
      when(() => local.cacheProjects(any())).thenAnswer((_) async {});

      final result = await repository.getProjects();

      expect(result.isRight(), true);
      result.match((_) => fail('expected Right'),
          (projects) => expect(projects, tProjects));
      verify(() => local.cacheProjects(tProjects)).called(1);
    });

    test('falls back to cache when remote throws', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.getProjects())
          .thenThrow(const ServerException('boom'));
      when(() => local.getCachedProjects()).thenReturn(tProjects);

      final result = await repository.getProjects();

      expect(result.isRight(), true);
      result.match((_) => fail('expected cached Right'),
          (projects) => expect(projects, tProjects));
    });

    test('returns ServerFailure when remote fails and no cache', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.getProjects())
          .thenThrow(const ServerException('boom'));
      when(() => local.getCachedProjects())
          .thenThrow(const CacheException());

      final result = await repository.getProjects();

      expect(result.isLeft(), true);
      result.match((f) => expect(f, isA<ServerFailure>()),
          (_) => fail('expected Left'));
    });
  });

  group('getProjects (offline)', () {
    test('returns cached data when offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedProjects()).thenReturn(tProjects);

      final result = await repository.getProjects();

      expect(result.isRight(), true);
      verifyNever(() => remote.getProjects());
    });

    test('returns NetworkFailure when offline and no cache', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedProjects())
          .thenThrow(const CacheException());

      final result = await repository.getProjects();

      expect(result.isLeft(), true);
      result.match((f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('expected Left'));
    });
  });
}
