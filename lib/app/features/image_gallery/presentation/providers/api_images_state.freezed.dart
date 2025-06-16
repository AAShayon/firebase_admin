// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_images_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ApiImagesState {
  List<GalleryImageEntity> get images => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  bool get hasMore =>
      throw _privateConstructorUsedError; // Assume there's more to load initially
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of ApiImagesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiImagesStateCopyWith<ApiImagesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiImagesStateCopyWith<$Res> {
  factory $ApiImagesStateCopyWith(
    ApiImagesState value,
    $Res Function(ApiImagesState) then,
  ) = _$ApiImagesStateCopyWithImpl<$Res, ApiImagesState>;
  @useResult
  $Res call({
    List<GalleryImageEntity> images,
    int page,
    bool hasMore,
    bool isLoading,
  });
}

/// @nodoc
class _$ApiImagesStateCopyWithImpl<$Res, $Val extends ApiImagesState>
    implements $ApiImagesStateCopyWith<$Res> {
  _$ApiImagesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiImagesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? page = null,
    Object? hasMore = null,
    Object? isLoading = null,
  }) {
    return _then(
      _value.copyWith(
            images:
                null == images
                    ? _value.images
                    : images // ignore: cast_nullable_to_non_nullable
                        as List<GalleryImageEntity>,
            page:
                null == page
                    ? _value.page
                    : page // ignore: cast_nullable_to_non_nullable
                        as int,
            hasMore:
                null == hasMore
                    ? _value.hasMore
                    : hasMore // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiImagesStateImplCopyWith<$Res>
    implements $ApiImagesStateCopyWith<$Res> {
  factory _$$ApiImagesStateImplCopyWith(
    _$ApiImagesStateImpl value,
    $Res Function(_$ApiImagesStateImpl) then,
  ) = __$$ApiImagesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<GalleryImageEntity> images,
    int page,
    bool hasMore,
    bool isLoading,
  });
}

/// @nodoc
class __$$ApiImagesStateImplCopyWithImpl<$Res>
    extends _$ApiImagesStateCopyWithImpl<$Res, _$ApiImagesStateImpl>
    implements _$$ApiImagesStateImplCopyWith<$Res> {
  __$$ApiImagesStateImplCopyWithImpl(
    _$ApiImagesStateImpl _value,
    $Res Function(_$ApiImagesStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiImagesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? page = null,
    Object? hasMore = null,
    Object? isLoading = null,
  }) {
    return _then(
      _$ApiImagesStateImpl(
        images:
            null == images
                ? _value._images
                : images // ignore: cast_nullable_to_non_nullable
                    as List<GalleryImageEntity>,
        page:
            null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                    as int,
        hasMore:
            null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                    as bool,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$ApiImagesStateImpl implements _ApiImagesState {
  const _$ApiImagesStateImpl({
    final List<GalleryImageEntity> images = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
  }) : _images = images;

  final List<GalleryImageEntity> _images;
  @override
  @JsonKey()
  List<GalleryImageEntity> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasMore;
  // Assume there's more to load initially
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'ApiImagesState(images: $images, page: $page, hasMore: $hasMore, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiImagesStateImpl &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_images),
    page,
    hasMore,
    isLoading,
  );

  /// Create a copy of ApiImagesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiImagesStateImplCopyWith<_$ApiImagesStateImpl> get copyWith =>
      __$$ApiImagesStateImplCopyWithImpl<_$ApiImagesStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ApiImagesState implements ApiImagesState {
  const factory _ApiImagesState({
    final List<GalleryImageEntity> images,
    final int page,
    final bool hasMore,
    final bool isLoading,
  }) = _$ApiImagesStateImpl;

  @override
  List<GalleryImageEntity> get images;
  @override
  int get page;
  @override
  bool get hasMore; // Assume there's more to load initially
  @override
  bool get isLoading;

  /// Create a copy of ApiImagesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiImagesStateImplCopyWith<_$ApiImagesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
