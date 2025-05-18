import 'package:ahorrify/models/transaction_model.dart';
import 'package:ahorrify/providers/transaction_provider.dart';
import 'package:ahorrify/screens/add_transaction_screen.dart';
import 'package:ahorrify/screens/edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
              if (result == true) {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('Todas', 'all'),
                _buildFilterChip('Ingresos', 'income'),
                _buildFilterChip('Gastos', 'expense'),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = _filterTransactions(provider.transactions);

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No hay transacciones para mostrar'),
                  );
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: Key(transaction.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _confirmDelete(transaction);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: transaction.type == TransactionType.income
                              ? Colors.green
                              : Colors.red,
                          child: Icon(
                            transaction.type == TransactionType.income
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(transaction.title),
                        subtitle: Text(
                          '${transaction.category} - ${DateFormat.yMMMd().format(transaction.date)}',
                        ),
                        trailing: Text(
                          NumberFormat.currency(locale: 'es_MX', symbol: '\$')
                              .format(transaction.amount),
                          style: TextStyle(
                            color: transaction.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _editTransaction(transaction),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[300],
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    return transactions.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(_searchQuery) ||
          transaction.category.toLowerCase().contains(_searchQuery);

      final matchesFilter = _selectedFilter == 'all' ||
          (_selectedFilter == 'income' &&
              transaction.type == TransactionType.income) ||
          (_selectedFilter == 'expense' &&
              transaction.type == TransactionType.expense);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(TransactionModel transaction) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true && transaction.id != null) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.deleteTransaction(transaction.id!);

      if (!mounted) return;

      setState(() {});
    }
  }
}
