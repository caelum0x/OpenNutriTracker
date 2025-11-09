import 'package:equatable/equatable.dart';

/// Weight entry for tracking
class WeightDataPoint extends Equatable {
  final DateTime date;
  final double weightKg;

  const WeightDataPoint({
    required this.date,
    required this.weightKg,
  });

  double get weightLbs => weightKg * 2.20462;

  @override
  List<Object?> get props => [date, weightKg];
}

/// Nutrition data point
class NutritionDataPoint extends Equatable {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionDataPoint({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  double get totalMacros => protein + carbs + fat;
  double get proteinPercent => (protein / totalMacros) * 100;
  double get carbsPercent => (carbs / totalMacros) * 100;
  double get fatPercent => (fat / totalMacros) * 100;

  @override
  List<Object?> get props => [date, calories, protein, carbs, fat];
}

/// Streak tracking
class StreakEntity extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastLogDate;
  final int totalDaysLogged;

  const StreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    this.lastLogDate,
    required this.totalDaysLogged,
  });

  bool get isActiveToday {
    if (lastLogDate == null) return false;
    final today = DateTime.now();
    final lastLog = lastLogDate!;
    return today.year == lastLog.year &&
        today.month == lastLog.month &&
        today.day == lastLog.day;
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastLogDate,
        totalDaysLogged,
      ];
}

/// Analytics summary
class AnalyticsSummaryEntity extends Equatable {
  final List<WeightDataPoint> weightHistory;
  final List<NutritionDataPoint> nutritionHistory;
  final StreakEntity streak;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsSummaryEntity({
    required this.weightHistory,
    required this.nutritionHistory,
    required this.streak,
    required this.startDate,
    required this.endDate,
  });

  // Average calculations
  double get averageCalories {
    if (nutritionHistory.isEmpty) return 0;
    final total = nutritionHistory.fold<double>(
      0,
      (sum, point) => sum + point.calories,
    );
    return total / nutritionHistory.length;
  }

  double get averageProtein {
    if (nutritionHistory.isEmpty) return 0;
    final total = nutritionHistory.fold<double>(
      0,
      (sum, point) => sum + point.protein,
    );
    return total / nutritionHistory.length;
  }

  double get averageCarbs {
    if (nutritionHistory.isEmpty) return 0;
    final total = nutritionHistory.fold<double>(
      0,
      (sum, point) => sum + point.carbs,
    );
    return total / nutritionHistory.length;
  }

  double get averageFat {
    if (nutritionHistory.isEmpty) return 0;
    final total = nutritionHistory.fold<double>(
      0,
      (sum, point) => sum + point.fat,
    );
    return total / nutritionHistory.length;
  }

  // Weight trends
  double? get weightChange {
    if (weightHistory.length < 2) return null;
    final first = weightHistory.first.weightKg;
    final last = weightHistory.last.weightKg;
    return last - first;
  }

  double? get currentWeight {
    if (weightHistory.isEmpty) return null;
    return weightHistory.last.weightKg;
  }

  @override
  List<Object?> get props => [
        weightHistory,
        nutritionHistory,
        streak,
        startDate,
        endDate,
      ];
}

/// Achievement types
enum AchievementType {
  firstLog,
  sevenDayStreak,
  thirtyDayStreak,
  hundredDayStreak,
  aiScanMaster,
  goalReached,
  weightMilestone,
}

/// Achievement entity
class AchievementEntity extends Equatable {
  final AchievementType type;
  final String title;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String icon;

  const AchievementEntity({
    required this.type,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.unlockedAt,
    required this.icon,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        description,
        isUnlocked,
        unlockedAt,
        icon,
      ];
}
