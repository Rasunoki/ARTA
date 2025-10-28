import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/download_helper.dart';
import 'src/mock_api.dart';
import 'admin_scaffold.dart';

class ResponsesPage extends StatefulWidget {
  const ResponsesPage({super.key});

  @override
  State<ResponsesPage> createState() => _ResponsesPageState();
}

class _ResponsesPageState extends State<ResponsesPage> {
  List<Map<String, String>> _allResponses = [];
  bool _loading = true;
  String? _error;

  String _search = '';
  String _sortBy = 'Newest';
  int _currentPage = 0;
  final int _pageSize = 8;
  // pagination is computed from fetched data

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await MockApi.instance.fetchResponses();
      if (!mounted) return;
      // Normalize date fields to a display-friendly format (dd-MM-yyyy)
      final normalized = data.map((m) {
        final raw = m['date'] ?? '';
        String dateStr = raw;
        try {
          final dt = DateTime.parse(raw);
          dateStr = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
        } catch (_) {}
        return {
          'id': m['id'] ?? '-',
          'name': m['name'] ?? '-',
          'clientType': m['clientType'] ?? '-',
          'region': m['region'] ?? '-',
          'service': m['service'] ?? '-',
          // keep original ISO date for parsing in metrics/pagination logic
          'dateIso': raw,
          'date': dateStr,
        };
      }).toList();

      setState(() {
        _allResponses = normalized;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Map<String, String>> get _filtered {
    final q = _search.trim().toLowerCase();
    var list = _allResponses.where((s) {
      if (q.isEmpty) return true;
      return s['id']!.toLowerCase().contains(q) || (s['name'] ?? '').toLowerCase().contains(q) || s['clientType']!.toLowerCase().contains(q) || s['region']!.toLowerCase().contains(q) || s['service']!.toLowerCase().contains(q);
    }).toList();

    switch (_sortBy) {
      case 'Newest':
        list.sort((a, b) => b['date']!.compareTo(a['date']!));
        break;
      case 'Oldest':
        list.sort((a, b) => a['date']!.compareTo(b['date']!));
        break;
      case 'ID Asc':
        list.sort((a, b) => a['id']!.compareTo(b['id']!));
        break;
      case 'ID Desc':
        list.sort((a, b) => b['id']!.compareTo(a['id']!));
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
      csv.writeln('${s['id']},${s['clientType']},${s['region']},${s['service']},${s['date']}');
    }
    final filename = 'responses_${DateTime.now().toIso8601String().replaceAll(':', '-')}.csv';
    try {
      final result = await saveCsvFile(filename, csv.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved export: $result')));
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: csv.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exported to clipboard (fallback)')));
    }
  }

  @override
  Widget build(BuildContext context) {
  final filtered = _filtered;
  final totalFiltered = filtered.length;
  final totalPages = (totalFiltered / _pageSize).ceil().clamp(1, 9999);
  final start = totalFiltered == 0 ? 0 : (_currentPage * _pageSize) + 1;
  final end = ((_currentPage + 1) * _pageSize).clamp(0, totalFiltered);
  final pageItems = filtered.skip(_currentPage * _pageSize).take(_pageSize).toList();

    return AdminScaffold(
      selectedRoute: '/admin/responses',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Loading responses...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Failed to load responses', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadResponses, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
          const SizedBox(height: 6),
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Survey Responses',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: _setSearch,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9AAED8)),
                                      hintText: 'Search',
                                      hintStyle: const TextStyle(color: Color(0xFF9AAED8)),
                                      filled: true,
                                      fillColor: const Color(0xFFEFF5FF),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                PopupMenuButton<String>(
                                  onSelected: _setSort,
                                  itemBuilder: (ctx) => const [
                                    PopupMenuItem(value: 'Newest', child: Text('Newest')),
                                    PopupMenuItem(value: 'Oldest', child: Text('Oldest')),
                                    PopupMenuItem(value: 'ID Asc', child: Text('ID Asc')),
                                    PopupMenuItem(value: 'ID Desc', child: Text('ID Desc')),
                                  ],
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(color: const Color(0xFFEFF5FF), borderRadius: BorderRadius.circular(24)),
                                    child: Row(
                                      children: [
                                        const Text('Sort by : ', style: TextStyle(color: Color(0xFF6F7F9F))),
                                        Text(_sortBy, style: const TextStyle(color: Color(0xFF2B4776), fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.arrow_drop_down, color: Color(0xFF2B4776)),
                                      ],
                                    ),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Table area (centered when it fits, horizontally scrollable when needed)
                          Expanded(
                            child: LayoutBuilder(builder: (context, constraints) {
                              final viewportWidth = constraints.maxWidth;
                              return SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    // ensure the horizontal scroll child is at least as wide as the viewport
                                    constraints: BoxConstraints(minWidth: viewportWidth),
                                    child: Center(
                                      child: SizedBox(
                                        width: viewportWidth,
                                        child: DataTable(
                                          columnSpacing: 24,
                                          columns: const [
                                            DataColumn(label: Text('Survey ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Client Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Region of Residence', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Service Applied', style: TextStyle(fontWeight: FontWeight.bold))),
                                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                          rows: pageItems
                                              .map((s) => DataRow(cells: [
                                                    DataCell(Text(s['id']!)),
                                                    DataCell(Text(s['name'] ?? '-')),
                                                    DataCell(Text(s['clientType']!)),
                                                    DataCell(Text(s['region']!)),
                                                    DataCell(Text(s['service']!)),
                                                    DataCell(Text(s['date']!)),
                                                  ]))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 8),

                          // Export button below the table, right-aligned (moved a bit closer)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(onPressed: _exportCurrentView, icon: const Icon(Icons.download_rounded, size: 18), label: const Text('Export Data')),
                          ),

                          const SizedBox(height: 8),

                          // Footer: showing text and pagination (reflects filtered count)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Showing data $start to $end of $totalFiltered entries', style: TextStyle(color: Colors.grey[500])),
                              Row(
                                children: [
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
                                              borderRadius: BorderRadius.circular(18),
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

// Metrics moved to Analytics page.
