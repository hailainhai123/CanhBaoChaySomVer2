import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/addWidget/add_account_page.dart';
import 'package:health_care/addWidget/add_department_page.dart';
import 'package:health_care/addWidget/add_device_page.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/navigator.dart';
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

  bool isLoading = true;

  @override
  void initState() {
    showLoadingDialog();
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
      body:
          isLoading ? Center(child: CircularProgressIndicator()) : buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          buildButton('Thêm khoa', Icons.meeting_room_outlined, 3),
          buildButton('Thêm tài khoản', Icons.account_box_outlined, 1),
          buildButton('Thêm thiết bị', Icons.devices, 2),
        ],
      ),
    );
  }

  Widget buildButton(String text, IconData icon, int option) {
    return GestureDetector(
      onTap: () {
        switch (option) {
          case 1:
            if (dropDownItems.isEmpty) {
              showPopup(context);
            } else {
              navigatorPush(
                  context,
                  AddAccountScreen(
                    dropDownItems: dropDownItems,
                  ));
            }
            break;
          case 2:
            if (dropDownItems.isEmpty) {
              showPopup(context);
            } else {
              navigatorPush(
                  context,
                  AddDeviceScreen(
                    dropDownItems: dropDownItems,
                  ));
            }
            break;
          case 3:
            navigatorPush(context, AddDepartmentScreen());
            break;
        }
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.add,
              size: 25,
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            Icon(
              icon,
              size: 25,
            ),
          ],
        ),
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
    hideLoadingDialog();
    print('_AddScreenState.handle ${dropDownItems.length}');
  }

  void showLoadingDialog() {
    setState(() {
      isLoading = true;
    });
    // Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    setState(() {
      isLoading = false;
    });
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
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

  void showPopup(context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              backgroundColor: Colors.transparent,
              content: Text(
                'Chưa có khoa',
              ),
            ));
  }
}
