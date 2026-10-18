import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../../../shared/widgets/empty_state.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  String _searchQuery = '';

  void _showAddProductSheet([Product? product]) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddProductSheet(product: product));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الكود...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ).animate().fadeIn().slideY(begin: -0.2),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                var products = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.contains(_searchQuery) || p.code.contains(_searchQuery)).toList();
                }

                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'لا يوجد منتجات',
                    subtitle: 'اضغط على الزر بالأسفل لإضافة أول منتج',
                  );
                }

                // Pull to refresh
                return RefreshIndicator(
                  onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Dismissible(
                        key: Key(product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
                        // تأكيد الحذف
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('حذف المنتج'),
                              content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: AppTheme.danger))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => _productService.deleteProduct(product.id),
                        child: Card(
                          elevation: 2, margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => _showAddProductSheet(product),
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.inventory_2, color: AppTheme.primary)),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text('${product.code} • ${product.unit}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${product.price} ج.م', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: product.isActive ? AppTheme.success.withOpacity(0.1) : AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(product.isActive ? 'نشط' : 'معطل', style: TextStyle(color: product.isActive ? AppTheme.success : AppTheme.danger, fontSize: 10))),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2),
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
        onPressed: () => _showAddProductSheet(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة منتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 300.ms, curve: Curves.easeOutBack),
    );
  }
}

// الـ AddProductSheet
class AddProductSheet extends StatefulWidget {
  final Product? product;
  const AddProductSheet({super.key, this.product});
  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedUnit = 'قطعة';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _codeController.text = widget.product!.code;
      _priceController.text = widget.product!.price.toString();
      _selectedUnit = widget.product!.unit;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final product = Product(id: widget.product?.id ?? '', name: _nameController.text.trim(), code: _codeController.text.trim(), unit: _selectedUnit, price: double.parse(_priceController.text.trim()), isActive: widget.product?.isActive ?? true);
    if (widget.product == null) { await ProductService().addProduct(product); } else { await ProductService().updateProduct(product); }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text(widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'اسم المنتج', prefixIcon: Icon(Icons.shopping_bag_outlined)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _codeController, decoration: const InputDecoration(labelText: 'كود المنتج', prefixIcon: Icon(Icons.qr_code)), validator: (v) => v!.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(value: _selectedUnit, decoration: const InputDecoration(labelText: 'الوحدة', prefixIcon: Icon(Icons.scale)), items: ['قطعة', 'كرتونة', 'عبوة', 'كيلو'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (v) => setState(() => _selectedUnit = v!)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController, 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))], // أرقام ونقطة عشرية فقط
                decoration: const InputDecoration(labelText: 'السعر', prefixIcon: Icon(Icons.attach_money)), 
                validator: (v) => v!.isEmpty ? 'مطلوب' : null
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _isLoading ? null : _save, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(widget.product == null ? 'حفظ المنتج' : 'حفظ التعديلات')),
            ],
          ),
        ),
      ),
    );
  }
}
