import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/features/ai_photo_analysis/domain/entity/food_analysis_entity.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_bloc.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_event.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/bloc/ai_photo_state.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/widgets/food_item_card.dart';
import 'package:opennutritracker/features/ai_photo_analysis/presentation/widgets/nutrition_summary_card.dart';

/// Screen showing AI analysis results
class AnalysisResultScreen extends StatefulWidget {
  final String imagePath;

  const AnalysisResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  @override
  void initState() {
    super.initState();
    // Start analysis when screen loads
    context.read<AIPhotoBloc>().add(
          AnalyzePhotoFromPath(imagePath: widget.imagePath),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
        centerTitle: true,
      ),
      body: BlocConsumer<AIPhotoBloc, AIPhotoState>(
        listener: (context, state) {
          if (state is AIPhotoSaved) {
            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Food logged successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to home
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AIPhotoError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Details',
                  textColor: Colors.white,
                  onPressed: () {
                    _showErrorDialog(state.message, state.technicalDetails);
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AIPhotoAnalyzing) {
            return _buildAnalyzingView(state.progressMessage);
          } else if (state is AIPhotoAnalyzed) {
            return _buildResultView(state.analysis);
          } else if (state is AIPhotoSaving) {
            return _buildSavingView(state.analysis);
          } else if (state is AIPhotoError) {
            return _buildErrorView(state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildAnalyzingView(String? progressMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Show the captured image
          Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(widget.imagePath),
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 32),

          const CircularProgressIndicator(),

          const SizedBox(height: 24),

          Text(
            progressMessage ?? 'Analyzing your food...',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'This may take a few seconds',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(FoodAnalysisEntity analysis) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nutrition summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NutritionSummaryCard(analysis: analysis),
          ),

          const SizedBox(height: 16),

          // Food items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Detected Foods',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analysis.foods.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return FoodItemCard(
                food: analysis.foods[index],
                index: index,
              );
            },
          ),

          const SizedBox(height: 16),

          // Notes if available
          if (analysis.notes != null && analysis.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Notes',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Confirm button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton(
              onPressed: () => _confirmAndSave(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Diary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSavingView(FoodAnalysisEntity analysis) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Saving to your diary...'),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),

            const SizedBox(height: 24),

            Text(
              'Analysis Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                // Retry analysis
                context.read<AIPhotoBloc>().add(
                      AnalyzePhotoFromPath(imagePath: widget.imagePath),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAndSave() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Meal Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMealTypeButton(dialogContext, 'Breakfast', Icons.wb_sunny),
            _buildMealTypeButton(dialogContext, 'Lunch', Icons.restaurant),
            _buildMealTypeButton(dialogContext, 'Dinner', Icons.dinner_dining),
            _buildMealTypeButton(dialogContext, 'Snack', Icons.cookie),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeButton(
    BuildContext dialogContext,
    String mealType,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(dialogContext);
          context.read<AIPhotoBloc>().add(
                ConfirmAnalysis(
                  mealTime: DateTime.now(),
                  mealType: mealType.toLowerCase(),
                ),
              );
        },
        icon: Icon(icon),
        label: Text(mealType),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  void _showErrorDialog(String message, String? technicalDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (technicalDetails != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Technical Details:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  technicalDetails,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
