import 'package:ahorrify/models/transaction_model.dart';
import 'package:ahorrify/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  late TransactionType _selectedType;
  String? _selectedCategory;
  late DateTime _selectedDate;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = DatabaseHelper.instance;
    final cats = await db.getCategoriesByType(_selectedType.toString().split('.').last);
    setState(() {
      _categories = cats;
      _selectedCategory = cats.firstWhere(
        (cat) => cat == widget.transaction.category,
        orElse: () => cats.isNotEmpty ? cats.first : '',
      );
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final updatedTx = TransactionModel(
        id: widget.transaction.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        category: _selectedCategory!,
        date: _selectedDate,
      );

      await DatabaseHelper.instance.updateTransaction(updatedTx);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Transacción'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese una descripción' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Monto (${currency.currencySymbol})',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Ingrese un monto válido'
                        : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tipo:'),
                  const SizedBox(width: 20),
                  DropdownButton<TransactionType>(
                    value: _selectedType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          _selectedCategory = null;
                        });
                        _loadCategories();
                      }
                    },
                    items: TransactionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type == TransactionType.income ? 'Ingreso' : 'Gasto'),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Fecha: ${DateFormat.yMMMd().format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
