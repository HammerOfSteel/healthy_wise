import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  double _performanceScore = 0.0;
  double _activityScore = 0.0;
  double _sleepPerformance = 0.0;

  @override
  void initState() {
    super.initState();
    _updateScores();
  }

  // Dummy function to simulate score calculation
  void _updateScores() {
    // For this MVP, let's set arbitrary scores
    // In a real-world application, these values would be calculated based on the user's performance and data
    setState(() {
      _performanceScore = 85.0;
      _activityScore = 75.0;
      _sleepPerformance = 90.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard('Performance Score', _performanceScore),
            SizedBox(height: 20.0),
            _buildScoreCard('Activity Score', _activityScore),
            SizedBox(height: 20.0),
            _buildScoreCard('Sleep Performance', _sleepPerformance),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.0),
            Text('Score: $score%', style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
