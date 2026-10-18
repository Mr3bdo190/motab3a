import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/route_service.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});
  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  String _selectedDate = '';
  String? _selectedDriverId;
  String? _selectedDriverName;
  List<Map<dynamic, dynamic>> _drivers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _loadDrivers();
  }

  void _loadDrivers() async {
    final snap = await FirebaseDatabase.instance.ref('users').orderByChild('role').equalTo('driver').get();
    if (snap.exists) {
      final data = snap.value as Map;
      setState(() {
        _drivers = data.entries.map((e) => {'id': e.key, ...e.value}).toList();
      });
    }
  }

  void _save() async {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر السائق أولاً')));
      return;
    }
    setState(() => _isLoading = true);
    await RouteService().createRoute(_selectedDate, _selectedDriverId!, _selectedDriverName!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء خط سير')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('التاريخ'),
              subtitle: Text(_selectedDate, style: const TextStyle(fontSize: 18, color: AppTheme.primary)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (date != null) {
                  setState(() => _selectedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
                }
              },
            ),
            const Divider(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'السائق'),
              items: _drivers.map((d) => DropdownMenuItem(value: d['id'].toString(), child: Text(d['name'] ?? 'بدون اسم'))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDriverId = val;
                  _selectedDriverName = _drivers.firstWhere((d) => d['id'] == val)['name'];
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('إنشاء الخط'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
