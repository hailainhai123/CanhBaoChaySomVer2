import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/device/edit_page.dart';
import 'package:health_care/dialogWidget/edit_patient_dialog.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/home.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/room.dart';
import 'package:health_care/response/device_response.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';
import 'department_page.dart';

const int LOGIN_NHA = 0;
const int DELETE_NHA = 1;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  HomePage({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomePageState createState() => _HomePageState(loginResponse);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  _HomePageState(this.loginResponse);

  final Map loginResponse;
  List<Device> devices;
  List<Room> rooms = List();
  List<Department> departments = List();
  List<Home> homes = List();
  Home seletedHome;
  String iduser;
  DeviceResponse response;
  int homeAction = 2;
  int deletePosition = 0;

  MQTTClientWrapper mqttClientWrapper;
  List<Patient> patients = List();

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

  Future<bool> _deleteHome(Home home) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn xóa nhà ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop(false);
                    Home h = Home(
                        '', iduser, home.tennha, home.manha, Constants.mac);
                    String dJson = jsonEncode(h);
                    publishMessage('deletenha', dJson);
                    homeAction = DELETE_NHA;
                  });
                },
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    initPatientTest();
    response = DeviceResponse.fromJson(loginResponse);

    iduser = response.message;
    // homes = response.id.map((e) => Home.fromJson(e)).toList();
  }

  void initPatientTest() {
    Patient patient = Patient(
      'id',
      'Lê Hồng Khánh',
      '0963003197',
      'Hà Nội',
      'IVNR1000001',
      '1',
      '5',
      'Sốt Virus',
      '37.5',
    );

    for (int i = 0; i < 100; i++) {
      switch (i % 3) {
        case 0:
          patient.nhietdo = '37';
          break;
        case 1:
          patient.nhietdo = '37.5';
          break;
        case 2:
          patient.nhietdo = '38.5';
          break;
        default:
          patient.nhietdo = '0';
      }
      patients.add(patient);
    }
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Trang chủ'),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              buildTableTitle(),
              horizontalLine(),
              buildListView(),
              horizontalLine(),
              // _applianceGrid(homes, newheight),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('STT', 3),
          verticalLine(),
          buildTextLabel('Tên', 15),
          verticalLine(),
          buildTextLabel('G', 2),
          verticalLine(),
          buildTextLabel('P', 2),
          verticalLine(),
          buildTempColumn(),
        ],
      ),
    );
  }

  Widget buildTempColumn() {
    return Expanded(
      flex: 4,
      child: Image.asset(
        'assets/images/thermometer.png',
        width: 20,
        height: 20,
        color: Colors.red,
      ),
    );
  }

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return itemView(index);
          },
        ),
      ),
    );
  }

  Widget itemView(int index) {
    return InkWell(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                //this right here
                child: Container(
                  child: EditPatientDialog(
                    patient: patients[index],
                    callback: (param) => {
                      removePatient(index),
                    },
                  ),
                ),
              );
            });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          children: [
            Container(
              color: double.parse(patients[index].nhietdo) > 38.5
                  ? Colors.yellow
                  : Colors.transparent,
              height: 40,
              child: Row(
                children: [
                  buildTextData('${index + 1}', 3),
                  verticalLine(),
                  buildTextData(patients[index].ten, 15),
                  verticalLine(),
                  buildTextData(patients[index].giuong, 2),
                  verticalLine(),
                  buildTextData(patients[index].phong, 2),
                  verticalLine(),
                  tempData(patients[index].nhietdo, 4),
                ],
              ),
            ),
            horizontalLine(),
          ],
        ),
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

  Widget tempData(String data, int flexValue) {
    return Expanded(
      child: Text(
        '$data\u2103',
        style: TextStyle(
            fontSize: 18,
            color: double.parse(data) > 37.4 ? Colors.red : Colors.black),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget verticalLine() {
    return Container(height: double.infinity, width: 1, color: Colors.grey);
  }

  Widget horizontalLine() {
    return Container(height: 1, width: double.infinity, color: Colors.grey);
  }

  Future<void> handle(String message) async {
    Map responseMap = jsonDecode(message);

    switch (homeAction) {
      case LOGIN_NHA:
        {
          if (responseMap['result'] == 'true') {
            response = DeviceResponse.fromJson(jsonDecode(message));

            rooms.clear();
            print('Home page: ${response.id}');
            rooms = response.id.map((e) => Room.fromJson(e)).toList();
            print('loginnha: ${rooms.length}');

            await Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => DepartmentPage(
                    loginResponse: loginResponse,
                    rooms: rooms,
                    home: seletedHome)));
          }
          break;
        }
      case DELETE_NHA:
        {
          if (responseMap['result'] == 'true') {
            setState(() {
              homes.removeAt(deletePosition);
            });
          }
          break;
        }
    }
  }

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }

  void _navigateEditPage(int typeOfEdit, int index) async {
    Home home = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            EditPage(iduser, homes[index], null, null, typeOfEdit)));
    setState(() {
      // homes.removeAt(index);
      // homes.add(home);
      homes[index].manha = home.manha;
      homes[index].tennha = home.tennha;
    });
  }

  void removePatient(int index) async {}
}

class SnackBarPage extends StatelessWidget {
  final String data;
  final String buttonLabel;

  SnackBarPage(this.data, this.buttonLabel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: Text(data),
            action: SnackBarAction(
              label: buttonLabel,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        },
        child: Text('Show SnackBar'),
      ),
    );
  }
}
