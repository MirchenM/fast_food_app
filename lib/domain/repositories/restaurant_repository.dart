import 'package:fast_food_app/domain/entities/restaurant.dart';

abstract class RestauranteRepository {
  /// Lista de restaurantes conhecidos (mock, por agora — mais tarde
  /// pode vir de uma API tipo Google Places em vez de dados fixos).
  Future<List<Restaurante>> listarRestaurantes();
}