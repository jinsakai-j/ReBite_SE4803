import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories = const ['Semua', 'Makanan', 'Minuman', 'Roti'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => onSelected(category),
              selectedColor: const Color(0xFF176B45),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD9E3DC)),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF242B26),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
