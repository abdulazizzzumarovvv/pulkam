import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulkam/features/hisoblar/hisoblar.dart';
import 'package:pulkam/main_screen/logic/cubit.dart';
import 'package:pulkam/main_screen/logic/state.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MainScreenCubit, MainScreenState>(
        builder: (context, state) {
          switch (state.selectedIndex) {
            case 0:
              return Hisoblar(); // Replace with your actual body content for the first tab
            case 1:
              return Container(); // Replace with your actual body content for the second tab
            case 2:
              return Container(); // Replace with your actual body content for the third tab
            case 3:
              return Container(); // Replace with your actual body content for the fourth tab
            case 4:
              return Container(); // Replace with your actual body content for the fifth tab
            default:
              return Container(); // Replace with your actual body content
          }
        }
      ),
      bottomNavigationBar: BlocBuilder<MainScreenCubit, MainScreenState>(
        builder: (context, state) {
          return NavigationBar(destinations:  const [
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Hisoblar', selectedIcon: Icon(Icons.account_balance_wallet),),
            NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Kategoriya', selectedIcon: Icon(Icons.category)),
            NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Ai Analiz', selectedIcon: Icon(Icons.auto_awesome)),
            NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Statistika', selectedIcon: Icon(Icons.bar_chart)),
            NavigationDestination(icon: Icon(Icons.widgets_outlined), label: 'Ma\'lumotlar', selectedIcon: Icon(Icons.widgets)),
          ],
          selectedIndex: state.selectedIndex,
          onDestinationSelected: (value) => context.read<MainScreenCubit>().setSelectedIndex(value),);
        }
      ),
    );
  }
}