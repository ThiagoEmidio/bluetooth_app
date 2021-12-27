import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ClassicalBluetoothEnv extends StatefulWidget {
  const ClassicalBluetoothEnv({Key? key}) : super(key: key);

  @override
  State<ClassicalBluetoothEnv> createState() => _ClassicalBluetoothEnvState();
}

class _ClassicalBluetoothEnvState extends State<ClassicalBluetoothEnv> {
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  bool scanning = false;
  List<BluetoothDevice> listOfScanResult = [];
  bool _connected = false;
  bool _pressed = false;
  BluetoothConnection? connectedTo;

  @override
  void initState() {
    getPermissions();
    addListenerToStateChanges();
    super.initState();
  }

  getPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
    print('statuses: $statuses');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Classical Bluetooth Env'),
          actions: <Widget>[
            IconButton(
              onPressed: _checkBluetooth,
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: getPermissions,
                child: const Text("getPermissions"),
              ),
              ElevatedButton(
                onPressed: _checkBluetooth,
                child: const Text("checkBluetooth"),
              ),
              ElevatedButton(
                onPressed: _whatDevicesAreConnected,
                child: const Text("whatDevicesAreConnected"),
              ),
              const Divider(
                height: 10,
                thickness: 5,
              ),
              if (scanning == true)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    String subtitle = 'type: ${listOfScanResult[index].type}\n'
                        'isConnected: ${listOfScanResult[index].isConnected}\n'
                        'address: ${listOfScanResult[index].address}\n'
                        'isBonded: ${listOfScanResult[index].isBonded}\n';
                    String? name = listOfScanResult[index].name;
                    String title = name != "" || name != null
                        ? name!
                        : "(Nome não encontrado)";
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(subtitle),
                      trailing: listOfScanResult[index].isConnected == false
                          ? TextButton(
                              onPressed: () => _connectToDevice(index),
                              child: const Text("Conectar"),
                            )
                          : TextButton(
                              onPressed: () {},
                              child: const Text("Conectado"),
                            ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                  itemCount: listOfScanResult.length,
                ),
              )
            ],
          ),
        ));
  }

  void _checkBluetooth() async {
    scanning = true;
    setState(() {});
    listOfScanResult = [];
    bluetooth.startDiscovery().listen((event) {
      listOfScanResult.add(event.device);
    }).onDone(() {
      scanning = false;
      setState(() {});
    });
  }

  void _whatDevicesAreConnected() async {
    connectedTo?.input?.listen((value) {
      print(value);
    });
  }

  void _connectToDevice(int index) async {
    bluetooth.cancelDiscovery();
    BluetoothConnection connection = await BluetoothConnection.toAddress(listOfScanResult.first.address);
    //_checkBluetooth;
    setState(() {});
  }

  void addListenerToStateChanges() {
    // For knowing when bluetooth is connected and when disconnected
    bluetooth.onStateChanged().listen((state) {
      switch (state.stringValue) {
        case "STATE_TURNING_ON":
          setState(() {
            _connected = true;
            _pressed = false;
          });

          break;

        case "STATE_TURNING_OFF":
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;

        default:
          print(state);
          break;
      }
    });
  }
}
