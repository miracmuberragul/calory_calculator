import 'package:calori_app/home_screen.dart';
import 'package:calori_app/past_meals_screen.dart';
import 'package:calori_app/services/daily_tracking_service.dart';
import 'package:calori_app/services/firebase_servise.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Bu kod widget ağacı oluşturulduktan sonra çalışacak
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        // Veri yükleme işlemini async olarak başlat
        await Provider.of<DailyTrackingService>(
          context,
          listen: false,
        ).loadTodayEntries();

        print('Dashboard: Veriler başarıyla yüklendi');
      } catch (e) {
        print('Dashboard: Veri yükleme hatası: $e');
        // Hata durumunda kullanıcıya bilgi verilebilir
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veriler yüklenirken bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    try {
      await Provider.of<DailyTrackingService>(
        context,
        listen: false,
      ).loadTodayEntries();

      print('Dashboard: Veriler yenilendi');
    } catch (e) {
      print('Dashboard: Veri yenileme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Consumer<DailyTrackingService>(
          builder: (context, trackingService, child) {
            // Debug için veri durumunu yazdır
            print(
              'Dashboard Build: isLoading=${trackingService.isLoading}, entries=${trackingService.todayEntries.length}',
            );

            // Yükleme durumu kontrolü
            if (trackingService.isLoading &&
                trackingService.todayEntries.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Veriler yükleniyor...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Pull-to-refresh için gerekli
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildDailySummaryCard(trackingService.dailyNutrition),
                        const SizedBox(height: 20),
                        _buildNutritionProgressCards(trackingService),
                        const SizedBox(height: 20),
                        _buildQuickActions(context),
                        const SizedBox(height: 20),
                        _buildTodayMealsSection(trackingService),
                        // Son öğeden sonra biraz boşluk bırak
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(DailyNutrition nutrition) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEA2AF), Color(0xFFE8919D)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEEA2AF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bugün Tüketilen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${nutrition.totalCalories}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'KALORI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('${nutrition.mealCount}', 'Öğün'),
              _buildMiniStat('${nutrition.totalProtein.toInt()}g', 'Protein'),
              _buildMiniStat('${nutrition.totalFat.toInt()}g', 'Yağ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionProgressCards(DailyTrackingService service) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Kalori',
                service.dailyNutrition.totalCalories,
                DailyTrackingService.dailyCalorieGoal,
                service.calorieProgress,
                const Color(0xFF35738C),
                'kcal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                'Protein',
                service.dailyNutrition.totalProtein.toInt(),
                DailyTrackingService.dailyProteinGoal.toInt(),
                service.proteinProgress,
                const Color(0xFF4CAF50),
                'g',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Yağ',
                service.dailyNutrition.totalFat.toInt(),
                DailyTrackingService.dailyFatGoal.toInt(),
                service.fatProgress,
                const Color(0xFFFF9800),
                'g',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                'Karbonhidrat',
                service.dailyNutrition.totalCarbohydrates.toInt(),
                DailyTrackingService.dailyCarbGoal.toInt(),
                service.carbProgress,
                const Color(0xFF9C27B0),
                'g',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    String title,
    int current,
    int goal,
    double progress,
    Color color,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$current$unit',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hedef: $goal$unit',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hızlı İşlemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF35738C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  'Yemek Ekle',
                  Icons.add_a_photo,
                  const Color(0xFFEEA2AF),
                  () async {
                    print('Dashboard: Yemek Ekle ekranına gidiliyor...');

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );

                    print(
                      'Dashboard: Yemek Ekle ekranından dönüldü. Result: $result',
                    );

                    if (!context.mounted) return;

                    // Her durumda veriyi yenile (yemek eklense de eklenmese de)
                    try {
                      await Provider.of<DailyTrackingService>(
                        context,
                        listen: false,
                      ).loadTodayEntries();

                      print(
                        'Dashboard: Yemek ekleme sonrası veriler yenilendi',
                      );
                    } catch (e) {
                      print(
                        'Dashboard: Yemek ekleme sonrası veri yenileme hatası: $e',
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  'Geçmiş',
                  Icons.history,
                  const Color(0xFF35738C),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMealsSection(DailyTrackingService service) {
    final meals = service.todayEntries;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bugünkü Yemekler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF35738C),
                ),
              ),
              Text(
                '${meals.length} öğün',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (meals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Henüz yemek eklenmedi',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İlk yemeğinizi eklemek için yukarıdaki "Yemek Ekle" butonunu kullanın',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...meals.asMap().entries.map((entry) {
              final index = entry.key;
              final meal = entry.value;
              return _buildMealItem(meal, index, service);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    FoodEntry meal,
    int index,
    DailyTrackingService service,
  ) {
    final timeStr =
        '${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFEEA2AF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fastfood,
              color: Color(0xFFEEA2AF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.foodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$timeStr • ${meal.calories} kcal • P: ${meal.protein.toInt()}g F: ${meal.fat.toInt()}g C: ${meal.carbohydrates.toInt()}g',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              // Silme onayı
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Yemeği Sil'),
                  content: Text(
                    '${meal.foodName} adlı yemeği silmek istediğinizden emin misiniz?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        //deleteFoodEntry
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        FirestoreService.deleteFoodEntry(meal.id);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true) {
                try {
                  await service.removeFoodEntry(index);
                  print('Dashboard: Yemek silindi: ${meal.foodName}');
                } catch (e) {
                  print('Dashboard: Yemek silme hatası: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yemek silinirken bir hata oluştu'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.shade400,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
