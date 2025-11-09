import 'package:json_annotation/json_annotation.dart';

part 'openrouter_request_dto.g.dart';

/// DTO for OpenRouter API request
@JsonSerializable()
class OpenRouterRequestDTO {
  final String model;
  final List<Map<String, dynamic>> messages;
  final double? temperature;
  @JsonKey(name: 'max_tokens')
  final int? maxTokens;

  OpenRouterRequestDTO({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 1000,
  });

  factory OpenRouterRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterRequestDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterRequestDTOToJson(this);
}
