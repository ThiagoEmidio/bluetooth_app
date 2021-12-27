import 'dart:convert';

import 'package:bluetooth_app/services_page.dart';
import 'package:bluetooth_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleEnv extends StatefulWidget {
  const BleEnv({Key? key}) : super(key: key);

  @override
  State<BleEnv> createState() => _BleEnvState();
}

class _BleEnvState extends State<BleEnv> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool scanning = false;
  List<ScanResult> listOfScanResult = [];

  List<BluetoothDevice>? _connectedDevice;
  bool isBluetoothOn = true;

  @override
  void initState() {
    _getPermissions();
    _checkTheBluetooth();
    super.initState();
  }

  _getPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
    print('statuses: $statuses');
  }

  _checkTheBluetooth() async {
    await Future.wait([
      flutterBlue.stopScan(),
      flutterBlue.connectedDevices.then((value) {
        _connectedDevice = value;
      }),
      flutterBlue.isOn.then((value) => isBluetoothOn = value),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BLE test environment'),
          actions: <Widget>[
            IconButton(
              onPressed: _checkBluetooth,
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (isBluetoothOn != true)
                    const Text("Bluetooth Não conectado"),
                  ElevatedButton(
                    onPressed: _whatDevicesAreConnected,
                    child: const Text("Logar connected devices"),
                  ),
                  ElevatedButton(
                    onPressed: _discoverServices,
                    child: const Text("Logar primeiro serviço"),
                  ),
                  ElevatedButton(
                    onPressed: _disconnectToDevice,
                    child: const Text("Desconectar dispositivo"),
                  ),
                  const Divider(
                    height: 10,
                    thickness: 5,
                  ),
                  if (scanning == true)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String subtitle =
                          'rssi: ${listOfScanResult[index].rssi}\n'
                          'id: ${listOfScanResult[index].device.id}';
                      String name = listOfScanResult[index].device.name;
                      String title =
                          name != "" ? name : "(Nome não encontrado)";
                      bool isConnected = _connectedDevice?.any((element) =>
                      (element.id.toString() ==
                          listOfScanResult[index]
                              .device
                              .id
                              .toString())) ==
                          true;
                      return ListTile(
                        title: Text(title),
                        subtitle: Text(subtitle),
                        trailing: isConnected==true
                            ? TextButton(
                                onPressed: () => _disconnectToDevice(),
                                child: const Text("Desconectar"),
                              )
                            : TextButton(
                                onPressed: () => _connectToDevice(index),
                                child: const Text("Conectar"),
                              ),
                        onTap: isConnected ? ()=>push(context, ServicesPage(listOfScanResult[index])) :(){},
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: listOfScanResult.length,
                  ),
                  const Divider(
                    height: 10,
                    thickness: 5,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _checkBluetooth() {
    flutterBlue.stopScan();
    scanning = true;
    if (mounted) {
      setState(() {});
    }
    flutterBlue
        .startScan(
      timeout: const Duration(seconds: 130),
      scanMode: ScanMode.lowLatency,
      allowDuplicates: false,
    )
        .whenComplete(() {
      scanning = false;
      if (mounted) {
        setState(() {});
      }
    });
    flutterBlue.scanResults.listen((results) {
      listOfScanResult = results;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _whatDevicesAreConnected() async {
    await Future.wait([
      flutterBlue.connectedDevices.then((devices) {
        print(' connected devices: ' + devices.toString());
        _connectedDevice = devices;
      }),
      flutterBlue.isAvailable.then((v) {
        print('isAvaiable: ' + v.toString());
      }),
      flutterBlue.isOn.then((v) {
        print('isOn: ' + v.toString());
      }),
    ]);
    setState(() {});
  }

  void _connectToDevice(int index) {
    flutterBlue.stopScan();
    print('info: ${listOfScanResult[index]}');
    listOfScanResult[index].device.disconnect().whenComplete(() {
      listOfScanResult[index].device.connect(
            timeout: const Duration(seconds: 10),
            autoConnect: true,
          )
        ..onError((error, stackTrace) => print(error))
        ..whenComplete(() => _whatDevicesAreConnected());
      print("Correctly connected");
    });
  }

  _discoverServices() {
    listOfScanResult.first.device.discoverServices().then((services) async {
      var characteristics = services[4].characteristics;
      var characteristic = characteristics[0];
      await Future.delayed(const Duration(milliseconds: 300));
      var value = await characteristic.read();
      List<int> value2 = [];
      if (characteristic.descriptors.isNotEmpty) {
        value2 = await characteristic.descriptors.first.read();
      }
      print('value: "${utf8.decode(value, allowMalformed: true)}" '
          '\n value2: "${utf8.decode(value2, allowMalformed: true)}"');
    });
  }

  _disconnectToDevice() {
    flutterBlue.connectedDevices.then((devices) {
      if(devices.isNotEmpty) {
        devices.first.disconnect().then((value) => _whatDevicesAreConnected());
      }
    });
  }
}
