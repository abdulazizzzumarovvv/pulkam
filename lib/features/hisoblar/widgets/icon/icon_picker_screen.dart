// icon_picker_screen.dart
import 'package:flutter/material.dart';

class IconPickerScreen extends StatefulWidget {
  final IconData initialIcon;
  final Color? accentColor;
  const IconPickerScreen({super.key, required this.initialIcon, this.accentColor});

  // _categories dan tashqarida, class ichida
  static IconData randomIcon() {
    final all = [
      Icons.star_outline,
      Icons.favorite_outline,
      Icons.home_outlined,
      Icons.work_outline,
      Icons.flag_outlined,
      Icons.bookmark_outline,
      Icons.calendar_today_outlined,
      Icons.alarm,
      Icons.account_balance_wallet_outlined,
      Icons.credit_card_outlined,
      Icons.money,
      Icons.savings_outlined,
      Icons.restaurant_outlined,
      Icons.fastfood_outlined,
      Icons.coffee_outlined,
      Icons.directions_car_outlined,
      Icons.flight_outlined,
      Icons.fitness_center_outlined,
      Icons.school_outlined,
      Icons.music_note_outlined,
    ]..shuffle();
    return all.first;
  }

  @override
  State<IconPickerScreen> createState() => _IconPickerScreenState();
}

class _IconPickerScreenState extends State<IconPickerScreen> {
  late IconData _selected;

  final Map<String, List<IconData>> _categories = {
    'Umumiy': [
      Icons.star_outline,
      Icons.favorite_outline,
      Icons.home_outlined,
      Icons.work_outline,
      Icons.flag_outlined,
      Icons.bookmark_outline,
      Icons.calendar_today_outlined,
      Icons.alarm,
      Icons.settings_outlined,
      Icons.notifications_outlined,
    ],
    'Moliya': [
      Icons.account_balance_wallet_outlined,
      Icons.credit_card_outlined,
      Icons.money,
      Icons.savings_outlined,
      Icons.attach_money,
      Icons.currency_exchange,
      Icons.payment_outlined,
      Icons.receipt_outlined,
      Icons.trending_up,
      Icons.bar_chart,
    ],
    'Oziq-ovqat': [
      Icons.restaurant_outlined,
      Icons.fastfood_outlined,
      Icons.coffee_outlined,
      Icons.local_pizza_outlined,
      Icons.cake_outlined,
      Icons.lunch_dining,
      Icons.dinner_dining,
      Icons.local_cafe_outlined,
      Icons.wine_bar_outlined,
      Icons.bakery_dining,
    ],
    'Transport': [
      Icons.directions_car_outlined,
      Icons.flight_outlined,
      Icons.directions_bus_outlined,
      Icons.train_outlined,
      Icons.directions_bike_outlined,
      Icons.local_taxi_outlined,
      Icons.motorcycle_outlined,
      Icons.electric_car_outlined,
      Icons.directions_walk,
      Icons.local_shipping_outlined,
    ],
    'Salomatlik': [
      Icons.fitness_center_outlined,
      Icons.medical_services_outlined,
      Icons.local_hospital_outlined,
      Icons.sports_gymnastics,
      Icons.self_improvement,
      Icons.spa_outlined,
      Icons.healing_outlined,
      Icons.monitor_heart_outlined,
      Icons.medication_outlined,
      Icons.psychology_outlined,
    ],
    'Ta\'lim': [
      Icons.school_outlined,
      Icons.menu_book_outlined,
      Icons.science_outlined,
      Icons.computer_outlined,
      Icons.brush_outlined,
      Icons.music_note_outlined,
      Icons.sports_soccer_outlined,
      Icons.videogame_asset_outlined,
      Icons.language_outlined,
      Icons.calculate_outlined,
    ],
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.initialIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon tanlang'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _categories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kategoriya nomi
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[700])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[700])),
                  ],
                ),
              ),
              // Iconlar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: entry.value.length,
                itemBuilder: (_, i) {
                  final icon = entry.value[i];
                  final isSelected = icon == _selected;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : Border.all(color: Colors.black, width: 2),
                      ),
                      child: Icon(icon, color: Colors.black, size: 28),
                    ),
                  );
                },
              ),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _selected),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Saqlash'),
        ),
      ),
    );
  }
}