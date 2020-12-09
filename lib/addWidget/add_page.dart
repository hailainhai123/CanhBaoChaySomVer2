import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/addWidget/add_account_page.dart';
import 'package:health_care/addWidget/add_department_page.dart';
import 'package:health_care/addWidget/add_device_page.dart';
import 'package:health_care/helper/loader.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/response/device_response.dart';

import '../helper/constants.dart' as Constants;

class AddScreen extends StatefulWidget {
  final String quyen;

  const AddScreen({Key key, this.quyen}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  static const GET_DEPARTMENT = 'loginkhoa';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  List<Department> departments = List();
  List<String> dropDownItems = List();

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    Department d = Department('', '', Constants.mac);
    publishMessage(GET_DEPARTMENT, jsonEncode(d));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                ),
                FlatButton(
                  child: Text('Thêm tài khoản'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAccountScreen(
                          dropDownItems: dropDownItems,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                ),
                FlatButton(
                  child: Text('Thêm thiết bị'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDeviceScreen(
                          dropDownItems: dropDownItems,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                ),
                FlatButton(
                  child: Text('Thêm khoa'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDepartmentScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    var response = DeviceResponse.fromJson(responseMap);
    departments = response.id.map((e) => Department.fromJson(e)).toList();
    dropDownItems.clear();
    departments.forEach((element) {
      dropDownItems.add(element.makhoa);
    });
    print('_AddScreenState.handle ${dropDownItems.length}');
  }

  void showLoadingDialog() {
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }
}
