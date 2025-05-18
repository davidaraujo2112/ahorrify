import 'package:ahorrify/models/transaction_model.dart';
import 'package:ahorrify/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'week';
  List<TransactionModel> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    final transactions = await provider.getTransactionsByDateRange(startDate, now);
    setState(() {
      _filteredTransactions = transactions;
    });
  }

  Map<String, double> _calculateCategoryTotals() {
    final categoryTotals = <String, double>{};
    for (var transaction in _filteredTransactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _calculateCategoryTotals();
    final totalExpense = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton('Semana', 'week'),
                _buildPeriodButton('Mes', 'month'),
                _buildPeriodButton('Año', 'year'),
              ],
            ),
          ),
          Expanded(
            child: categoryTotals.isEmpty
                ? const Center(child: Text('No hay datos disponibles'))
                : PieChart(
                    PieChartData(
                      sections: _createPieChartSections(categoryTotals, totalExpense),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categoryTotals.length,
              itemBuilder: (context, index) {
                final category = categoryTotals.keys.elementAt(index);
                final amount = categoryTotals[category]!;
                final percentage = (amount / totalExpense * 100).toStringAsFixed(1);

                return ListTile(
                  title: Text(category),
                  trailing: Text(
                    '\$${amount.toStringAsFixed(2)} ($percentage%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadTransactions();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      Map<String, double> categoryTotals, double totalExpense) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    return categoryTotals.entries.map((entry) {
      final percentage = entry.value / totalExpense;
      final color = colors[categoryTotals.keys.toList().indexOf(entry.key) % colors.length];

      return PieChartSectionData(
        value: entry.value,
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
