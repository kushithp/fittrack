import 'package:flutter/material.dart';
import '../goals/goals_screen.dart';
import '../notes/notes_screen.dart';
import 'tracking_screen.dart';

class TrackingTabScreen extends StatelessWidget {
  const TrackingTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fitness & Health Tracking'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite_rounded), text: 'Health & Body'),
              Tab(icon: Icon(Icons.flag_rounded), text: 'Goals'),
              Tab(icon: Icon(Icons.note_alt_rounded), text: 'Journal Notes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HealthTrackingScreen(),
            GoalsScreen(),
            NotesScreen(),
          ],
        ),
      ),
    );
  }
}
