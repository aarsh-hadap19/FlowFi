import 'package:flutter/material.dart';
import 'package:flowfi/constants/app_theme.dart';
import 'package:flowfi/screens/home_screen.dart';
import 'package:flowfi/screens/transactions_screen.dart';
import 'package:flowfi/screens/goals_screen.dart';
import 'package:flowfi/screens/insights_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(label: 'Home', icon: Icons.home_rounded, page: const HomeScreen()),
    _NavItem(label: 'Transactions', icon: Icons.receipt_long_rounded, page: const TransactionsScreen()),
    _NavItem(label: 'Goals', icon: Icons.flag_rounded, page: const GoalsScreenWidget()),
    _NavItem(label: 'Insights', icon: Icons.insights_rounded, page: const InsightsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navItems[_selectedIndex].page,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.caption,
          items: _navItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;

  _NavItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}
