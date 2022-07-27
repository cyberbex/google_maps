import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  Set<Polygon> _polygons = {};

  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-20.082918176518998, -50.8712734176755), zoom: 14);

  _onMapCreated(GoogleMapController googleMapController) {
    _controller.complete(googleMapController);
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(_posicaoCamera),
    );
  }

  _carregarMarcadores() {
    Set<Marker> _marcadoresLocal = {};

    /* Marker marcadorAeroPorto = Marker(
        markerId: MarkerId("Marcador-AeroPorto"),
        position: LatLng(-25.388162287979604, -54.26880486135598),
        infoWindow: InfoWindow(title: "Aero Porto de São Miguel do Iguaçu"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: 45);
    Marker marcadorPostoCacic = Marker(
        markerId: MarkerId("Marcador-PostoCacic"),
        position: LatLng(-25.373638064668558, -54.271263937805806),
        onTap: () {
          print('posto clicado!!');
        });
    _marcadoresLocal.add(marcadorAeroPorto);
    _marcadoresLocal.add(marcadorPostoCacic);
    setState(() {
      _marcadores = _marcadoresLocal;
    }); */

    Set<Polygon> listaPolygons = {};
    Polygon polygon1 = Polygon(
        polygonId: PolygonId("polygon1"),
        fillColor: Colors.transparent,
        strokeColor: Colors.red,
        strokeWidth: 3,
        points: [
          LatLng(-25.349707748910628, -54.243353352053774),
          LatLng(-25.349722701833926, -54.2343688055496),
          LatLng(-25.3542683048032, -54.2381744145661),
        ]);
    listaPolygons.add(polygon1);
    setState(() {
      _polygons = listaPolygons;
    });
  }

  _recuperarLocalizacaoAtual() async {
    Position position = await _determinePosirion();
    print("Localização atual: " + position.toString());
  }

  _adicionarListenerLocalizacao() {
    var locatorOptions = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        intervalDuration: const Duration(seconds: 10));

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locatorOptions)
            .listen((Position? position) {
      //print(position == null
      //  ? 'Unknown'
      // : '${position.latitude.toString()}, ${position.longitude.toString()}');
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position!.latitude, position.longitude), zoom: 17);
        _movimentarCamera();
      });
    });
  }

  Future<Position> _determinePosirion() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission are danied');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_carregarMarcadores();
    //_recuperarLocalizacaoAtual();
    _adicionarListenerLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: _movimentarCamera,
      ),
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          //markers: _marcadores,
          //polygons: _polygons,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
