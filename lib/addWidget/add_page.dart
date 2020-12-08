import 'package:flutter/material.dart';
import 'package:health_care/addWidget/add_account_page.dart';
import 'package:health_care/addWidget/add_device_page.dart';

class AddScreen extends StatefulWidget {
  final String quyen;

  const AddScreen({Key key, this.quyen}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm',
        ),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: RaisedButton(
              child: Text('Thêm tài khoản'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAccountScreen(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RaisedButton(
              child: Text('Thêm thiết bị'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDeviceScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
