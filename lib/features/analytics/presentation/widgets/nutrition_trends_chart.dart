import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/features/analytics/domain/entity/analytics_entity.dart';

/// Nutrition trends chart widget
class NutritionTrendsChart extends StatefulWidget {
  final List<NutritionDataPoint> dataPoints;
  final String period;

  const NutritionTrendsChart({
    super.key,
    required this.dataPoints,
    required this.period,
  });

  @override
  State<NutritionTrendsChart> createState() => _NutritionTrendsChartState();
}

class _NutritionTrendsChartState extends State<NutritionTrendsChart> {
  String _selectedMetric = 'calories'; // calories, protein, carbs, fat

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Metric selector
            Row(
              children: [
                Expanded(child: _buildMetricButton('calories', 'Calories', Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricButton('protein', 'Protein', Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricButton('carbs', 'Carbs', Colors.amber)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricButton('fat', 'Fat', Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                _buildChartData(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricButton(String metric, String label, Color color) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMetric = metric;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getAverageValue(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final spots = widget.dataPoints.asMap().entries.map((entry) {
      final value = _getValueForMetric(entry.value);
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    final color = _getColorForMetric();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getHorizontalInterval(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _getBottomInterval(),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= widget.dataPoints.length) return const Text('');
              final date = widget.dataPoints[value.toInt()].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (widget.dataPoints.length - 1).toDouble(),
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: color,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.trending_up,
                size: 60,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No nutrition data yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getValueForMetric(NutritionDataPoint point) {
    switch (_selectedMetric) {
      case 'calories':
        return point.calories;
      case 'protein':
        return point.protein;
      case 'carbs':
        return point.carbs;
      case 'fat':
        return point.fat;
      default:
        return point.calories;
    }
  }

  Color _getColorForMetric() {
    switch (_selectedMetric) {
      case 'calories':
        return Colors.orange;
      case 'protein':
        return Colors.red;
      case 'carbs':
        return Colors.amber;
      case 'fat':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getAverageValue() {
    final values = widget.dataPoints.map(_getValueForMetric);
    final average = values.reduce((a, b) => a + b) / values.length;

    if (_selectedMetric == 'calories') {
      return '${average.toInt()}';
    }
    return '${average.toInt()}g';
  }

  double _getMinY() {
    final values = widget.dataPoints.map(_getValueForMetric);
    final min = values.reduce((a, b) => a < b ? a : b);
    return (min * 0.8).floorToDouble();
  }

  double _getMaxY() {
    final values = widget.dataPoints.map(_getValueForMetric);
    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }

  double _getHorizontalInterval() {
    final range = _getMaxY() - _getMinY();
    return (range / 5).ceilToDouble();
  }

  double _getBottomInterval() {
    if (widget.dataPoints.length <= 7) return 1;
    if (widget.dataPoints.length <= 30) return 5;
    return 10;
  }
}
