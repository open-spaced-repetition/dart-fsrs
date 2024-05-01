// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardImpl _$$CardImplFromJson(Map<String, dynamic> json) => _$CardImpl(
      DateTime.parse(json['due'] as String),
      DateTime.parse(json['lastReview'] as String),
      (json['stability'] as num?)?.toDouble() ?? 0,
      (json['difficulty'] as num?)?.toDouble() ?? 0,
      (json['elapsedDays'] as num?)?.toInt() ?? 0,
      (json['scheduledDays'] as num?)?.toInt() ?? 0,
      (json['reps'] as num?)?.toInt() ?? 0,
      (json['lapses'] as num?)?.toInt() ?? 0,
      $enumDecodeNullable(_$StateEnumMap, json['state']) ?? State.newState,
    );

Map<String, dynamic> _$$CardImplToJson(_$CardImpl instance) =>
    <String, dynamic>{
      'due': instance.due.toIso8601String(),
      'lastReview': instance.lastReview.toIso8601String(),
      'stability': instance.stability,
      'difficulty': instance.difficulty,
      'elapsedDays': instance.elapsedDays,
      'scheduledDays': instance.scheduledDays,
      'reps': instance.reps,
      'lapses': instance.lapses,
      'state': _$StateEnumMap[instance.state]!,
    };

const _$StateEnumMap = {
  State.newState: 'newState',
  State.learning: 'learning',
  State.review: 'review',
  State.relearning: 'relearning',
};
