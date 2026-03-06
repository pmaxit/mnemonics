// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VocabularyWord _$VocabularyWordFromJson(Map<String, dynamic> json) {
  return _VocabularyWord.fromJson(json);
}

/// @nodoc
mixin _$VocabularyWord {
  String get word => throw _privateConstructorUsedError;
  String get meaning => throw _privateConstructorUsedError;
  String get mnemonic => throw _privateConstructorUsedError;
  String? get aiMnemonic => throw _privateConstructorUsedError;
  String? get aiInsights => throw _privateConstructorUsedError;
  @JsonKey(name: 'imageUrl')
  String? get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'videoUrl')
  String? get video => throw _privateConstructorUsedError;
  String get example => throw _privateConstructorUsedError;
  List<String> get synonyms => throw _privateConstructorUsedError;
  List<String> get antonyms => throw _privateConstructorUsedError;
  WordDifficulty get difficulty => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  List<String> get setIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VocabularyWordCopyWith<VocabularyWord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabularyWordCopyWith<$Res> {
  factory $VocabularyWordCopyWith(
          VocabularyWord value, $Res Function(VocabularyWord) then) =
      _$VocabularyWordCopyWithImpl<$Res, VocabularyWord>;
  @useResult
  $Res call(
      {String word,
      String meaning,
      String mnemonic,
      String? aiMnemonic,
      String? aiInsights,
      @JsonKey(name: 'imageUrl') String? image,
      @JsonKey(name: 'videoUrl') String? video,
      String example,
      List<String> synonyms,
      List<String> antonyms,
      WordDifficulty difficulty,
      String category,
      List<String> setIds});
}

