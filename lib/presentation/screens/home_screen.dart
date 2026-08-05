import 'package:fast_food_app/data/repositories/restaurant_repository_impl.dart';
import 'package:fast_food_app/domain/entities/restaurant.dart';
import 'package:fast_food_app/domain/repositories/restaurant_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


/// Muda para `true` quando tiveres o Google Maps configurado (API key
/// na Web em web/index.html e/ou no AndroidManifest.xml). A localização
/// em si (GPS) não depende disto — só o widget do mapa depende.
const bool _mapaAtivo = false;

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

  final _searchController = TextEditingController();

  GoogleMapController? _mapController;
  Position? _posicaoAtual;
  List<Restaurante> _restaurantes = [];
  String _pesquisa = '';
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      // A localização usa o GPS do aparelho (via Geolocator) — não
      // depende da API do Google Maps nem de faturação, por isso
      // funciona mesmo com _mapaAtivo a false.
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

  List<Restaurante> get _restaurantesFiltrados {
    if (_pesquisa.trim().isEmpty) return _restaurantes;
    final query = _pesquisa.trim().toLowerCase();
    return _restaurantes.where((r) {
      final nomeMatch = r.nome.toLowerCase().contains(query);
      final categoriaMatch =
      r.categorias.any((c) => c.toLowerCase().contains(query));
      return nomeMatch || categoriaMatch;
    }).toList();
  }

  Set<Marker> get _marcadores {
    return _restaurantesFiltrados.map((r) {
      return Marker(
        markerId: MarkerId(r.id),
        position: LatLng(r.latitude, r.longitude),
        infoWindow: InfoWindow(title: r.nome, snippet: r.categorias.join(', ')),
      );
    }).toSet();
  }

  String get _saudacao {
    final nome = FirebaseAuth.instance.currentUser?.displayName;
    if (nome == null || nome.trim().isEmpty) return 'Perto de ti';
    return 'Olá, ${nome.trim().split(' ').first}!';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final centro = _posicaoAtual != null
        ? LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude)
        : _localizacaoOmissao;

    final restaurantesOrdenados = [..._restaurantesFiltrados]..sort((a, b) {
      final da = _distanciaKm(a) ?? double.infinity;
      final db = _distanciaKm(b) ?? double.infinity;
      return da.compareTo(db);
    });

    return Scaffold(
      appBar: AppBar(title: Text(_saudacao)),
      body: Stack(
        children: [
          if (_mapaAtivo)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: centro, zoom: 14),
              markers: _marcadores,
              myLocationEnabled: _posicaoAtual != null,
              myLocationButtonEnabled: _posicaoAtual != null,
              onMapCreated: (controller) => _mapController = controller,
            )
          else
            Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: Colors.grey.shade500),
                  const SizedBox(height: 12),
                  Text(
                    'Mapa por configurar.\nMuda _mapaAtivo para true quando'
                        ' tiveres a API key.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          // Barra de pesquisa flutuante.
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                controller: _searchController,
                onChanged: (valor) => setState(() => _pesquisa = valor),
                decoration: InputDecoration(
                  hintText: 'Hambúrguer, pizza, prego...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _pesquisa.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _pesquisa = '');
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          if (_erro != null)
            Positioned(
              top: 68,
              left: 12,
              right: 12,
              child: Material(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '$_erro A mostrar Maputo por omissão.',
                    style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                  ),
                ),
              ),
            ),

          DraggableScrollableSheet(
            initialChildSize: _mapaAtivo ? 0.32 : 0.62,
            minChildSize: 0.16,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
                ),
                child: restaurantesOrdenados.isEmpty
                    ? ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _puxador(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('Nenhum restaurante encontrado.'),
                      ),
                    ),
                  ],
                )
                    : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: restaurantesOrdenados.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) return _puxador();
                    final r = restaurantesOrdenados[index - 1];
                    return _RestauranteCard(
                      restaurante: r,
                      distanciaKm: _distanciaKm(r),
                      onTap: () {
                        // TODO: navegar para o ecrã de menu do
                        // restaurante assim que existir.
                        if (_mapaAtivo) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(r.latitude, r.longitude),
                              16,
                            ),
                          );
                        }
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

  Widget _puxador() {
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.fastfood_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurante.nome,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: restaurante.categorias
                        .map((c) => _CategoriaChip(texto: c))
                        .toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        restaurante.avaliacao.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '~${restaurante.precoMedio.toStringAsFixed(0)} MT',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (distanciaKm != null)
              Text(
                '${distanciaKm!.toStringAsFixed(1)} km',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String texto;

  const _CategoriaChip({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}