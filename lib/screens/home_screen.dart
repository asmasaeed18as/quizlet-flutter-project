import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'quiz_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      title: 'Grammar',
      imagePath: 'assets/images/grammar.png',
      subtitle: 'Sentence structure, tenses, and clarity',
      icon: Icons.menu_book_rounded,
    ),
    _CategoryItem(
      title: 'Maths',
      imagePath: 'assets/images/maths.png',
      subtitle: 'Equations, arithmetic, and problem solving',
      icon: Icons.calculate_rounded,
    ),
    _CategoryItem(
      title: 'Physics',
      imagePath: 'assets/images/physics.png',
      subtitle: 'Force, motion, energy, and experiments',
      icon: Icons.science_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Quiz',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Practice by category and track your progress instantly.',
                  style: TextStyle(color: Color(0xFF4A5568)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                      return GridView.builder(
                        itemCount: _categories.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: crossAxisCount == 1 ? 1.35 : 1.2,
                        ),
                        itemBuilder: (context, index) {
                          final item = _categories[index];
                          return _CategoryCard(item: item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizListScreen(category: item.title),
          ),
        );
      },
      child: Hero(
        tag: item.title,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330B1B3F),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC0F172A), Color(0x440F172A)],
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(item.icon, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    style: const TextStyle(color: Color(0xFFE2E8F0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final String imagePath;
  final String subtitle;
  final IconData icon;

  const _CategoryItem({
    required this.title,
    required this.imagePath,
    required this.subtitle,
    required this.icon,
  });
}
