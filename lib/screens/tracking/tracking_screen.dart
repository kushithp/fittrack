import 'package:flutter/material.dart';
import 'sleep_tracking_widget.dart';
import 'water_tracking_widget.dart';
import 'weight_tracking_widget.dart';

class HealthTrackingScreen extends StatelessWidget {
  const HealthTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health & Habit Tracking'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WaterTrackingWidget(),
              const SizedBox(height: 16),
              const WeightTrackingWidget(),
              const SizedBox(height: 16),
              const SleepTrackingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
