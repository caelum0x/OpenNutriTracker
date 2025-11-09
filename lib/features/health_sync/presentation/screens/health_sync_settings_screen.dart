import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/health_sync/presentation/bloc/health_sync_bloc.dart';
import 'package:opennutritracker/features/health_sync/presentation/bloc/health_sync_event.dart';
import 'package:opennutritracker/features/health_sync/presentation/bloc/health_sync_state.dart';

/// Screen for configuring health sync settings
class HealthSyncSettingsScreen extends StatelessWidget {
  const HealthSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthAppName = Platform.isIOS ? 'Apple Health' : 'Google Fit';

    return Scaffold(
      appBar: AppBar(
        title: Text('$healthAppName Integration'),
        centerTitle: true,
      ),
      body: BlocConsumer<HealthSyncBloc, HealthSyncState>(
        listener: (context, state) {
          if (state is HealthSyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is HealthSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HealthNotAvailable) {
            return _buildNotAvailableView(context, state.message);
          } else if (state is HealthPermissionsDenied) {
            return _buildPermissionsDeniedView(context, state.message);
          } else if (state is HealthSyncConfigured) {
            return _buildConfiguredView(context, state, healthAppName);
          } else if (state is HealthSyncLoading) {
            return _buildLoadingView(state.message);
          }

          return _buildInitialView(context, healthAppName);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context, String healthAppName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Platform.isIOS ? Icons.favorite : Icons.fitness_center,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),
            Text(
              'Connect to $healthAppName',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sync your nutrition and fitness data with $healthAppName for a complete health overview.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeaturesList(context),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<HealthSyncBloc>().add(
                      const RequestHealthPermissions(),
                    );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Connect Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      'Sync calories burned from workouts',
      'Track weight changes',
      'Share nutrition data',
      'Log water intake',
      'View activity trends',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConfiguredView(
    BuildContext context,
    HealthSyncConfigured state,
    String healthAppName,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    state.isConnected ? Icons.check_circle : Icons.error,
                    color: state.isConnected ? Colors.green : Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isConnected ? 'Connected' : 'Not Connected',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.isConnected
                              ? 'Syncing with $healthAppName'
                              : 'Enable to start syncing',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Health data summary
          if (state.summary != null) _buildHealthSummary(context, state.summary!),

          const SizedBox(height: 24),

          // Sync settings
          Text(
            'Sync Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Enable/Disable main toggle
          Card(
            child: SwitchListTile(
              title: const Text('Enable Health Sync'),
              subtitle: const Text('Sync data with health app'),
              value: state.config.isEnabled,
              onChanged: (enabled) {
                context.read<HealthSyncBloc>().add(
                      ToggleHealthSync(enabled: enabled),
                    );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Individual sync options
          if (state.config.isEnabled) ...[
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Calories Burned'),
                    subtitle: const Text('Import from health app'),
                    value: state.config.syncCaloriesBurned,
                    onChanged: (enabled) {
                      context.read<HealthSyncBloc>().add(
                            ToggleSyncFeature(
                              feature: 'calories_burned',
                              enabled: enabled,
                            ),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Weight'),
                    subtitle: const Text('Two-way sync'),
                    value: state.config.syncWeight,
                    onChanged: (enabled) {
                      context.read<HealthSyncBloc>().add(
                            ToggleSyncFeature(
                              feature: 'weight',
                              enabled: enabled,
                            ),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Water Intake'),
                    subtitle: const Text('Export to health app'),
                    value: state.config.syncWaterIntake,
                    onChanged: (enabled) {
                      context.read<HealthSyncBloc>().add(
                            ToggleSyncFeature(
                              feature: 'water',
                              enabled: enabled,
                            ),
                          );
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Nutrition'),
                    subtitle: const Text('Export meals to health app'),
                    value: state.config.syncNutrition,
                    onChanged: (enabled) {
                      context.read<HealthSyncBloc>().add(
                            ToggleSyncFeature(
                              feature: 'nutrition',
                              enabled: enabled,
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Manual sync button
            ElevatedButton.icon(
              onPressed: state.isSyncing
                  ? null
                  : () {
                      context.read<HealthSyncBloc>().add(const ManualSync());
                    },
              icon: state.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(state.isSyncing ? 'Syncing...' : 'Sync Now'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            if (state.config.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Last synced: ${_formatDateTime(state.config.lastSyncTime!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHealthSummary(BuildContext context, HealthDataSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${summary.caloriesBurned.toInt()}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.directions_walk,
                    label: 'Steps',
                    value: '${summary.steps}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(message),
          ],
        ],
      ),
    );
  }

  Widget _buildNotAvailableView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Not Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsDeniedView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Permissions Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<HealthSyncBloc>().add(
                      const RequestHealthPermissions(),
                    );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
