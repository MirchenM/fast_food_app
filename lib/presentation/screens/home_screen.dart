
import 'package:fast_food_app/data/repositories/restaurant_repository_impl.dart';
import 'package:fast_food_app/domain/entities/restaurant.dart';
import 'package:fast_food_app/domain/repositories/restaurant_repository.dart';
import 'package:flutter/material.dart';

/// Centro por omissão (Maputo) caso a localização não esteja disponível.
const _localizacaoOmissao = LatLng(-25.9692, 32.5732);

class HomeScreen extends StatefulWidget {
  final RestauranteRepository? restauranteRepository;

  const HomeScreen({super.key, this.restauranteRepository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final RestauranteRepository _restauranteRepository =
      widget.restauranteRepository ?? RestauranteRepositoryImpl();

  GoogleMapController? _mapController;
  Position? _posicaoAtual;
  List<Restaurante> _restaurantes = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final posicao = await _obterLocalizacaoAtual();
      final restaurantes = await _restauranteRepository.listarRestaurantes();

      setState(() {
        _posicaoAtual = posicao;
        _restaurantes = restaurantes;
        if (posicao == null) {
          _erro = 'Não foi possível obter a tua localização.';
        }
      });
    } catch (_) {
      setState(() => _erro = 'Não foi possível obter a tua localização.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<Position?> _obterLocalizacaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return null;

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double? _distanciaKm(Restaurante r) {
    if (_posicaoAtual == null) return null;
    final metros = Geolocator.distanceBetween(
      _posicaoAtual!.latitude,
      _posicaoAtual!.longitude,
      r.latitude,
      r.longitude,
    );
    return metros / 1000;
  }

  Set<Marker> get _marcadores {
    return _restaurantes.map((r) {
      return Marker(
        markerId: MarkerId(r.id),
        position: LatLng(r.latitude, r.longitude),
        infoWindow: InfoWindow(title: r.nome, snippet: r.categorias.join(', ')),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final centro = _posicaoAtual != null
        ? LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude)
        : _localizacaoOmissao;

    final restaurantesOrdenados = [..._restaurantes]..sort((a, b) {
      final da = _distanciaKm(a) ?? double.infinity;
      final db = _distanciaKm(b) ?? double.infinity;
      return da.compareTo(db);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Perto de ti')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: centro, zoom: 14),
            markers: _marcadores,
            myLocationEnabled: _posicaoAtual != null,
            myLocationButtonEnabled: _posicaoAtual != null,
            onMapCreated: (controller) => _mapController = controller,
          ),
          if (_erro != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '$_erro A mostrar Maputo por omissão.',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.14,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: restaurantesOrdenados.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }
                    final r = restaurantesOrdenados[index - 1];
                    return _RestauranteCard(
                      restaurante: r,
                      distanciaKm: _distanciaKm(r),
                      onTap: () {
                        // TODO: navegar para o ecrã de menu do restaurante
                        // assim que existir.
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(r.latitude, r.longitude),
                            16,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RestauranteCard extends StatelessWidget {
  final Restaurante restaurante;
  final double? distanciaKm;
  final VoidCallback onTap;

  const _RestauranteCard({
    required this.restaurante,
    required this.distanciaKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.fastfood_rounded, color: Colors.white),
      ),
      title: Text(restaurante.nome),
      subtitle: Text(restaurante.categorias.join(', ')),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 2),
              Text(restaurante.avaliacao.toStringAsFixed(1)),
            ],
          ),
          if (distanciaKm != null)
            Text(
              '${distanciaKm!.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}