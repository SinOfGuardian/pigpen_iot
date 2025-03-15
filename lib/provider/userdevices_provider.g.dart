// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userdevices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDevicesStreamHash() => r'fc5b9672b5b1aa79ac14959b5251d31024ece575';

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

/// See also [userDevicesStream].
@ProviderFor(userDevicesStream)
const userDevicesStreamProvider = UserDevicesStreamFamily();

/// See also [userDevicesStream].
class UserDevicesStreamFamily extends Family<AsyncValue<List<UserDevice>>> {
  /// See also [userDevicesStream].
  const UserDevicesStreamFamily();

  /// See also [userDevicesStream].
  UserDevicesStreamProvider call(
    String uid,
  ) {
    return UserDevicesStreamProvider(
      uid,
    );
  }

  @override
  UserDevicesStreamProvider getProviderOverride(
    covariant UserDevicesStreamProvider provider,
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
  String? get name => r'userDevicesStreamProvider';
}

/// See also [userDevicesStream].
class UserDevicesStreamProvider
    extends AutoDisposeStreamProvider<List<UserDevice>> {
  /// See also [userDevicesStream].
  UserDevicesStreamProvider(
    String uid,
  ) : this._internal(
          (ref) => userDevicesStream(
            ref as UserDevicesStreamRef,
            uid,
          ),
          from: userDevicesStreamProvider,
          name: r'userDevicesStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userDevicesStreamHash,
          dependencies: UserDevicesStreamFamily._dependencies,
          allTransitiveDependencies:
              UserDevicesStreamFamily._allTransitiveDependencies,
          uid: uid,
        );

  UserDevicesStreamProvider._internal(
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
    Stream<List<UserDevice>> Function(UserDevicesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDevicesStreamProvider._internal(
        (ref) => create(ref as UserDevicesStreamRef),
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
  AutoDisposeStreamProviderElement<List<UserDevice>> createElement() {
    return _UserDevicesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDevicesStreamProvider && other.uid == uid;
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
mixin UserDevicesStreamRef on AutoDisposeStreamProviderRef<List<UserDevice>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserDevicesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<UserDevice>>
    with UserDevicesStreamRef {
  _UserDevicesStreamProviderElement(super.provider);

  @override
  String get uid => (origin as UserDevicesStreamProvider).uid;
}

String _$userDevicesHash() => r'679739fde0789a6285b64d5a31e6e86df05b4421';

/// See also [UserDevices].
@ProviderFor(UserDevices)
final userDevicesProvider =
    AutoDisposeAsyncNotifierProvider<UserDevices, List<UserDevice>>.internal(
  UserDevices.new,
  name: r'userDevicesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userDevicesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserDevices = AutoDisposeAsyncNotifier<List<UserDevice>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
