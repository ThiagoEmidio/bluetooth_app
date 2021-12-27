import 'package:bluetooth_app/ble_env.dart';
import 'package:bluetooth_app/classical_bluetooth_env.dart';
import 'package:bluetooth_app/utils.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BluetoothApp'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            PageButtonWidget(
              page: BleEnv(),
              name: 'BLE Test Environment',
            ),
            PageButtonWidget(
              page: ClassicalBluetoothEnv(),
              name: 'Classical Bluetooth (only RFCOMM)',
            ),
          ],
        ),
      ),
    );
  }
}

class PageButtonWidget extends StatelessWidget {
  final String name;
  final Widget page;

  const PageButtonWidget({
    Key? key,
    required this.name,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: ()=>push(context, page),
      child: Text(name),
    );
  }
}
