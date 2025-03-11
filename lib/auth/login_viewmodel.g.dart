// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showPasswordLoginHash() => r'fe60f9b8aa53d95b3f1ce9356ad2a68872513c28';

/// See also [ShowPasswordLogin].
@ProviderFor(ShowPasswordLogin)
final showPasswordLoginProvider =
    AutoDisposeNotifierProvider<ShowPasswordLogin, bool>.internal(
  ShowPasswordLogin.new,
  name: r'showPasswordLoginProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showPasswordLoginHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowPasswordLogin = AutoDisposeNotifier<bool>;
String _$loginHash() => r'0b481ca973f3081bea4ba61e6bff0bbcdf95240a';

/// See also [Login].
@ProviderFor(Login)
final loginProvider = NotifierProvider<Login, AuthUser>.internal(
  Login.new,
  name: r'loginProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Login = Notifier<AuthUser>;
String _$loginFieldsHash() => r'a1b1267136f52775fbae35dd167c87d3cff81026';

/// See also [LoginFields].
@ProviderFor(LoginFields)
final loginFieldsProvider =
    AutoDisposeNotifierProvider<LoginFields, AuthFieldsMessage>.internal(
  LoginFields.new,
  name: r'loginFieldsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginFieldsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LoginFields = AutoDisposeNotifier<AuthFieldsMessage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
