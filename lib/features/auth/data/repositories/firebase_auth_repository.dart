import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/i_auth_repository.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }

  @override
  Future<String> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return cred.user!.uid;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}