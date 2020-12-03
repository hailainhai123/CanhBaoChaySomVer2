import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/device/edit_page.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/model/device.dart';
import 'package:health_care/model/home.dart';
import 'package:health_care/model/room.dart';
import 'package:health_care/response/device_response.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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

  Widget _backButton() {
    return InkWell(
      onTap: () {
        _onWillPop();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            // Text('Back',
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.white))
          ],
        ),
      ),
    );
  }

  void initOneSignal(oneSignalAppId) {
    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    };
    OneSignal.shared.init(oneSignalAppId, iOSSettings: settings);
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
// will be called whenever a notification is received
    OneSignal.shared
        .setNotificationReceivedHandler((OSNotification notification) {
      print('Received: ' + notification?.payload?.body ?? '');
    });
// will be called whenever a notification is opened/button pressed.
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('Opened: ' + result.notification?.payload?.body ?? '');
    });
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    initOneSignal(Constants.one_signal_app_id);
    response = DeviceResponse.fromJson(loginResponse);

    iduser = response.message;
    homes = response.id.map((e) => Home.fromJson(e)).toList();
    print('_HomePageState.initState: ${homes.length}');
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
          buildTextLabel('STT', 1),
          verticalLine(),
          buildTextLabel('Tên', 5),
          verticalLine(),
          buildTextLabel('G', 1),
          verticalLine(),
          buildTextLabel('P', 1),
          verticalLine(),
          buildTextLabel('K', 1),
          verticalLine(),
          buildTempColumn(),
        ],
      ),
    );
  }

  Widget buildTempColumn() {
    return Expanded(
      flex: 2,
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
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: homes.length,
        itemBuilder: (context, index) {
          return itemView(index);
        },
      ),
    );
  }

  Widget itemView(int index) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 40,
            child: Row(
              children: [
                buildTextData('${index + 1}', 1),
                verticalLine(),
                buildTextData('Nguyễn Văn Aaaaaaaaaa', 5),
                verticalLine(),
                buildTextData('1', 1),
                verticalLine(),
                buildTextData('2', 1),
                verticalLine(),
                buildTextData('3', 1),
                verticalLine(),
                tempData('38', 2),
              ],
            ),
          ),
          horizontalLine(),
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
            color: double.parse(data) > 37.5 ? Colors.red : Colors.black),
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

  Widget _applianceGrid(List<Home> homes, double newheight) {
    return Container(
        alignment: Alignment.topCenter,
        // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        height: newheight - 150,
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          padding: EdgeInsets.all(5),
          children: List.generate(homes.length, (index) {
            return homes.isNotEmpty
                ? _buildApplianceCard(homes, index)
                : Container(
                    height: 120,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    margin: index % 3 == 0
                        ? EdgeInsets.fromLTRB(15, 7.5, 7.5, 7.5)
                        : EdgeInsets.fromLTRB(7.5, 7.5, 15, 7.5),
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 10,
                              offset: Offset(0, 10),
                              color: Color(0xfff1f0f2))
                        ],
                        color: Colors.white,
                        border: Border.all(
                            width: 1,
                            style: BorderStyle.solid,
                            color: Color(0xffa3a3a3)),
                        borderRadius: BorderRadius.circular(20)),
                    child: FloatingActionButton(
                      heroTag: 'btn2',
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  );
          }),
        ));
  }

  Widget _buildApplianceCard(List<Home> homes, int index) {
    return GestureDetector(
      child: InkWell(
        child: Container(
          height: 200,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: index % 2 == 0
              ? EdgeInsets.fromLTRB(5, 5, 5, 5)
              : EdgeInsets.fromLTRB(5, 5, 5, 5),
          decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(1.0, 1.0),
                )
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white]),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    'assets/images/pharmacy.png',
                    width: 30,
                    height: 30,
                    color: Colors.red,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, size: 35),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              //this right here
                              child: Container(
                                height: 160,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vui lòng chọn',
                                      ),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        width: 320.0,
                                        child: RaisedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(this);
                                            _navigateEditPage(
                                                Constants.EDIT_HOME, index);
                                          },
                                          child: Text(
                                            "Sửa thông tin",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: const Color(0xFF1BC0C5),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 320.0,
                                        child: RaisedButton(
                                          onPressed: () {
                                            setState(() {
                                              print('Item OnLongPressed');
                                              Navigator.of(context).pop(false);
                                              _deleteHome(homes[index]);
                                              deletePosition = index;
                                            });
                                          },
                                          child: Text(
                                            "Xóa",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: const Color(0xFF1BC0C5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Text(
              //   '${rooms[index].numberOfDevices} bệnh nhân',
              //   style: TextStyle(
              //       color: rooms[index].isEnable
              //           ? Colors.white
              //           : Color(0xff302e45),
              //       fontSize: 25,
              //       fontWeight: FontWeight.w600),
              // ),
              Flexible(
                  child: Text(
                homes[index].tennha != null
                    ? '${homes[index].tennhaDecode}'
                    : 'Tên nhà',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    // color: homes[index].isEnable
                    //     ? Colors.white
                    //     : Color(0xff302e45),
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              )),
              SizedBox(height: 5),
              Flexible(
                child: Text(
                  homes[index].manha != null
                      ? '${homes[index].manha}'
                      : 'Mã nhà',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      // color: homes[index].isEnable ? Colors.white : Colors.red,
                      // fontWeight: FontWeight.w600,
                      // : Color(0xffa3a3a3),
                      fontSize: 16),
                ),
              ),
              // Icon(model.allYatch[index].topRightIcon,color:model.allYatch[index].isEnable ? Colors.white : Color(0xffa3a3a3))
            ],
          ),
        ),
        onTap: () async {
          seletedHome = homes[index];
          Home home = new Home('', iduser, '${homes[index].tennha}',
              '${homes[index].manha}', Constants.mac);
          String json = jsonEncode(home);
          publishMessage('loginnha', json);
          homeAction = LOGIN_NHA;
        },
      ),
      onLongPress: () {
        //onLongPress
      },
    );
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
