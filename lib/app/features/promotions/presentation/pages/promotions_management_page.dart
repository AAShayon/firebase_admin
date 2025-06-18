// import 'package:firebase_admin/app/features/promotions/presentation/pages/create_promotion_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// import '../providers/promotion_providers.dart';
//
// class PromotionsManagementPage extends ConsumerWidget {
//   const PromotionsManagementPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final promotionsAsync = ref.watch(allPromotionsStreamProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Promotions'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_circle_outline), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePromotionPage())); },
//             // onPressed: () => context.pushNamed(AppRoutes.createPromotion),
//           ),
//         ],
//       ),
//       body: promotionsAsync.when(
//         data: (promos) => ListView.builder(
//           itemCount: promos.length,
//           itemBuilder: (context, index) {
//             final promo = promos[index];
//             final bool isActive = promo.isActive;
//             return Card(
//               margin: const EdgeInsets.all(8),
//               child: ListTile(
//                 leading: CircleAvatar(child: Icon(isActive ? Icons.check_circle : Icons.pause_circle, color: isActive ? Colors.green : Colors.orange)),
//                 title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text('Code: ${promo.couponCode ?? "N/A"}\nExpires: ${DateFormat.yMd().format(promo.endDate)}'),
//                 trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () { /* Navigate to edit page */ }),
//               ),
//             );
//           },
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(child: Text('Error: $e')),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_router.dart';
import '../../domain/entities/promotion_entity.dart';
import '../providers/promotion_notifier_provider.dart';
import '../providers/promotion_providers.dart';
import '../providers/promotion_state.dart';

class PromotionsManagementPage extends ConsumerWidget {
  const PromotionsManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotionsAsync = ref.watch(allPromotionsStreamProvider);

    // Listen for success/error messages from the notifier
    ref.listen<PromotionState>(promotionNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          // Refresh the list after a successful action
          ref.invalidate(allPromotionsStreamProvider);
        },
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
        ),
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Promotions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add New Promotion',
            onPressed: () => context.pushNamed(AppRoutes.createPromotion),
          ),
        ],
      ),
      body: promotionsAsync.when(
        data: (promos) {
          if (promos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No promotions found.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(AppRoutes.createPromotion),
                    child: const Text('Create your first promotion'),
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allPromotionsStreamProvider),
            child: ListView.builder(
              itemCount: promos.length,
              itemBuilder: (context, index) {
                final promo = promos[index];
                final bool isActive = promo.isActive;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive ? Colors.green.shade100 : Colors.orange.shade100,
                      child: Icon(
                        isActive ? Icons.check_circle : Icons.pause_circle_filled,
                        color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                    title: Text(promo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Code: ${promo.couponCode ?? "N/A"}\nExpires: ${DateFormat.yMd().format(promo.endDate)}'),
                    isThreeLine: true,
                    // --- THIS IS THE NEW ACTION MENU ---
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Navigate to the create/edit page, passing the promotion object.
                          context.pushNamed(AppRoutes.createPromotion, extra: promo);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, ref, promo);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit')),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete')),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // --- HELPER METHOD FOR DELETE CONFIRMATION ---
  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, PromotionEntity promo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Promotion?'),
        content: Text('Are you sure you want to delete the "${promo.title}" promotion? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(promotionNotifierProvider.notifier).deletePromotion(promo.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          )
        ],
      ),
    );
  }
}