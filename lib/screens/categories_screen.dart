import 'package:ahorrify/models/category_model.dart';
import 'package:ahorrify/services/database_helper.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _db = DatabaseHelper.instance;
  List<String> _incomeCategories = []; // Cambiado a List<String>
  List<String> _expenseCategories = []; // Cambiado a List<String>

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final incomes = await _db.getCategoriesByType('income');
    final expenses = await _db.getCategoriesByType('expense');
    setState(() {
      _incomeCategories = incomes;
      _expenseCategories = expenses;
    });
  }

  Future<void> _showCategoryDialog({
    CategoryModel? category,
    required String type,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  if (isEditing) {
                    await _db.updateCategory(
                      category.id!.toString(),
                      name,
                      type,
                    ); // Convertir a String
                  } else {
                    await _db.insertCategory(name, type);
                  }

                  if (!mounted) return; // Verifica si el widget sigue montado
                  Navigator.pop(context);
                  _loadCategories();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar Categoría'),
            content: Text(
              '¿Eliminar "${category.name}"? Esto no eliminará transacciones pasadas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _db.deleteCategory(
        category.id!.toString(),
        category.type,
      ); // Convertir a String
      if (!mounted) return; // Verifica si el widget sigue montado
      _loadCategories();
    }
  }

  Widget _buildCategoryList(
    String title,
    List<String> categories, // Cambiado a List<String>
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showCategoryDialog(type: type),
            ),
          ],
        ),
        ...categories.map(
          (cat) => ListTile(
            title: Text(cat),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed:
                      () => _showCategoryDialog(
                        category: CategoryModel(name: cat, type: type),
                        type: type,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      () =>
                          _confirmDelete(CategoryModel(name: cat, type: type)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCategoryList('Ingresos', _incomeCategories, 'income'),
            const Divider(),
            _buildCategoryList('Gastos', _expenseCategories, 'expense'),
          ],
        ),
      ),
    );
  }
}
