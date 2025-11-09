import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/health_sync/domain/entity/health_sync_entity.dart';

/// States for Health Sync BLoC
abstract class HealthSyncState extends Equatable {
  const HealthSyncState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HealthSyncInitial extends HealthSyncState {
  const HealthSyncInitial();
}

/// Loading state
class HealthSyncLoading extends HealthSyncState {
  final String? message;

  const HealthSyncLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Health sync configured and ready
class HealthSyncConfigured extends HealthSyncState {
  final HealthSyncConfigEntity config;
  final HealthSyncStatus status;
  final HealthDataSummary? summary;

  const HealthSyncConfigured({
    required this.config,
    required this.status,
    this.summary,
  });

  bool get isConnected => status == HealthSyncStatus.connected;
  bool get isSyncing => status == HealthSyncStatus.syncing;

  @override
  List<Object?> get props => [config, status, summary];
}

/// Permissions not granted
class HealthPermissionsDenied extends HealthSyncState {
  final String message;

  const HealthPermissionsDenied({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Health not available
class HealthNotAvailable extends HealthSyncState {
  final String message;

  const HealthNotAvailable({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Syncing in progress
class HealthSyncing extends HealthSyncState {
  final String progressMessage;

  const HealthSyncing({required this.progressMessage});

  @override
  List<Object?> get props => [progressMessage];
}

/// Sync completed successfully
class HealthSyncSuccess extends HealthSyncState {
  final String message;
  final HealthDataSummary? summary;

  const HealthSyncSuccess({
    required this.message,
    this.summary,
  });

  @override
  List<Object?> get props => [message, summary];
}

/// Error state
class HealthSyncError extends HealthSyncState {
  final String message;
  final String? technicalDetails;

  const HealthSyncError({
    required this.message,
    this.technicalDetails,
  });

  @override
  List<Object?> get props => [message, technicalDetails];
}
