
import 'package:fast_food_app/domain/entities/restaurant.dart';
import 'package:fast_food_app/domain/repositories/restaurant_repository.dart';

/// Implementação mock — lista fixa de restaurantes de exemplo em
/// Maputo, só para termos algo no mapa enquanto não há uma fonte real.
class RestauranteRepositoryImpl implements RestauranteRepository {
  @override
  Future<List<Restaurante>> listarRestaurantes() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return const [
      Restaurante(
        id: '1',
        nome: 'Chicken Zone',
        morada: 'Av. Julius Nyerere, Maputo',
        latitude: -25.9655,
        longitude: 32.5892,
        avaliacao: 4.3,
        categorias: ['Frango'],
      ),
      Restaurante(
        id: '2',
        nome: 'Burger House',
        morada: 'Av. 24 de Julho, Maputo',
        latitude: -25.9689,
        longitude: 32.5808,
        avaliacao: 4.5,
        categorias: ['Hambúrgueres'],
      ),
      Restaurante(
        id: '3',
        nome: 'Pizza Rápida',
        morada: 'Av. Eduardo Mondlane, Maputo',
        latitude: -25.9720,
        longitude: 32.5934,
        avaliacao: 4.0,
        categorias: ['Pizza'],
      ),
      Restaurante(
        id: '4',
        nome: 'Fast Grill',
        morada: 'Av. Vladimir Lenine, Maputo',
        latitude: -25.9598,
        longitude: 32.5735,
        avaliacao: 3.9,
        categorias: ['Grelhados'],
      ),
    ];
  }
}