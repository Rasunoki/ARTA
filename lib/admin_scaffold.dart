import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'src/mock_api.dart';
import 'dart:async';
 import 'dart:typed_data';
import 'dart:convert';

typedef NavCallback = void Function(String route);

class AdminScaffold extends StatefulWidget {
  final Widget child;
  final String selectedRoute;
  final NavCallback onNavigate;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.selectedRoute,
    required this.onNavigate,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> with SingleTickerProviderStateMixin {
  // Sidebar is fixed (non-collapsible)
  static const double _sidebarWidth = 260.0;
  late final StreamSubscription<Map<String, String>> _profileSub;
  Uint8List? _avatarBytes;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    // Load admin profile from mock API (frontend-ready placeholder)
    _loadProfile();
    // Listen for live profile updates from MockApi
    _profileSub = MockApi.instance.profileStream.listen((map) {
      if (!mounted) return;
      setState(() {
        _adminName = map['name'] ?? _adminName;
        _adminRole = map['role'] ?? _adminRole;
        if (map.containsKey('imageBase64')) {
          try {
            _avatarBytes = base64Decode(map['imageBase64']!);
            _avatarUrl = null;
          } catch (_) {
            _avatarBytes = null;
          }
        } else if (map.containsKey('image')) {
          _avatarUrl = map['image'];
          _avatarBytes = null;
        }
      });
    }, onError: (_) {});
  }

  String _adminName = 'Admin User';
  String _adminRole = 'admin';

  Future<void> _loadProfile() async {
    try {
      final map = await MockApi.instance.fetchAdminProfile();
      if (!mounted) return;
      setState(() {
        _adminName = map['name'] ?? _adminName;
        _adminRole = map['role'] ?? _adminRole;
        if (map.containsKey('imageBase64')) {
          try {
            _avatarBytes = base64Decode(map['imageBase64']!);
            _avatarUrl = null;
          } catch (_) {
            _avatarBytes = null;
          }
        } else if (map.containsKey('image')) {
          _avatarUrl = map['image'];
          _avatarBytes = null;
        }
      });
    } catch (_) {
      // ignore — leave defaults
    }
  }



  @override
  Widget build(BuildContext context) {
    const width = _sidebarWidth;
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: width,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: Image.asset(
                          'assets/city_logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => const Icon(Icons.location_city, size: 20, color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Navigation Items
                // Use Bootstrap Icons (CDN SVGs)
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/chat-dots.svg',
                  icon: Icons.chat_bubble_outline,
                  label: 'Responses',
                  route: '/admin/responses',
                  selected: widget.selectedRoute == '/admin/responses',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/graph-up.svg',
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  route: '/admin/analytics',
                  selected: widget.selectedRoute == '/admin/analytics',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/people.svg',
                  icon: Icons.people_outline,
                  label: 'User Management',
                  route: '/admin/users',
                  selected: widget.selectedRoute == '/admin/users',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                _SidebarItem(
                  iconSvg: 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/icons/clipboard-data.svg',
                  icon: Icons.list_alt,
                  label: 'Survey Form',
                  route: '/admin/survey',
                  selected: widget.selectedRoute == '/admin/survey',
                  collapsed: false,
                  onTap: widget.onNavigate,
                ),
                const Spacer(),

                // User profile area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => widget.onNavigate('/admin/profile'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey,
                                backgroundImage: _avatarBytes != null
                                    ? MemoryImage(_avatarBytes!)
                                    : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                        ? NetworkImage(_avatarUrl!) as ImageProvider
                                        : const AssetImage('assets/profile_placeholder.png')),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_adminName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(_adminRole, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    ],
                                  ),
                              ),
                              const Icon(Icons.chevron_right, size: 20, color: Colors.black45),
                            ],
                          ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content with background image from assets
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Color.fromRGBO(0, 0, 0, 0.45), BlendMode.darken),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _profileSub.cancel();
    super.dispose();
  }
}

class _SidebarItem extends StatelessWidget {
  final String? iconSvg;
  final IconData icon;
  final String label;
  final String route;
  final bool selected;
  final bool collapsed;
  final NavCallback onTap;

  const _SidebarItem({
    this.iconSvg,
    required this.icon,
    required this.label,
    required this.route,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: selected
              ? BoxDecoration(
                  color: const Color(0xFF007BFF),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                )
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 8 : 12,
            vertical: 10,
          ),
          child: collapsed
              ? SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Center(
                    child: iconSvg != null
                        ? _maybeSvg(iconSvg!, selected)
                        : Icon(
                            icon,
                            color: selected ? Colors.white : Colors.black54,
                            size: 20,
                          ),
                  ),
                )
              : Row(
                  children: [
                    if (iconSvg != null)
                      _maybeSvg(iconSvg!, selected)
                    else
                      Icon(
                        icon,
                        color: selected ? Colors.white : Colors.black54,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (selected) const Icon(Icons.chevron_right, color: Colors.white, size: 16),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _maybeSvg(String path, bool selected) {
    try {
      if (path.startsWith('http')) {
        return SvgPicture.network(
          path,
          width: 20,
          height: 20,
          color: selected ? Colors.white : Colors.black54,
          placeholderBuilder: (_) => const SizedBox(width: 20, height: 20),
        );
      }
      return SvgPicture.asset(
        path,
        width: 20,
        height: 20,
        color: selected ? Colors.white : Colors.black54,
      );
    } catch (_) {
      return Icon(
        icon,
        color: selected ? Colors.white : Colors.black54,
        size: 20,
      );
    }
  }
}