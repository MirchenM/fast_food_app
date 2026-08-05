import 'package:fast_food_app/domain/entities/restaurant.dart';
import 'package:fast_food_app/domain/repositories/restaurant_repository.dart';

/// Lista de restaurantes reais de Maputo (nomes e zonas confirmados
/// por pesquisa). As coordenadas são uma aproximação da rua/zona
/// indicada, não uma geocodificação exata — dá para testar
/// pesquisa/distância/ordenação com dados verdadeiros, mas afina as
/// coordenadas mais tarde se precisares de precisão ao nível do
/// edifício (ou liga isto à Places API, quando fizer sentido).
class RestauranteRepositoryImpl implements RestauranteRepository {
  @override
  Future<List<Restaurante>> listarRestaurantes() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Restaurante(
        id: '1',
        nome: 'Teka Famba Junta',
        morada: 'R. Carlos Morgado, Maputo',
        latitude: -25.9553,
        longitude: 32.5758,
        avaliacao: 4.2,
        precoMedio: 280,
        categorias: ['Hambúrgueres', 'Frango'],
      ),
      Restaurante(
        id: '2',
        nome: 'Take Away Orca',
        morada: 'Av. Eduardo Mondlane, Maputo',
        latitude: -25.9682,
        longitude: 32.5847,
        avaliacao: 4.4,
        precoMedio: 180,
        categorias: ['Frango', 'Pregos'],
      ),
      Restaurante(
        id: '3',
        nome: 'KFC',
        morada: 'Av. Vladimir Lenine, Maputo',
        latitude: -25.9651,
        longitude: 32.5801,
        avaliacao: 3.4,
        precoMedio: 320,
        categorias: ['Frango'],
      ),
      Restaurante(
        id: '4',
        nome: 'Debonairs Pizza',
        morada: 'Baixa, Maputo',
        latitude: -25.9701,
        longitude: 32.5831,
        avaliacao: 4.1,
        precoMedio: 450,
        categorias: ['Pizza'],
      ),
    ];
  }
}