import 'package:flutter/material.dart';
import 'admin_scaffold.dart';

class SurveyPage extends StatelessWidget {
  const SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/survey',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: const Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Survey Form (Disabled)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('Survey forms are disabled in this demo build. No actions will be performed.'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: null,
                child: Text('Submit (disabled)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
