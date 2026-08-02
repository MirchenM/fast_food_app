import 'package:fast_food_app/domain/entities/user.dart';

/// Contrato de autenticação.
///
/// A camada `presentation` (os ecrãs) depende só desta interface,
/// nunca da implementação concreta — essa está em `data/`. Assim,
/// quando ligarmos a um backend real (Firebase, API própria, etc.),
/// só é preciso criar outra classe que implemente este contrato,
/// sem tocar nos ecrãs de login/registo.
///
abstract class AuthRepository {
  /// Utilizador com sessão iniciada, ou `null` se ninguém tiver entrado.
  Usuario? get currentUser;

  Future<Usuario> login({
    required String email,
    required String password,
  });

  Future<Usuario> signUp({
    required String nome,
    required String email,
    required String password,
    String? telefone,
  });

  Future<void> logout();
}