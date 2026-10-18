import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/customer.dart';
import '../../../services/customer_service.dart';
import '../../../shared/widgets/empty_state.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});
  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerService _customerService = CustomerService();
  String _searchQuery = '';

  void _showAddCustomerSheet([Customer? customer]) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddCustomerSheet(customer: customer));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم، الكود، أو الهاتف...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
          ),
          Expanded(
            child: StreamBuilder<List<Customer>>(
              stream: _customerService.getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var customers = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  customers = customers.where((c) => c.name.contains(_searchQuery) || c.code.contains(_searchQuery) || c.phone.contains(_searchQuery)).toList();
                }

                if (customers.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'لا يوجد عملاء',
                    subtitle: 'اضغط على الزر بالأسفل لإضافة أول عميل',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Dismissible(
                        key: Key(customer.id),
                        direction: DismissDirection.endToStart,
                        background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('حذف العميل'),
                              content: Text('هل أنت متأكد من حذف "${customer.name}"؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppTheme.danger))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => _customerService.deleteCustomer(customer.id),
                        child: Card(
                          elevation: 2, margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => _showAddCustomerSheet(customer),
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppTheme.primary)),
                            title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('📞 ${customer.phone}'),
                                if (customer.area.isNotEmpty) Text('📍 ${customer.area}', style: const TextStyle(color: AppTheme.textLight)),
                              ],
                            ),
                            trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerSheet(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة عميل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
    );
  }
}

class AddCustomerSheet extends StatefulWidget {
  final Customer? customer;
  const AddCustomerSheet({super.key, this.customer});
  @override
  State<AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _codeController.text = widget.customer!.code;
      _phoneController.text = widget.customer!.phone;
      _areaController.text = widget.customer!.area;
      _addressController.text = widget.customer!.address;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final customer = Customer(id: widget.customer?.id ?? '', name: _nameController.text.trim(), code: _codeController.text.trim(), phone: _phoneController.text.trim(), area: _areaController.text.trim(), address: _addressController.text.trim(), isActive: widget.customer?.isActive ?? true);
    if (widget.customer == null) { await CustomerService().addCustomer(customer); } else { await CustomerService().updateCustomer(customer); }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text(widget.customer == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم العميل', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // أرقام فقط
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                  validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _codeController, decoration: const InputDecoration(labelText: 'كود العميل', prefixIcon: Icon(Icons.qr_code)))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _areaController, decoration: const InputDecoration(labelText: 'المنطقة', prefixIcon: Icon(Icons.location_city)))),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(labelText: 'العنوان بالتفصيل', prefixIcon: Icon(Icons.map))),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.customer == null ? 'حفظ العميل' : 'حفظ التعديلات')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
