import 'dart:async';

import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tmv_lite/core/network/dio_client.dart';
import 'package:tmv_lite/features/vehicles/model/terminal.dart';
import 'package:tmv_lite/service/location_service.dart';
import 'dart:math' as Math;
import 'package:geocode/geocode.dart';
import 'package:tmv_lite/utils/hexcolor.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Terminal vehicle;
  final CameraPosition initialCameraPosition;

  const VehicleDetailsScreen(
      {Key? key, required this.vehicle, required this.initialCameraPosition})
      : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final dioClient = DioClient.instance;
  Completer<GoogleMapController> controller = Completer();
  List<Marker> markers = [];
  List<Polyline> polylines = [];
  List<LatLng> latlngList = [];
  BitmapDescriptor? vehicleMarker;
  BitmapDescriptor? stepMarker;
  BitmapDescriptor? startPointMarker;
  dynamic vehicle = null;
  bool isTrackingVehicle = false;
  bool isTrackingMyLocation = false;
  Timer? timer;
  LatLng? lastLatLng;
  final storage = GetStorage();
  CancelToken cancelToken = CancelToken();
  LatLng? lastStepLatLng;
  double? lastStepRotation;

  @override
  void initState() {
    setVehicleMarker();
    setStepMarker();
    setStartPointMarker();
    getVehicleLocation();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    if (timer != null) {
      timer!.cancel();
    }
    cancelToken.cancel();
    super.dispose();
  }

  void startVehicleLocationProcess() async {
    try {
      timer = Timer.periodic(const Duration(seconds: 20), (Timer t) {
        getVehicleLocation();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  GeoCode geoCode = GeoCode();

  void getVehicleLocation() async {
    if (mounted) {
      setState(() {
        isTrackingVehicle = true;
      });
    }
    try {
      var formData = Dio.FormData.fromMap({
        "_Script": "API/V1/Terminal/GetForLiveLocation",
        "TerminalID": widget.vehicle.terminalID
      });
      final res = await dioClient.post("/",
          data: formData,
          cancelToken: cancelToken,
          options: Options(
            headers: {"Cookie": storage.read("user_cookie")},
          ));
      if (res.data.length != 0) {
        final lat = res.data[0]["TerminalDataLatitudeLast"];
        final long = res.data[0]["TerminalDataLongitudeLast"];
        final latLong = LatLng(double.parse(lat), double.parse(long));

        //get current location name
        // var addresses = await geoCode.reverseGeocoding(latitude: double.parse(lat), longitude: double.parse(long));

        if (lastLatLng == null && mounted) {
          startVehicleLocationProcess();
        }

        final rotation =
            lastLatLng != null ? calculateRotation(lastLatLng!, latLong) : 0.0;
        if (mounted) {
          setState(() {
            vehicle = res.data[0];
            lastLatLng = latLong;
          });
        }

        moveMarker(widget.vehicle.terminalID, latLong, vehicleMarker, rotation);
        drawStep(latLong, rotation);
      }
      if (mounted) {
        setState(() {
          isTrackingVehicle = false;
        });
      }
    } catch (e) {
      //Toast.errorToast(e.toString(), "Error occur");
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          isTrackingVehicle = false;
        });
      }
    }
  }

  void drawStep(LatLng latLng, double rotation) {
    if (lastStepLatLng == null || lastStepRotation == null) {
      setState(() {
        lastStepLatLng = latLng;
        lastStepRotation = rotation;
      });
    } else {
      if (lastStepLatLng!.latitude == latLng.latitude &&
          lastStepLatLng!.longitude == latLng.longitude) return;

      var localMarkers = markers;

      localMarkers.add(Marker(
          markerId: MarkerId(UniqueKey().toString()),
          position: lastStepLatLng!,
          icon: localMarkers.length == 1 ? startPointMarker! : stepMarker!,
          rotation: lastStepRotation!));

      setState(() {
        lastStepLatLng = latLng;
        lastStepRotation = rotation;
      });
    }
  }

  void setVehicleMarker() async {
    try {
      vehicleMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(20, 20)),
          'assets/images/car_marker_v1.png');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setStepMarker() async {
    try {
      stepMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(20, 20)),
          'assets/images/arrow_marker.png');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setStartPointMarker() async {
    try {
      startPointMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(20, 20)),
          'assets/images/start_point_marker.png');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void moveCamera(LatLng latLng) async {
    final GoogleMapController localController = await controller.future;
    final CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 15,
    );
    localController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  double radiansToDegrees(double x) {
    return x * 180.0 / Math.pi;
  }

  double calculateRotation(LatLng lastLatLng, LatLng currentLatLng) {
    double fLat = (Math.pi * lastLatLng.latitude) / 180.0;
    double fLng = (Math.pi * lastLatLng.longitude) / 180.0;
    double tLat = (Math.pi * currentLatLng.latitude) / 180.0;
    double tLng = (Math.pi * currentLatLng.longitude) / 180.0;

    double degree = radiansToDegrees(Math.atan2(
        Math.sin(tLng - fLng) * Math.cos(tLat),
        Math.cos(fLat) * Math.sin(tLat) -
            Math.sin(fLat) * Math.cos(tLat) * Math.cos(tLng - fLng)));

    double bearing = 0;
    if (degree >= 0) {
      bearing = degree;
    } else {
      bearing = 360 + degree;
    }

    debugPrint("Rotation ${degree}");
    return bearing;
  }

  InfoWindow getTerminalWindowInfo() {
    return InfoWindow(
        title: vehicle == null
            ? "--"
            : "Nearby: ${vehicle["GeoLocationName"]}(${(double.parse(vehicle["GeoLocationPositionLandmarkDistanceMeter"]) / 1000).toString().substring(0, 3)} km)",
        snippet: vehicle == null
            ? "--"
            : "Time: ${Jiffy(vehicle["TerminalDataTimeLast"])
                .format("MMMM do yyyy, h:mm:ss a")}");
  }

  void moveMarker(id, LatLng latLng, marker, double rotation) async {
    var localMarkers = markers;
    final index =
        markers.indexWhere((marker) => marker.markerId == MarkerId(id));
    if (index >= 0) {
      final previousLatLong = localMarkers[index].position;
      localMarkers[index] = Marker(
          markerId: MarkerId(id),
          position: latLng,
          icon: marker,
          rotation: rotation,
          infoWindow: getTerminalWindowInfo());
    } else {
      localMarkers.add(Marker(
          markerId: MarkerId(id),
          position: latLng,
          icon: marker,
          rotation: rotation,
          infoWindow: getTerminalWindowInfo()));
    }

    if (mounted) {
      setState(() {
        if (lastLatLng != null) {
          latlngList.add(latLng);
        }
        markers = localMarkers;
        polylines.add(Polyline(
            polylineId: PolylineId(UniqueKey().toString()),
            visible: true,
            //latlng is List<LatLng>
            points: latlngList,
            color: HexColor("#8a8a8a"),
            width: 4));
      });
    }

    moveCamera(latLng);
  }

  void setUpVehicleMarker() {
    final lat = double.parse(widget.vehicle.terminalDataLatitudeLast!);
    final long = double.parse(widget.vehicle.terminalDataLongitudeLast!);

    moveMarker(
        widget.vehicle.terminalID, LatLng(lat, long), vehicleMarker, 0.0);
  }

  void getMyLocation() async {
    try {
      final status = await LocationService.getLocationState();
      if (status == LocationStatus.PERMISSION_OK) {
        //permission is ok
        if (mounted) {
          setState(() {
            isTrackingMyLocation = true;
          });
        }
        var localMarkers = markers;
        final position = await Geolocator.getCurrentPosition();
        final latLng = LatLng(position.latitude, position.longitude);

        //move camera
        moveCamera(latLng);

        //check if marker exist or new marker
        final index = markers
            .indexWhere((marker) => marker.markerId == const MarkerId("Home"));
        if (index >= 0) {
          localMarkers[index] =
              Marker(markerId: const MarkerId("Home"), position: latLng);
        } else {
          localMarkers
              .add(Marker(markerId: const MarkerId("Home"), position: latLng));
        }

        if (mounted) {
          setState(() {
            markers = localMarkers;
            isTrackingMyLocation = false;
          });
        }
      }

      if (status == LocationStatus.SERVICE_DISABLE) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Location services are disabled."),
            content: const Text(
                "Please enable the location service from app settings"),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Go to settings'),
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
      if (status == LocationStatus.PERMISSION_DENIED) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Location permissions are denied"),
            content: const Text(
                "Location permissions are require to use this app. Please accept location permissions"),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  getMyLocation();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
        if (status == LocationStatus.PERMISSION_DENIED) {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                  "Location permissions are permanently denied, we cannot request permissions"),
              content: const Text(
                  "Please accept location permission from app setting"),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    Geolocator.openLocationSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
        ),
        body: ExpandableBottomSheet(
          background: Stack(
            children: <Widget>[
              GoogleMap(
                polylines: Set.from(polylines),
                markers: Set.from(markers),
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: widget.initialCameraPosition,
                onMapCreated: (GoogleMapController c) {
                  controller.complete(c);
                  setUpVehicleMarker();
                },
              ),
              Positioned.fill(child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: FloatingActionButton.small(
                    onPressed: () {
                      getMyLocation();
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    heroTag: UniqueKey(),
                    child: isTrackingMyLocation
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
              )),
              Positioned.fill(
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: FloatingActionButton.small(
                        heroTag: UniqueKey(),
                        onPressed: () {
                          Get.back();
                        },
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    )),
              )
            ],
          ),
          persistentHeader: Container(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FloatingActionButton.small(
                      onPressed: () {
                        if (isTrackingVehicle) return;
                        getVehicleLocation();
                      },
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      heroTag: UniqueKey(),
                      child: isTrackingVehicle
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16),),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: ListTile(
                          onTap: () {
                            if (lastLatLng != null) moveCamera(lastLatLng!);
                          },
                          leading: Image.asset(
                            "assets/images/car.png",
                            width: 50,
                            height: 50,
                          ),
                          title: Text(
                            "${widget.vehicle.carrierRegistrationNumber}, ${widget.vehicle.carrierName}",
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "RML ${widget.vehicle.terminalAssignmentCode}",
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                vehicle == null && isTrackingVehicle == true
                                    ? "Loading.."
                                    : vehicle == null &&
                                            isTrackingVehicle == false
                                        ? "---"
                                        : "Nearby of ${vehicle["GeoLocationName"]}(${(double.parse(vehicle["GeoLocationPositionLandmarkDistanceMeter"]) / 1000).toString().substring(0, 3)} km)",
                                style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold, height: 1.2),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                  vehicle == null && isTrackingVehicle == true
                                      ? "Loading.."
                                      : vehicle == null &&
                                              isTrackingVehicle == false
                                          ? "---"
                                          : "Last update ${Jiffy(vehicle["TerminalDataTimeLast"]).fromNow()}",
                                  style:
                                      textTheme.caption?.copyWith(fontSize: 11))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          expandableContent: Container(
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      Text(
                        "Travel",
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text("---")
                    ],
                  )),
                  Container(
                    color: Colors.black12,
                    width: 2,
                    height: 30,
                  ),
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      Text(
                        "Engine",
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        vehicle == null
                            ? "---"
                            : vehicle['TerminalDataIsAccOnLast'] == "1"
                                ? "ON"
                                : "OFF",
                        style: textTheme.labelLarge?.copyWith(
                            color: vehicle == null
                                ? null
                                : vehicle['TerminalDataIsAccOnLast'] == "1"
                                    ? Colors.green
                                    : Colors.red),
                      )
                    ],
                  )),
                  Container(
                    color: Colors.black12,
                    width: 2,
                    height: 30,
                  ),
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      Text(
                        "Speed",
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                          "${vehicle == null ? "---" : vehicle['TerminalDataVelocityLast'].toString().substring(0, 4)} KM/H")
                    ],
                  ))
                ],
              ),
            ),
          ),
        ));
  }
}
