import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/route_stop.dart';
import '../../services/route_service.dart';

class DriverVisitScreen extends StatefulWidget {
  final RouteStop stop;
  const DriverVisitScreen({super.key, required this.stop});

  @override
  State<DriverVisitScreen> createState() => _DriverVisitScreenState();
}

class _DriverVisitScreenState extends State<DriverVisitScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String _selectedStatus = 'delivered';

  void _submit() async {
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr) ?? 0.0;

    if (amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المبلغ لا يمكن أن يكون سالباً'), backgroundColor: AppTheme.danger));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await RouteService().recordCollection(widget.stop.id, amount, _selectedStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل التحصيل بنجاح'), backgroundColor: AppTheme.success));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.danger));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الزيارة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppTheme.primary.withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppTheme.primary.withOpacity(0.2))),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.storefront, size: 50, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    Text(widget.stop.customerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('📞 ${widget.stop.customerPhone}', style: const TextStyle(fontSize: 16, color: AppTheme.textLight)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('الحالة: ${widget.stop.status == 'pending' ? 'لم تبدأ' : 'تمت الزيارة'}', style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            if (widget.stop.status == 'pending') ...[
              const Text('تسجيل التحصيل المالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المحصل (ج.م)',
                  prefixIcon: Icon(Icons.money),
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'حالة التسليم', prefixIcon: Icon(Icons.check_circle_outline)),
                items: const [
                  DropdownMenuItem(value: 'delivered', child: Text('تم التسليم والتحصيل')),
                  DropdownMenuItem(value: 'partial', child: Text('تحصيل جزئي')),
                  DropdownMenuItem(value: 'not_delivered', child: Text('لم يتم التسليم')),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تأكيد التحصيل', style: TextStyle(fontSize: 18)),
                ),
              ),
            ] else ...[
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 80, color: AppTheme.success),
                    SizedBox(height: 16),
                    Text('تمت هذه الزيارة بالفعل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.success)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
