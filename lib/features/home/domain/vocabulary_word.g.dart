// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VocabularyWordImpl _$$VocabularyWordImplFromJson(Map<String, dynamic> json) =>
    _$VocabularyWordImpl(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      mnemonic: json['mnemonic'] as String,
      aiMnemonic: json['aiMnemonic'] as String?,
      aiInsights: json['aiInsights'] as String?,
      image: json['image'] as String?,
      video: json['video'] as String?,
      example: json['example'] as String,
      synonyms:
          (json['synonyms'] as List<dynamic>).map((e) => e as String).toList(),
      antonyms:
          (json['antonyms'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: $enumDecode(_$WordDifficultyEnumMap, json['difficulty']),
      category: json['category'] as String,
      setIds: (json['setIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$$VocabularyWordImplToJson(
        _$VocabularyWordImpl instance) =>
    <String, dynamic>{
      'word': instance.word,
      'meaning': instance.meaning,
      'mnemonic': instance.mnemonic,
      'aiMnemonic': instance.aiMnemonic,
      'aiInsights': instance.aiInsights,
      'image': instance.image,
      'video': instance.video,
      'example': instance.example,
      'synonyms': instance.synonyms,
      'antonyms': instance.antonyms,
      'difficulty': _$WordDifficultyEnumMap[instance.difficulty]!,
      'category': instance.category,
      'setIds': instance.setIds,
    };

const _$WordDifficultyEnumMap = {
  WordDifficulty.basic: 'basic',
  WordDifficulty.intermediate: 'intermediate',
  WordDifficulty.advanced: 'advanced',
};
