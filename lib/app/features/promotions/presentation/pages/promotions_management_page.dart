import 'package:firebase_admin/app/features/promotions/presentation/pages/create_promotion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/promotion_providers.dart';

class PromotionsManagementPage extends ConsumerWidget {
  const PromotionsManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(allPromotionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Promotions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePromotionPage())); },
            // onPressed: () => context.pushNamed(AppRoutes.createPromotion),
          ),
        ],
      ),
      body: promotionsAsync.when(
        data: (promos) => ListView.builder(
          itemCount: promos.length,
          itemBuilder: (context, index) {
            final promo = promos[index];
            final bool isActive = promo.isActive;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(child: Icon(isActive ? Icons.check_circle : Icons.pause_circle, color: isActive ? Colors.green : Colors.orange)),
                title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Code: ${promo.couponCode ?? "N/A"}\nExpires: ${DateFormat.yMd().format(promo.endDate)}'),
                trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () { /* Navigate to edit page */ }),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}