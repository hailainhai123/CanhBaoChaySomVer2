import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/model/user.dart';

import '../helper/constants.dart' as Constants;

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> users = List();
  User user = User(
    'mac',
    'lek21197@gmail.com',
    'pass',
    'Lê Hồng Khánh',
    'sdt',
    'nha',
  );
  MQTTClientWrapper mqttClientWrapper;

  @override
  void initState() {
    initMqtt();
    for (int i = 0; i < 100; i++) {
      users.add(user);
    }
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleUser(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn thoát ứng dụng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Danh sách tài khoản'),
          centerTitle: true,
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          buildTableTitle(),
          horizontalLine(),
          buildListView(),
          horizontalLine(),
        ],
      ),
    );
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('STT', 1),
          verticalLine(),
          buildTextLabel('Username', 4),
          verticalLine(),
          buildTextLabel('Tên', 4),
        ],
      ),
    );
  }

  Widget buildTextLabel(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {
            return itemView(index);
          },
        ),
      ),
    );
  }

  Widget itemView(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        children: [
          Container(
            height: 40,
            child: Row(
              children: [
                buildTextData('${index + 1}', 1),
                verticalLine(),
                buildTextData(users[index].email, 4),
                verticalLine(),
                buildTextData(users[index].ten, 4),
              ],
            ),
          ),
          horizontalLine(),
        ],
      ),
    );
  }

  Widget buildTextData(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget verticalLine() {
    return Container(
      height: double.infinity,
      width: 1,
      color: Colors.grey,
    );
  }

  Widget horizontalLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey,
    );
  }

  void handleUser(String message) {}
}
