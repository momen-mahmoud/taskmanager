import 'package:flutter/material.dart';

import '../../domain/entities/project.dart';

/// Maps a [ProjectStatus] to a display color + icon (presentation concern,
/// kept out of the domain entity).
({Color color, IconData icon}) projectStatusStyle(ProjectStatus status) {
  return switch (status) {
    ProjectStatus.active => (color: Colors.green, icon: Icons.play_circle_outline),
    ProjectStatus.onHold => (color: Colors.orange, icon: Icons.pause_circle_outline),
    ProjectStatus.completed => (color: Colors.blueGrey, icon: Icons.check_circle_outline),
  };
}
