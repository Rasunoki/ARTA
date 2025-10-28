// flutter/material already imported at top
import 'admin_scaffold.dart';
import 'src/mock_api.dart';
import 'src/download_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _loading = true;
  String? _error;
  int _totalResponses = 0;
  int _activeResponses = 0;
  late final StreamSubscription<List<Map<String, String>>> _responsesSub;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
    // Subscribe to responses stream so metrics update live
    _responsesSub = MockApi.instance.responsesStream.listen((list) {
      if (!mounted) return;
      final total = list.length;
      final active = list.where((m) {
        final raw = m['date'] ?? '';
        try {
          final dt = DateTime.parse(raw);
          return dt.isAfter(DateTime.now().subtract(const Duration(days: 30)));
        } catch (_) {
          return false;
        }
      }).length;
      setState(() {
        _totalResponses = total;
        _activeResponses = active;
      });
    }, onError: (_) {});
  }

  Future<void> _loadSurveys() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // warm the surveys cache/server if needed; we don't keep them here in analytics
      await MockApi.instance.fetchSurveys();
      if (!mounted) return;
      setState(() { _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _exportResponses() async {
    try {
      final data = await MockApi.instance.fetchResponses();
      final rows = data;
      const header = 'Survey ID,Client Type,Region,Service,Date';
      final csv = StringBuffer()..writeln(header);
      for (final m in rows) {
        final raw = m['date'] ?? '';
        String dateStr = raw;
        try {
          final dt = DateTime.parse(raw);
          dateStr = '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
        } catch (_) {}
        csv.writeln('${m['id'] ?? '-'},${m['clientType'] ?? '-'},${m['region'] ?? '-'},${m['service'] ?? '-'},$dateStr');
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
    // metrics are updated from the responsesStream subscription;
    // no one-off loader required here.

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/analytics',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _loading
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Loading analytics...')]))
            : _error != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Failed to load analytics', style: TextStyle(color: Colors.red)), const SizedBox(height: 8), ElevatedButton(onPressed: _loadSurveys, child: const Text('Retry'))]))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top metrics card
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Icon circle
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), shape: BoxShape.circle),
                                    child: Icon(Icons.group, color: Colors.green, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text('Total Surveys', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 6),
                                      Text('$_totalResponses', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(children: [const Icon(Icons.arrow_upward, color: Colors.green, size: 14), const SizedBox(width: 6), const Text('16% this month', style: TextStyle(color: Colors.green, fontSize: 12))]),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            // vertical divider
                            Container(width: 1, height: 56, color: Colors.grey.shade200),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), shape: BoxShape.circle),
                                    child: Icon(Icons.person, color: Colors.green, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const Text('Active Survey', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(height: 6),
                                      Text('$_activeResponses', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Row(children: [const Icon(Icons.arrow_downward, color: Colors.red, size: 14), const SizedBox(width: 6), const Text('1% this month', style: TextStyle(color: Colors.red, fontSize: 12))]),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Big content card (table area placeholder)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF007BFF), width: 3),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // large empty area for table preview
                              Expanded(child: Container()),

                              // export button placed close to bottom-right
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(onPressed: _exportResponses, icon: const Icon(Icons.download_rounded, size: 18), label: const Text('Export Data')),
                              ),

                              const SizedBox(height: 8),

                              // Footer row with left text and right pagination
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Showing data 1 to 8 of ${_totalResponses} entries', style: TextStyle(color: Colors.grey[500])),
                                  Row(
                                    children: [
                                      IconButton(onPressed: null, icon: const Icon(Icons.chevron_left)),
                                      // simple pagination preview
                                      for (var i = 1; i <= 5; i++)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(color: i == 1 ? const Color(0xFF2D6AE6) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade300)),
                                            child: Center(child: Text('$i', style: TextStyle(color: i == 1 ? Colors.white : Colors.grey[700]))),
                                          ),
                                        ),
                                      const SizedBox(width: 6),
                                      IconButton(onPressed: null, icon: const Icon(Icons.chevron_right)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _responsesSub.cancel();
    } catch (_) {}
    super.dispose();
  }

}

 
  