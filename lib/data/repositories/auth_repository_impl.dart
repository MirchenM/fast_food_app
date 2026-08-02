import 'package:fast_food_app/domain/entities/user.dart';
import 'package:fast_food_app/domain/exceptions/auth_exception.dart';
import 'package:fast_food_app/domain/repositories/auth_repository.dart';

/// Implementação "mock" de [AuthRepository]: guarda os utilizadores
/// em memória, só para testarmos os ecrãs sem depender de um backend.

/// Os dados são perdidos ao reiniciar a app — é só um ponto de partida.
/// Quando tivermos um backend definido, criamos outra classe (ex.:
/// `FirebaseAuthRepository`) que implementa o mesmo [AuthRepository],
/// e trocamos só o sítio onde é instanciada.
///
class AuthRepositoryImpl implements AuthRepository {
  // `static` para que todas as instâncias partilhem os mesmos dados
  // (senão o ecrã de login não "veria" quem se registou no ecrã de signup).
  static final Map<String, _RegistoUtilizador> _utilizadores = {};
  static Usuario? _sessaoAtual;

  @override
  Usuario? get currentUser => _sessaoAtual;

  @override
  Future<Usuario> login({
    required String email,
    required String password,
  }) async {
    await _simularLatencia();

    final registo = _utilizadores[email.toLowerCase()];
    if (registo == null || registo.password != password) {
      throw const AuthException('Email ou palavra-passe incorretos.');
    }

    _sessaoAtual = registo.usuario;
    return registo.usuario;
  }

  @override
  Future<Usuario> signUp({
    required String nome,
    required String email,
    required String password,
    String? telefone,
  }) async {
    await _simularLatencia();

    final chave = email.toLowerCase();
    if (_utilizadores.containsKey(chave)) {
      throw const AuthException('Já existe uma conta com este email.');
    }

    final usuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      email: email,
      telefone: telefone,
    );

    _utilizadores[chave] = _RegistoUtilizador(
      usuario: usuario,
      password: password,
    );
    _sessaoAtual = usuario;
    return usuario;
  }

  @override
  Future<void> logout() async {
    _sessaoAtual = null;
  }

  Future<void> _simularLatencia() =>
      Future.delayed(const Duration(milliseconds: 600));
}

class _RegistoUtilizador {
  final Usuario usuario;
  final String password;

  _RegistoUtilizador({required this.usuario, required this.password});
}