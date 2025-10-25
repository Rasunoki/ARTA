import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/download_helper.dart';
import 'admin_scaffold.dart';

class Survey {
  final String id;
  final String clientType;
  final String region;
  final String service;
  final DateTime date;

  Survey(this.id, this.clientType, this.region, this.service, this.date);
}

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Sample in-memory data (frontend only)
  final List<Survey> _allSurveys = List.generate(26, (i) {
    final regions = ['Karuhatan', 'Mapulang Lupa', 'Gen. T De Leon', 'Lawang Bato', 'Coloong', 'Polo'];
    return Survey(
      '00-00${i + 1}',
      i % 3 == 0 ? 'Citizen' : 'Business',
      regions[i % regions.length],
      (i % 4 == 0) ? 'Service A' : (i % 4 == 1) ? 'Service B' : (i % 4 == 2) ? 'Service C' : 'Service D',
      DateTime.utc(2025, 9, 30).add(Duration(days: i)),
    );
  });

  String _search = '';
  String _sortBy = 'Newest'; // Newest | Oldest | ID Asc | ID Desc
  int _currentPage = 0;
  final int _pageSize = 6;

  List<Survey> get _filtered {
    final q = _search.trim().toLowerCase();
    var list = _allSurveys.where((s) {
      if (q.isEmpty) return true;
      return s.id.toLowerCase().contains(q) || s.clientType.toLowerCase().contains(q) || s.region.toLowerCase().contains(q) || s.service.toLowerCase().contains(q);
    }).toList();

    switch (_sortBy) {
      case 'Newest':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'ID Asc':
        list.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'ID Desc':
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return list;
  }

  void _setSearch(String s) {
    setState(() {
      _search = s;
      _currentPage = 0;
    });
  }

  void _setSort(String sort) {
    setState(() {
      _sortBy = sort;
      _currentPage = 0;
    });
  }

  void _exportCurrentView() async {
    final rows = _filtered;
    const header = 'Survey ID,Client Type,Region,Service,Date';
    final csv = StringBuffer()..writeln(header);
    for (final s in rows) {
      csv.writeln('${s.id},${s.clientType},${s.region},${s.service},${s.date.toIso8601String()}');
    }
    final filename = 'surveys_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    try {
      final result = await saveCsvFile(filename, csv.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved export: $result')));
    } catch (e) {
      // fallback to clipboard
      await Clipboard.setData(ClipboardData(text: csv.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported to clipboard (fallback)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final total = filtered.length;
    final totalPages = (total / _pageSize).ceil().clamp(1, 9999);
    final start = (_currentPage * _pageSize) + 1;
    final end = ((_currentPage + 1) * _pageSize).clamp(0, total);
    final pageItems = filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return AdminScaffold(
      selectedRoute: '/admin/analytics',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Metrics Banner
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
              child: LayoutBuilder(builder: (context, constraints) {
                final narrow = constraints.maxWidth < 700;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MetricCard(title: 'Total Surveys', value: '${_allSurveys.length}', icon: Icons.list, color: Colors.green),
                      const SizedBox(height: 12),
                      _MetricCard(title: 'Active Surveys', value: '${_allSurveys.where((s) => s.date.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length}', icon: Icons.show_chart, color: Colors.teal),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MetricCard(title: 'Total Surveys', value: '${_allSurveys.length}', icon: Icons.list, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(title: 'Active Surveys', value: '${_allSurveys.where((s) => s.date.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length}', icon: Icons.show_chart, color: Colors.teal),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Large table panel with blue border and rounded corners
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF007BFF), width: 3),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'All Surveys',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Search and sort
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: _setSearch,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: 'Search (id, type, region, service)',
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: [
                                      Text('Sort by : $_sortBy', style: const TextStyle(color: Colors.black54)),
                                      const SizedBox(width: 6),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                                        onSelected: _setSort,
                                        itemBuilder: (ctx) => const [
                                          PopupMenuItem(value: 'Newest', child: Text('Newest')),
                                          PopupMenuItem(value: 'Oldest', child: Text('Oldest')),
                                          PopupMenuItem(value: 'ID Asc', child: Text('ID Asc')),
                                          PopupMenuItem(value: 'ID Desc', child: Text('ID Desc')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // Table header
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table area - fills available vertical space
                          Expanded(
                            child: SingleChildScrollView(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 600),
                                  child: DataTable(
                                    columnSpacing: 32,
                                    columns: const [
                                      DataColumn(label: Text('Survey ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Client Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Region of Residence', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Service Applied', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: pageItems.map((s) => DataRow(cells: [
                                      DataCell(Text(s.id)),
                                      DataCell(Text(s.clientType)),
                                      DataCell(Text(s.region)),
                                      DataCell(Text(s.service)),
                                      DataCell(Text('${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}')),
                                    ])).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          // Footer actions: export & pagination
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Showing data $start to $end of $total entries', style: TextStyle(color: Colors.grey[600])),
                              Row(
                                children: [
                                  IconButton(onPressed: _exportCurrentView, icon: const Icon(Icons.download_rounded)),
                                  const SizedBox(width: 8),
                                  // Simple pagination dots/numbers
                                  Row(
                                    children: List.generate(totalPages, (i) {
                                      final isActive = i == _currentPage;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: InkWell(
                                          onTap: () => setState(() => _currentPage = i),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isActive ? const Color(0xFF007BFF) : Colors.white,
                                              border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text('${i + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey[700])),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                  IconButton(
                                    onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            // withOpacity deprecated; use withAlpha for equivalent transparency (0.1 -> ~26)
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
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