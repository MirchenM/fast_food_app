/// Exceção lançada quando uma operação de autenticação falha
/// (credenciais inválidas, email já registado, etc.).
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}