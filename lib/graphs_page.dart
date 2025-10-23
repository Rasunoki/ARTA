import 'package:flutter/material.dart';
import 'admin_scaffold.dart';

class GraphsPage extends StatelessWidget {
  const GraphsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/graphs',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Metrics
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricBox(title: 'Total Surveys', value: '5,423'),
                  _MetricBox(title: 'Active Surveys', value: '1,893'),
                  _MetricBox(title: 'Completion Rate', value: '87%'),
                  _MetricBox(title: 'Avg. Duration', value: '12 min'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Charts Grid
          Expanded(
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              children: const [
                _ChartCard(title: 'Response Trends', description: 'Monthly survey responses'),
                _ChartCard(title: 'User Engagement', description: 'Active users over time'),
                _ChartCard(title: 'Department Stats', description: 'Survey participation by department'),
                _ChartCard(title: 'Rating Distribution', description: 'Average ratings per survey'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;

  const _MetricBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String description;

  const _ChartCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Chart: $title',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}