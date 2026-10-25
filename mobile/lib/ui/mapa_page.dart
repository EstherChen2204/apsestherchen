import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/api_client.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key, required this.api});
  final ApiClient api;
  @override
  State<MapaPage> createState() => _State();
}

class _Dados {
  _Dados(this.relatos, this.cemaden);
  final List<dynamic> relatos;
  final List<dynamic> cemaden;
}

class _State extends State<MapaPage> {
  _Dados? _dados;
  bool _carregando = true;
  bool mostrarCemaden = true;
  String uf = 'SP';
  
  final MapController _mapController = MapController();

  final Map<String, LatLng> _centrosEstados = {
    'SP': const LatLng(-23.55, -46.63),
    'RJ': const LatLng(-22.84, -43.15),
    'MG': const LatLng(-18.10, -44.38),
    'PE': const LatLng(-8.28, -35.07),
    'SC': const LatLng(-27.33, -49.44),
    'ES': const LatLng(-19.19, -40.34),
    'AM': const LatLng(-3.07, -61.66),
    'BA': const LatLng(-12.96, -38.50),
  };

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final r = await widget.api.enviar('GET', '/ocorrencias?page_size=100');
      final c = await widget.api.enviar('GET', '/cemaden/ocorrencias?tipologia=HIDRO&uf=$uf&page_size=200');
      if (mounted) {
        setState(() {
          _dados = _Dados(jsonDecode(r.body)['itens'], jsonDecode(c.body)['itens']);
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Color _cor(int sev) => Color.lerp(Colors.amber, Colors.red, (sev - 1) / 4)!;
  Color _corMagnitude(String m) =>
      switch (m) { 'GP' => Colors.red.shade900, 'MP' => Colors.deepOrange, _ => Colors.blueGrey };

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // O MAPA AGORA FICA FIXO AQUI (não é mais destruído ao carregar)
      FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(-23.55, -46.63),
          initialZoom: 6, // Zoom mais aberto
        ),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'br.unip.aps.alagamentos'),
          
          // Só desenha os pinos se os dados já tiverem chegado
          if (_dados != null && mostrarCemaden)
            MarkerLayer(markers: [
              for (final o in _dados!.cemaden)
                Marker(point: LatLng(o['lat'], o['lon']), width: 26, height: 26,
                    child: Tooltip(
                        message: '${o['municipio']} - ${o['data']} - magnitude ${o['magnitude']} (CEMADEN)',
                        child: Icon(Icons.change_history, color: _corMagnitude(o['magnitude'])))),
            ]),
            
          if (_dados != null)
            MarkerLayer(markers: [
              for (final o in _dados!.relatos)
                Marker(point: LatLng(o['lat'], o['lon']), width: 32, height: 32,
                    child: Icon(Icons.water_drop, color: _cor(o['severidade']))),
            ]),
        ],
      ),
      
      // Barra superior de filtros
      Positioned(top: 8, left: 8, right: 8, child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        FilterChip(
          label: const Text('CEMADEN'), 
          selected: mostrarCemaden,
          onSelected: (v) => setState(() => mostrarCemaden = v)
        ),
        DropdownButton<String>(
          value: uf, 
          items: [
            for (final u in ['SP', 'RJ', 'MG', 'PE', 'SC', 'ES', 'AM', 'BA'])
              DropdownMenuItem(value: u, child: Text(u)),
          ], 
          onChanged: (v) { 
            if (v == null) return;
            setState(() { uf = v; }); 
            
            // MÁGICA AQUI: move o mapa na mesma hora!
            _mapController.move(_centrosEstados[v]!, 6); 
            
            // Depois busca os dados novos em segundo plano
            _carregar(); 
          }
        ),
        if (_carregando) 
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ])),
    ]);
  }
}