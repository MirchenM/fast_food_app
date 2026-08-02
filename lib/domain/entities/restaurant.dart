/// Entidade que representa um restaurante fast food.
class Restaurante {
  final String id;
  final String nome;
  final String morada;
  final double latitude;
  final double longitude;
  final double avaliacao; // 0 a 5
  final String? imagemUrl;
  final List<String> categorias; // ex: ['Hambúrgueres', 'Frango']

  const Restaurante({
    required this.id,
    required this.nome,
    required this.morada,
    required this.latitude,
    required this.longitude,
    this.avaliacao = 0,
    this.imagemUrl,
    this.categorias = const [],
  });
}