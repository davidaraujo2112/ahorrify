import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/settings_provider.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseBarChart({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<SettingsProvider>(context);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(16),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              barGroups: _buildBarGroups(expenses),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < expenses.length) {
                        return Text(
                          expenses[index].category,
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<Expense> expenses) {
    return List.generate(
      expenses.length,
      (index) {
        final expense = expenses[index];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: expense.amount,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
              width: 16,
            ),
          ],
        );
      },
    );
  }
}
