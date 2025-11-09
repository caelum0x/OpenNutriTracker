import 'package:json_annotation/json_annotation.dart';

part 'openrouter_response_dto.g.dart';

/// DTO for OpenRouter API response
@JsonSerializable()
class OpenRouterResponseDTO {
  final String id;
  final String model;
  final List<ChoiceDTO> choices;
  final UsageDTO? usage;

  OpenRouterResponseDTO({
    required this.id,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory OpenRouterResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterResponseDTOToJson(this);
}

@JsonSerializable()
class ChoiceDTO {
  final int index;
  final MessageDTO message;
  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  ChoiceDTO({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory ChoiceDTO.fromJson(Map<String, dynamic> json) =>
      _$ChoiceDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ChoiceDTOToJson(this);
}

@JsonSerializable()
class MessageDTO {
  final String role;
  final String content;

  MessageDTO({
    required this.role,
    required this.content,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) =>
      _$MessageDTOFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDTOToJson(this);
}

@JsonSerializable()
class UsageDTO {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  UsageDTO({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory UsageDTO.fromJson(Map<String, dynamic> json) =>
      _$UsageDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UsageDTOToJson(this);
}
