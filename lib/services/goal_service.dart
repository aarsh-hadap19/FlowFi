import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowfi/models/goal.dart';
import 'package:flowfi/services/hive_service.dart';

class GoalService {
  late Box<Goal> _goalsBox;

  GoalService() {
    _goalsBox = HiveService.getGoalsBox();
  }

  // Add a new goal
  Future<void> addGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  // Get all goals
  List<Goal> getAllGoals() {
    return _goalsBox.values.toList();
  }

  // Get active goals
  List<Goal> getActiveGoals() {
    return _goalsBox.values.where((g) => g.isActive).toList();
  }

  // Get goals as a stream
  Stream<List<Goal>> watchGoals() {
    return _goalsBox.watch().map((_) => getAllGoals());
  }

  // Get goal by ID
  Goal? getGoal(String id) {
    return _goalsBox.get(id);
  }

  // Update goal
  Future<void> updateGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  // Delete goal
  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  // Get goals by type
  List<Goal> getGoalsByType(String type) {
    return _goalsBox.values.where((g) => g.type == type).toList();
  }

  // Increment goal streak
  Future<void> incrementGoalStreak(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.currentDays = goal.currentDays + 1;
      await updateGoal(goal);
    }
  }

  // Reset goal streak
  Future<void> resetGoalStreak(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.currentDays = 0;
      goal.lastResetDate = DateTime.now();
      await updateGoal(goal);
    }
  }

  // Mark goal as complete
  Future<void> completeGoal(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.isActive = false;
      await updateGoal(goal);
    }
  }

  // Get primary active goal (no-spend challenge)
  Goal? getPrimaryNoSpendGoal() {
    try {
      return _goalsBox.values.firstWhere((g) => g.type == 'noSpendChallenge' && g.isActive);
    } catch (e) {
      return null;
    }
  }

  // Clear all goals
  Future<void> clearAll() async {
    await _goalsBox.clear();
  }

  // Get goal count
  int getGoalCount() {
    return _goalsBox.length;
  }
}
