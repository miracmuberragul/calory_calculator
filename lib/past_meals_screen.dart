import 'package:calori_app/services/firebase_servise.dart';
import 'package:flutter/material.dart';
import 'package:calori_app/services/daily_tracking_service.dart'; // FoodEntry burada tanımlı
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FoodEntry> _foodEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodEntries();
  }

  Future<void> _loadFoodEntries() async {
    final entries = await FirestoreService.getAllFoodEntries();
    setState(() {
      _foodEntries = entries;
      _isLoading = false;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Yiyecek Kayıtları'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foodEntries.isEmpty
          ? const Center(child: Text('Kayıt bulunamadı.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _foodEntries.length,
              itemBuilder: (context, index) {
                final entry = _foodEntries[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),

                    title: Text(
                      entry.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Kalori: ${entry.calories} kcal'),
                        Text('Protein: ${entry.protein.toStringAsFixed(1)} g'),
                        Text('Yağ: ${entry.fat.toStringAsFixed(1)} g'),
                        Text(
                          'Karbonhidrat: ${entry.carbohydrates.toStringAsFixed(1)} g',
                        ),
                        Text('Tarih: ${_formatDateTime(entry.timestamp)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
