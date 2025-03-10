// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pigpenUserStreamHash() => r'4caaf646d1a6bcae88f7eb01d4f58c5346d60d19';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [_pigpenUserStream].
@ProviderFor(_pigpenUserStream)
const _pigpenUserStreamProvider = _PigpenUserStreamFamily();

/// See also [_pigpenUserStream].
class _PigpenUserStreamFamily extends Family<AsyncValue<PigpenUser>> {
  /// See also [_pigpenUserStream].
  const _PigpenUserStreamFamily();

  /// See also [_pigpenUserStream].
  _PigpenUserStreamProvider call(
    String uid,
  ) {
    return _PigpenUserStreamProvider(
      uid,
    );
  }

  @override
  _PigpenUserStreamProvider getProviderOverride(
    covariant _PigpenUserStreamProvider provider,
  ) {
    return call(
      provider.uid,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_pigpenUserStreamProvider';
}

/// See also [_pigpenUserStream].
class _PigpenUserStreamProvider extends AutoDisposeStreamProvider<PigpenUser> {
  /// See also [_pigpenUserStream].
  _PigpenUserStreamProvider(
    String uid,
  ) : this._internal(
          (ref) => _pigpenUserStream(
            ref as _PigpenUserStreamRef,
            uid,
          ),
          from: _pigpenUserStreamProvider,
          name: r'_pigpenUserStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pigpenUserStreamHash,
          dependencies: _PigpenUserStreamFamily._dependencies,
          allTransitiveDependencies:
              _PigpenUserStreamFamily._allTransitiveDependencies,
          uid: uid,
        );

  _PigpenUserStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<PigpenUser> Function(_PigpenUserStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PigpenUserStreamProvider._internal(
        (ref) => create(ref as _PigpenUserStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<PigpenUser> createElement() {
    return _PigpenUserStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PigpenUserStreamProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _PigpenUserStreamRef on AutoDisposeStreamProviderRef<PigpenUser> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _PigpenUserStreamProviderElement
    extends AutoDisposeStreamProviderElement<PigpenUser>
    with _PigpenUserStreamRef {
  _PigpenUserStreamProviderElement(super.provider);

  @override
  String get uid => (origin as _PigpenUserStreamProvider).uid;
}

String _$activeUserHash() => r'd9e3904c905e5490e528e6ed28b0cefada8ee02f';

/// See also [ActiveUser].
@ProviderFor(ActiveUser)
final activeUserProvider =
    AutoDisposeAsyncNotifierProvider<ActiveUser, PigpenUser>.internal(
  ActiveUser.new,
  name: r'activeUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveUser = AutoDisposeAsyncNotifier<PigpenUser>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
