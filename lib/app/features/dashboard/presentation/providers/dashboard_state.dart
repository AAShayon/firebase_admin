import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.statsLoaded(DashboardStatsEntity stats) = _StatsLoaded;
  const factory DashboardState.notificationSent(String message) = _NotificationSent;
  const factory DashboardState.error(String message) = _Error;
}