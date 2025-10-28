import 'package:flutter/material.dart';
import 'admin_scaffold.dart';
import 'src/mock_api.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  Map<String, String> userData = {
    'name': 'GATCHALIAN, WES',
    'position': 'Admin',
    'department': 'Information Technology Department',
    'email': 'wes.gatchalian@valenzuela.gov.ph',
    'phone': '+63 912 345 6789',
  };

  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _descCtrl;
  Uint8List? _imageBytes;
  // Inline validation errors
  String? _nameError;
  String? _phoneError;
  String? _descError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: userData['name']);
    _positionCtrl = TextEditingController(text: userData['position']);
    _deptCtrl = TextEditingController(text: userData['department']);
    _emailCtrl = TextEditingController(text: userData['email']);
    _phoneCtrl = TextEditingController(text: userData['phone']);
    _imageCtrl = TextEditingController(text: userData['image'] ?? '');
    _descCtrl = TextEditingController(text: userData['description'] ?? '');
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final map = await MockApi.instance.fetchAdminProfile();
      if (!mounted) return;
      setState(() {
        userData['name'] = map['name'] ?? userData['name']!;
        userData['position'] = map['role'] ?? userData['position']!;
        if (map.containsKey('email')) userData['email'] = map['email']!;
        if (map.containsKey('phone')) userData['phone'] = map['phone']!;
        if (map.containsKey('description')) userData['description'] = map['description']!;
        if (map.containsKey('imageBase64')) userData['imageBase64'] = map['imageBase64']!;
        if (map.containsKey('image')) userData['image'] = map['image']!;

        _nameCtrl.text = userData['name']!;
        _positionCtrl.text = userData['position']!;
        _deptCtrl.text = userData['department']!;
        _emailCtrl.text = userData['email']!;
        _phoneCtrl.text = userData['phone']!;
        _imageCtrl.text = userData['image'] ?? '';
        _descCtrl.text = userData['description'] ?? '';
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    _deptCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _imageCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      selectedRoute: '/admin/profile',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Row(
                  children: [
                    // Profile Picture (editable)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[300],
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : (userData['imageBase64'] != null
                                    ? Image.memory(base64Decode(userData['imageBase64']!), fit: BoxFit.cover)
                                    : (_imageCtrl.text.isNotEmpty
                                        ? Image.network(_imageCtrl.text, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => const Icon(Icons.person, size: 60, color: Colors.grey))
                                        : const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey,
                                          ))),
                          ),
                        ),
                        if (_editing)
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Tooltip(
                              message: 'Change image',
                              child: InkWell(
                                onTap: () async {
                                  await _pickImage();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editing
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                                      child: TextField(
                                        controller: _nameCtrl,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                      ),
                                    ),
                                    if (_nameError != null) ...[
                                      const SizedBox(height: 6),
                                      Text(_nameError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                    ]
                                  ],
                                )
                              : Text(
                                  userData['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          // Position is not editable per requested scope
                          Text(
                            userData['position']!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    // Edit / Save / Cancel Button(s)
                    _editing
                        ? Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  // Cancel editing, revert controllers
                                  setState(() {
                                    _editing = false;
                                    _nameCtrl.text = userData['name']!;
                                    _positionCtrl.text = userData['position']!;
                                    _deptCtrl.text = userData['department']!;
                                    _emailCtrl.text = userData['email']!;
                                    _phoneCtrl.text = userData['phone']!;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Validate fields
                                  final name = _nameCtrl.text.trim();
                                  final phone = _phoneCtrl.text.trim();
                                  final image = _imageCtrl.text.trim();
                                  final desc = _descCtrl.text.trim();

                                  String? validationError;
                                  if (name.isEmpty) validationError = 'Name cannot be empty.';
                                  final phoneRegex = RegExp(r'^\+?[0-9 \-]{7,}$');
                                  if (validationError == null && !phoneRegex.hasMatch(phone)) validationError = 'Phone number looks invalid.';
                                  if (validationError == null && desc.isEmpty) validationError = 'Description cannot be empty.';

                                  if (validationError != null) {
                                    setState(() {
                                      _nameError = validationError == 'Name cannot be empty.' ? validationError : null;
                                      _phoneError = validationError == 'Phone number looks invalid.' ? validationError : null;
                                      _descError = validationError == 'Description cannot be empty.' ? validationError : null;
                                    });
                                    return;
                                  }

                                  // Call mock API to save
                                  // capture messenger before async gap
                                  final messenger = ScaffoldMessenger.of(context);
                                  () async {
                                    // Prepare payload
                                    final payload = <String, String>{'name': name, 'phone': phone, 'description': desc};
                                    if (_imageBytes != null) {
                                      payload['imageBase64'] = base64Encode(_imageBytes!);
                                    } else if (image.isNotEmpty) {
                                      payload['image'] = image;
                                    }
                                    final ok = await MockApi.instance.saveProfile(payload);
                                    if (!mounted) return;
                                    if (ok) {
                                      setState(() {
                                        userData['name'] = name;
                                        userData['phone'] = phone;
                                        if (payload.containsKey('imageBase64')) userData['imageBase64'] = payload['imageBase64']!;
                                        if (payload.containsKey('image')) userData['image'] = payload['image']!;
                                        userData['description'] = desc;
                                        _nameError = null;
                                        _phoneError = null;
                                        _descError = null;
                                        _editing = false;
                                      });
                                      messenger.showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
                                    } else {
                                      messenger.showSnackBar(const SnackBar(content: Text('Failed to save profile')));
                                    }
                                  }();
                                },
                                icon: const Icon(Icons.save, size: 16),
                                label: const Text('Save'),
                              ),
                            ],
                          )
                        : TextButton.icon(
                            onPressed: () => setState(() => _editing = true),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit Profile'),
                          ),
                  ],
                ),
                
                const SizedBox(height: 12),

                // Editable fields indicator
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text('Editable: Name · Image · Number · Description', style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 16),

                // User Information
                _infoRow('Department', userData['department']!),
                const SizedBox(height: 12),
                _infoRow('Email', userData['email']!),
                const SizedBox(height: 12),
                _infoRow('Phone Number', userData['phone']!, controller: _phoneCtrl),

                const SizedBox(height: 24),

                // Bio/Description (editable)
                Expanded(
                  child: SingleChildScrollView(
                    child: _editing
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _descCtrl,
                                        maxLines: null,
                                        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a short bio/description'),
                                      ),
                                      if (_descError != null) ...[
                                        const SizedBox(height: 6),
                                        Text(_descError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                      ],
                                    ],
                                  )
                                : Text(
                                    userData['description'] ?? '"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                    ),
                    onPressed: () => _showLogoutConfirmation(context),
                    child: const Text('LOG OUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {TextEditingController? controller}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const VerticalDivider(width: 24, thickness: 1),
          Expanded(
            child: controller != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_editing)
                        TextField(controller: controller, decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)))
                      else
                        Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      if (_phoneError != null && label.toLowerCase().contains('phone')) ...[
                        const SizedBox(height: 4),
                        Text(_phoneError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageCtrl.text = '';
      });
    } catch (e) {
      // ignore errors for the mock; show a SnackBar
      messenger.showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }



  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Close the dialog first
              Navigator.of(context).pop();
              // Show a confirmation and navigate to the login page, clearing the stack
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}