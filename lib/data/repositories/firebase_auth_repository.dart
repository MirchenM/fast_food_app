import 'package:fast_food_app/domain/entities/user.dart';
import 'package:fast_food_app/domain/exceptions/auth_exception.dart';
import 'package:fast_food_app/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Implementação real de [AuthRepository] usando o Firebase Authentication.
/// Substitui o [AuthRepositoryImpl] mock — a interface (contrato) é a
/// mesma, por isso os ecrãs de login/registo não mudam nada.
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;

  FirebaseAuthRepository({fb.FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance;

  @override
  Usuario? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _paraUsuario(user);
  }

  @override
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _paraUsuario(credencial.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mensagemDeErro(e.code));
    }
  }

  @override
  Future<Usuario> signUp({
    required String nome,
    required String email,
    required String password,
    String? telefone,
  }) async {
    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credencial.user?.updateDisplayName(nome);

      return Usuario(id: credencial.user!.uid, nome: nome, email: email, telefone: telefone);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_mensagemDeErro(e.code));
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  Usuario _paraUsuario(fb.User user) {
    return Usuario(
      id: user.uid,
      nome: user.displayName ?? '',
      email: user.email ?? '',
    );
  }

  String _mensagemDeErro(String codigo) {
    switch (codigo) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou palavra-passe incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este email.';
      case 'weak-password':
        return 'A palavra-passe é demasiado fraca (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'Email inválido.';
      case 'network-request-failed':
        return 'Sem ligação à internet.';
      default:
        return 'Ocorreu um erro. Tenta novamente.';
    }
  }
}