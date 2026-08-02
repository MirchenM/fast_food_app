// Entidade que represente um utilizador da aplicação (cliente)

// Pertence à camada 'domain' - não sabe nada Flutter, bases de
// dados ou APIs. É só o "conceito" de utilizador

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String? telefone;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
  });
}