/// @nodoc
class _$VocabularyWordCopyWithImpl<$Res, $Val extends VocabularyWord>
    implements $VocabularyWordCopyWith<$Res> {
  _$VocabularyWordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? meaning = null,
    Object? mnemonic = null,
    Object? aiMnemonic = freezed,
    Object? aiInsights = freezed,
    Object? image = freezed,
    Object? video = freezed,
    Object? example = null,
    Object? synonyms = null,
    Object? antonyms = null,
    Object? difficulty = null,
    Object? category = null,
    Object? setIds = null,
  }) {
    return _then(_value.copyWith(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      aiMnemonic: freezed == aiMnemonic
          ? _value.aiMnemonic
          : aiMnemonic // ignore: cast_nullable_to_non_nullable
              as String?,
      aiInsights: freezed == aiInsights
          ? _value.aiInsights
          : aiInsights // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as String?,
      example: null == example
          ? _value.example
          : example // ignore: cast_nullable_to_non_nullable
              as String,
      synonyms: null == synonyms
          ? _value.synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      antonyms: null == antonyms
          ? _value.antonyms
          : antonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      setIds: null == setIds
          ? _value.setIds
          : setIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VocabularyWordImplCopyWith<$Res>
    implements $VocabularyWordCopyWith<$Res> {
  factory _$$VocabularyWordImplCopyWith(_$VocabularyWordImpl value,
          $Res Function(_$VocabularyWordImpl) then) =
      __$$VocabularyWordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String word,
      String meaning,
      String mnemonic,
      String? aiMnemonic,
      String? aiInsights,
      @JsonKey(name: 'imageUrl') String? image,
      @JsonKey(name: 'videoUrl') String? video,
      String example,
      List<String> synonyms,
      List<String> antonyms,
      WordDifficulty difficulty,
      String category,
      List<String> setIds});
}

/// @nodoc
class __$$VocabularyWordImplCopyWithImpl<$Res>
    extends _$VocabularyWordCopyWithImpl<$Res, _$VocabularyWordImpl>
    implements _$$VocabularyWordImplCopyWith<$Res> {
  __$$VocabularyWordImplCopyWithImpl(
      _$VocabularyWordImpl _value, $Res Function(_$VocabularyWordImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? meaning = null,
    Object? mnemonic = null,
    Object? aiMnemonic = freezed,
    Object? aiInsights = freezed,
    Object? image = freezed,
    Object? video = freezed,
    Object? example = null,
    Object? synonyms = null,
    Object? antonyms = null,
    Object? difficulty = null,
    Object? category = null,
    Object? setIds = null,
  }) {
    return _then(_$VocabularyWordImpl(
      word: null == word
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _value.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      aiMnemonic: freezed == aiMnemonic
          ? _value.aiMnemonic
          : aiMnemonic // ignore: cast_nullable_to_non_nullable
              as String?,
      aiInsights: freezed == aiInsights
          ? _value.aiInsights
          : aiInsights // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      video: freezed == video
          ? _value.video
          : video // ignore: cast_nullable_to_non_nullable
              as String?,
      example: null == example
          ? _value.example
          : example // ignore: cast_nullable_to_non_nullable
              as String,
      synonyms: null == synonyms
          ? _value._synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      antonyms: null == antonyms
          ? _value._antonyms
          : antonyms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WordDifficulty,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      setIds: null == setIds
          ? _value._setIds
          : setIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VocabularyWordImpl implements _VocabularyWord {
  const _$VocabularyWordImpl(
      {required this.word,
      required this.meaning,
      required this.mnemonic,
      this.aiMnemonic,
      this.aiInsights,
      @JsonKey(name: 'imageUrl') this.image,
      @JsonKey(name: 'videoUrl') this.video,
      required this.example,
      required final List<String> synonyms,
      required final List<String> antonyms,
      required this.difficulty,
      required this.category,
      final List<String> setIds = const <String>[]})
      : _synonyms = synonyms,
        _antonyms = antonyms,
        _setIds = setIds;

  factory _$VocabularyWordImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabularyWordImplFromJson(json);

  @override
  final String word;
  @override
  final String meaning;
  @override
  final String mnemonic;
  @override
  final String? aiMnemonic;
  @override
  final String? aiInsights;
  @override
  @JsonKey(name: 'imageUrl')
  final String? image;
  @override
  @JsonKey(name: 'videoUrl')
  final String? video;
  @override
  final String example;
  final List<String> _synonyms;
  @override
  List<String> get synonyms {
    if (_synonyms is EqualUnmodifiableListView) return _synonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_synonyms);
  }

  final List<String> _antonyms;
  @override
  List<String> get antonyms {
    if (_antonyms is EqualUnmodifiableListView) return _antonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_antonyms);
  }

  @override
  final WordDifficulty difficulty;
  @override
  final String category;
  final List<String> _setIds;
  @override
  @JsonKey()
  List<String> get setIds {
    if (_setIds is EqualUnmodifiableListView) return _setIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_setIds);
  }

  @override
  String toString() {
    return 'VocabularyWord(word: $word, meaning: $meaning, mnemonic: $mnemonic, aiMnemonic: $aiMnemonic, aiInsights: $aiInsights, image: $image, video: $video, example: $example, synonyms: $synonyms, antonyms: $antonyms, difficulty: $difficulty, category: $category, setIds: $setIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabularyWordImpl &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.mnemonic, mnemonic) ||
                other.mnemonic == mnemonic) &&
            (identical(other.aiMnemonic, aiMnemonic) ||
                other.aiMnemonic == aiMnemonic) &&
            (identical(other.aiInsights, aiInsights) ||
                other.aiInsights == aiInsights) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.video, video) || other.video == video) &&
            (identical(other.example, example) || other.example == example) &&
            const DeepCollectionEquality().equals(other._synonyms, _synonyms) &&
            const DeepCollectionEquality().equals(other._antonyms, _antonyms) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._setIds, _setIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      word,
      meaning,
      mnemonic,
      aiMnemonic,
      aiInsights,
      image,
      video,
      example,
      const DeepCollectionEquality().hash(_synonyms),
      const DeepCollectionEquality().hash(_antonyms),
      difficulty,
      category,
      const DeepCollectionEquality().hash(_setIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabularyWordImplCopyWith<_$VocabularyWordImpl> get copyWith =>
      __$$VocabularyWordImplCopyWithImpl<_$VocabularyWordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabularyWordImplToJson(
      this,
    );
  }
}

abstract class _VocabularyWord implements VocabularyWord {
  const factory _VocabularyWord(
      {required final String word,
      required final String meaning,
      required final String mnemonic,
      final String? aiMnemonic,
      final String? aiInsights,
      @JsonKey(name: 'imageUrl') final String? image,
      @JsonKey(name: 'videoUrl') final String? video,
      required final String example,
      required final List<String> synonyms,
      required final List<String> antonyms,
      required final WordDifficulty difficulty,
      required final String category,
      final List<String> setIds}) = _$VocabularyWordImpl;

  factory _VocabularyWord.fromJson(Map<String, dynamic> json) =
      _$VocabularyWordImpl.fromJson;

  @override
  String get word;
  @override
  String get meaning;
  @override
  String get mnemonic;
  @override
  String? get aiMnemonic;
  @override
  String? get aiInsights;
  @override
  @JsonKey(name: 'imageUrl')
  String? get image;
  @override
  @JsonKey(name: 'videoUrl')
  String? get video;
  @override
  String get example;
  @override
  List<String> get synonyms;
  @override
  List<String> get antonyms;
  @override
  WordDifficulty get difficulty;
  @override
  String get category;
  @override
  List<String> get setIds;
  @override
  @JsonKey(ignore: true)
  _$$VocabularyWordImplCopyWith<_$VocabularyWordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
