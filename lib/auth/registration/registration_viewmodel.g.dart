// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showPasswordSignupHash() =>
    r'fc63b37054feb838ea5c5f292733c03208cb3379';

/// See also [ShowPasswordSignup].
@ProviderFor(ShowPasswordSignup)
final showPasswordSignupProvider =
    AutoDisposeNotifierProvider<ShowPasswordSignup, bool>.internal(
  ShowPasswordSignup.new,
  name: r'showPasswordSignupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showPasswordSignupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowPasswordSignup = AutoDisposeNotifier<bool>;
String _$registrationHash() => r'2dc4bfa2883e6053b997ced87370357cfc5006d3';

/// See also [Registration].
@ProviderFor(Registration)
final registrationProvider = NotifierProvider<Registration, AuthUser>.internal(
  Registration.new,
  name: r'registrationProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$registrationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Registration = Notifier<AuthUser>;
String _$registrationFieldsHash() =>
    r'0f32a63a9371808be3fdd7d76cdc5bebab5a213d';

/// See also [RegistrationFields].
@ProviderFor(RegistrationFields)
final registrationFieldsProvider =
    AutoDisposeNotifierProvider<RegistrationFields, AuthFieldsMessage>.internal(
  RegistrationFields.new,
  name: r'registrationFieldsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registrationFieldsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RegistrationFields = AutoDisposeNotifier<AuthFieldsMessage>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
