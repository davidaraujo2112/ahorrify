// ignore_for_file: library_private_types_in_public_api

import 'package:ahorrify/models/transaction_model.dart';
import 'package:ahorrify/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  _AddEditTransactionScreenState createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late String _category;
  late TransactionType _type;
  late DateTime _date;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      _title = widget.transaction!.title;
      _amount = widget.transaction!.amount;
      _category = widget.transaction!.category;
      _type = widget.transaction!.type;
      _date = widget.transaction!.date;
    } else {
      _title = '';
      _amount = 0.0;
      _category = _categories.first;
      _type = TransactionType.expense;
      _date = DateTime.now();
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final transaction = TransactionModel(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _title,
        amount: _amount,
        category: _category,
        type: _type,
        date: _date,
      );

      final db = DatabaseHelper.instance;
      if (widget.transaction == null) {
        await db.insertTransaction(transaction);
      } else {
        await db.updateTransaction(transaction);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Agregar Transacción'
              : 'Editar Transacción',
        ),
        backgroundColor: Colors.teal,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Descripción'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingrese una descripción' : null,
              onSaved: (value) => _title = value!,
            ),
            TextFormField(
              initialValue: _amount.toString(),
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese un monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type == TransactionType.income ? 'Ingreso' : 'Gasto'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Fecha: ${DateFormat.yMMMd().format(_date)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _date = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
