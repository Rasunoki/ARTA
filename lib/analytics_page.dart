import 'package:flutter/material.dart';
import 'admin_scaffold.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/analytics',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: const Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}