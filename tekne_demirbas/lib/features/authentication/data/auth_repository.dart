import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Future<void> signInWithEmailAndPassWord({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Email verification kontrolü
    if (userCredential.user != null) {
      await userCredential.user!.reload();
      if (!userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Lütfen email adresinizi doğrulayın',
        );
      }
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Email verification gönder
    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Hesabı kalıcı olarak siler (App Store 5.1.1(v) gereksinimi).
  /// Önce şifre ile yeniden kimlik doğrulaması yapılır, ardından
  /// kullanıcının kişisel verileri ve Auth hesabı silinir.
  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    final firestore = FirebaseFirestore.instance;
    final uid = user.uid;

    // Üye olduğu odalardan çıkar
    final rooms = await firestore
        .collection('rooms')
        .where('memberIds', arrayContains: uid)
        .get();
    for (final doc in rooms.docs) {
      await doc.reference.update({
        'memberIds': FieldValue.arrayRemove([uid]),
      });
    }

    // Kullanıcı dokümanını sil (kişisel veriler + FCM tokenları)
    await firestore.collection('users').doc(uid).delete();

    // Auth hesabını sil
    await user.delete();
  }

  Future<void> signOut() async {
    // Tüm Firebase Auth state'ini temizle
    await _auth.signOut();
    // Ekstra güvenlik için bir kez daha kontrol et
    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(FirebaseAuth.instance);
}

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return authRepository.authStateChanges();
}

@Riverpod(keepAlive: true)
Stream<User?> currentUser(Ref ref) {
  // Auth state değişikliklerini dinle
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
}
