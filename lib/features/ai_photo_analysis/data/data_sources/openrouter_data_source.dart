import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/dto/openrouter_request_dto.dart';
import 'package:opennutritracker/features/ai_photo_analysis/data/dto/openrouter_response_dto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Data source for OpenRouter API calls
/// Handles AI vision analysis for food identification
class OpenRouterDataSource {
  static const _baseUrl = 'https://openrouter.ai/api/v1';
  static const _timeoutDuration = Duration(seconds: 30);
  final log = Logger('OpenRouterDataSource');

  final String apiKey;
  final http.Client client;

  OpenRouterDataSource({
    String? apiKey,
    http.Client? client,
  })  : apiKey = apiKey ?? Env.openRouterApiKey,
        client = client ?? http.Client();

  /// Analyzes a food image and returns nutritional information
  ///
  /// [imageBase64] - Base64 encoded image string
  /// [model] - Optional model to use (defaults to GPT-4 Vision)
  /// [includeVolumeData] - Whether to request volume/portion size estimation
  Future<OpenRouterResponseDTO> analyzeFoodImage({
    required String imageBase64,
    String model = 'openai/gpt-4-vision-preview',
    bool includeVolumeData = false,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/completions');

      final request = OpenRouterRequestDTO(
        model: model,
        messages: [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _buildPrompt(includeVolumeData),
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$imageBase64',
                },
              },
            ],
          },
        ],
      );

      log.fine('Sending food analysis request to OpenRouter');

      final response = await client
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://opennutritracker.app',
              'X-Title': 'OpenNutriTracker',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final responseDto = OpenRouterResponseDTO.fromJson(
          jsonDecode(response.body),
        );
        log.fine('Successfully received food analysis from OpenRouter');
        return responseDto;
      } else {
        log.warning('OpenRouter API call failed: ${response.statusCode}');
        log.warning('Response body: ${response.body}');
        throw HttpException(
          'OpenRouter API failed with status ${response.statusCode}',
        );
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while analyzing food image: $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      rethrow;
    }
  }

  /// Gets AI coaching suggestions based on user's nutrition data
  ///
  /// [dailyIntake] - User's current daily intake
  /// [goals] - User's nutritional goals
  /// [context] - Additional context (e.g., time of day, recent meals)
  Future<String> getCoachingSuggestions({
    required Map<String, dynamic> dailyIntake,
    required Map<String, dynamic> goals,
    String? context,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/chat/completions');

      final prompt = _buildCoachingPrompt(dailyIntake, goals, context);

      final request = {
        'model': 'anthropic/claude-3.5-sonnet',
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          },
        ],
      };

      log.fine('Requesting AI coaching suggestions');

      final response = await client
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://opennutritracker.app',
              'X-Title': 'OpenNutriTracker',
            },
            body: jsonEncode(request),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final suggestion = jsonResponse['choices'][0]['message']['content'];
        log.fine('Successfully received coaching suggestions');
        return suggestion;
      } else {
        log.warning('Coaching API call failed: ${response.statusCode}');
        throw HttpException(
          'Coaching API failed with status ${response.statusCode}',
        );
      }
    } catch (exception, stacktrace) {
      log.severe('Exception while getting coaching suggestions: $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      rethrow;
    }
  }

  String _buildPrompt(bool includeVolumeData) {
    final basePrompt = '''
Analyze this food image and provide detailed nutritional information in JSON format.

Identify all food items visible in the image. For each item, estimate:
1. Food name and type
2. Serving size (in grams or ml)
3. Calories
4. Macronutrients (protein, carbs, fat in grams)
5. Confidence level (0-100)
''';

    final volumePrompt = includeVolumeData
        ? '''
6. Estimated volume (if possible based on visual cues)
7. Portion size relative to common objects
'''
        : '';

    return '''$basePrompt$volumePrompt

Return the response in this exact JSON format:
{
  "foods": [
    {
      "name": "string",
      "servingSize": number,
      "servingUnit": "g" or "ml",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number,
      "confidence": number
    }
  ],
  "totalCalories": number,
  "totalProtein": number,
  "totalCarbs": number,
  "totalFat": number,
  "notes": "any additional observations"
}

If you cannot identify the food with confidence, set confidence below 50 and provide your best estimate with a note explaining the uncertainty.
''';
  }

  String _buildCoachingPrompt(
    Map<String, dynamic> dailyIntake,
    Map<String, dynamic> goals,
    String? context,
  ) {
    return '''
You are a nutrition coach. Based on the following data, provide personalized suggestions:

Current Daily Intake:
- Calories: ${dailyIntake['calories']}/${goals['calories']}
- Protein: ${dailyIntake['protein']}g/${goals['protein']}g
- Carbs: ${dailyIntake['carbs']}g/${goals['carbs']}g
- Fat: ${dailyIntake['fat']}g/${goals['fat']}g

${context != null ? 'Context: $context\n' : ''}

Provide 2-3 actionable, encouraging suggestions to help them reach their goals today.
Keep it concise, positive, and practical. Focus on:
1. What they're doing well
2. Specific food suggestions if they're low on any macros
3. Timing suggestions if relevant

Respond in a friendly, motivating tone in 2-3 short paragraphs.
''';
  }
}
