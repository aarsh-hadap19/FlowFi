import 'package:hive_flutter/hive_flutter.dart';
import 'package:flowfi/models/goal.dart';
import 'package:flowfi/services/hive_service.dart';

class GoalService {
  late Box<Goal> _goalsBox;

  GoalService() {
    _goalsBox = HiveService.getGoalsBox();
  }

  Future<void> addGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  List<Goal> getAllGoals() {
    return _goalsBox.values.toList();
  }

  List<Goal> getActiveGoals() {
    return _goalsBox.values.where((g) => g.isActive).toList();
  }

  // Get goals as a stream
  Stream<List<Goal>> watchGoals() async* {
    // Emit current state first
    yield getAllGoals();
    
    // Then listen for changes
    await for (final _ in _goalsBox.watch()) {
      yield getAllGoals();
    }
  }

  Goal? getGoal(String id) {
    return _goalsBox.get(id);
  }

  Future<void> updateGoal(Goal goal) async {
    await _goalsBox.put(goal.id, goal);
  }

  Future<void> deleteGoal(String id) async {
    await _goalsBox.delete(id);
  }

  List<Goal> getGoalsByType(String type) {
    return _goalsBox.values.where((g) => g.type == type).toList();
  }

  Future<void> incrementGoalStreak(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.currentDays = goal.currentDays + 1;
      await updateGoal(goal);
    }
  }

  Future<void> resetGoalStreak(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.currentDays = 0;
      goal.lastResetDate = DateTime.now();
      await updateGoal(goal);
    }
  }

  Future<void> completeGoal(String goalId) async {
    final goal = getGoal(goalId);
    if (goal != null) {
      goal.isActive = false;
      await updateGoal(goal);
    }
  }

  Goal? getPrimaryNoSpendGoal() {
    try {
      return _goalsBox.values.firstWhere((g) => g.type == 'noSpendChallenge' && g.isActive);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _goalsBox.clear();
  }

  int getGoalCount() {
    return _goalsBox.length;
  }
}
