import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ServicesPage extends StatefulWidget {
  final ScanResult scanResult;

  const ServicesPage(this.scanResult, {Key? key}) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<BluetoothService> _services = [];

  @override
  void initState() {
    widget.scanResult.device
        .discoverServices()
        .then((value) {
           setState(() {
             _services = value;
           });
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BLE test services'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  var chars = _services[index].characteristics.map((e) => "\n"+ e.uuid.toString().substring(0,8));
                  return ListTile(
                    title: Text('uuid: ${_services[index].uuid.toString().substring(0,8)}'),
                    subtitle: Text("chars: $chars"),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _services.length,
              ),
            ),
          ],
        ));
  }
}
