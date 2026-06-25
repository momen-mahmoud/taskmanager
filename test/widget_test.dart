import 'package:assessment/core/widgets/empty_state.dart';
import 'package:assessment/features/auth/presentation/screens/login_screen.dart';
import 'package:assessment/features/projects/domain/entities/project.dart';
import 'package:assessment/features/projects/presentation/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyState renders its title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(title: 'No projects yet', message: 'Pull to refresh'),
        ),
      ),
    );

    expect(find.text('No projects yet'), findsOneWidget);
    expect(find.text('Pull to refresh'), findsOneWidget);
  });

  testWidgets('ProjectCard shows title, status and triggers onTap',
      (tester) async {
    var tapped = false;
    const project = Project(
      id: 1,
      userId: 1,
      title: 'Marketing site',
      description: 'Build the landing page',
      status: ProjectStatus.active,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCard(project: project, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('Marketing site'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);

    await tester.tap(find.byType(ProjectCard));
    expect(tapped, true);
  });

  testWidgets('LoginScreen shows validation errors on empty submit',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
