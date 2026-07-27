// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firestore_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FirestoreController)
final firestoreControllerProvider = FirestoreControllerProvider._();

final class FirestoreControllerProvider
    extends $AsyncNotifierProvider<FirestoreController, void> {
  FirestoreControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreControllerHash();

  @$internal
  @override
  FirestoreController create() => FirestoreController();
}

String _$firestoreControllerHash() =>
    r'442b5b87a4360ba0ecb0774d653f95d5fe6a133e';

abstract class _$FirestoreController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
