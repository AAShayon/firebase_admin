import 'package:firebase_admin/app/features/dashboard/domain/usecases/create_public_notification_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_dashboard_stats_use_case.dart';


final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((ref) {
  return locator<GetDashboardStatsUseCase>();
});

final createPublicNotificationUseCaseProvider = Provider<CreatePublicNotificationUseCase>((ref) {
  return locator<CreatePublicNotificationUseCase>();
});