import 'package:flutter/material.dart';
import 'package:opennutritracker/features/analytics/domain/entity/analytics_entity.dart';
import 'package:opennutritracker/features/analytics/presentation/widgets/macro_pie_chart.dart';
import 'package:opennutritracker/features/analytics/presentation/widgets/nutrition_trends_chart.dart';
import 'package:opennutritracker/features/analytics/presentation/widgets/streak_widget.dart';
import 'package:opennutritracker/features/analytics/presentation/widgets/weight_chart.dart';

/// Analytics dashboard screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7D'; // 7D, 30D, 90D, ALL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7D', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30D', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90D', child: Text('Last 90 Days')),
              const PopupMenuItem(value: 'ALL', child: Text('All Time')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak widget
            const StreakWidget(
              currentStreak: 7,
              longestStreak: 15,
              totalDaysLogged: 45,
            ),

            const SizedBox(height: 24),

            // Weight chart
            _buildSectionHeader(context, 'Weight Progress'),
            const SizedBox(height: 12),
            WeightChart(
              dataPoints: _getMockWeightData(),
              period: _selectedPeriod,
            ),

            const SizedBox(height: 24),

            // Nutrition trends
            _buildSectionHeader(context, 'Nutrition Trends'),
            const SizedBox(height: 12),
            NutritionTrendsChart(
              dataPoints: _getMockNutritionData(),
              period: _selectedPeriod,
            ),

            const SizedBox(height: 24),

            // Macro distribution
            _buildSectionHeader(context, 'Macro Distribution'),
            const SizedBox(height: 12),
            MacroPieChart(
              protein: _getMockNutritionData().last.protein,
              carbs: _getMockNutritionData().last.carbs,
              fat: _getMockNutritionData().last.fat,
            ),

            const SizedBox(height: 24),

            // Summary stats
            _buildSectionHeader(context, 'Summary'),
            const SizedBox(height: 12),
            _buildSummaryStats(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSummaryStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatRow(
              context,
              'Average Calories',
              '1,850 cal',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              'Average Protein',
              '125g',
              Icons.egg,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              'Days Tracked',
              '45 days',
              Icons.calendar_today,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              'Weight Change',
              '-3.5 kg',
              Icons.trending_down,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // Mock data generators
  List<WeightDataPoint> _getMockWeightData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return WeightDataPoint(
        date: now.subtract(Duration(days: 29 - index)),
        weightKg: 80 - (index * 0.1), // Gradual weight loss
      );
    });
  }

  List<NutritionDataPoint> _getMockNutritionData() {
    final now = DateTime.now();
    return List.generate(30, (index) {
      return NutritionDataPoint(
        date: now.subtract(Duration(days: 29 - index)),
        calories: 1800 + (index % 5) * 100,
        protein: 120 + (index % 3) * 10,
        carbs: 200 + (index % 4) * 20,
        fat: 60 + (index % 3) * 5,
      );
    });
  }
}
