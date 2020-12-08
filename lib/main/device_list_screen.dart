import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_care/dialogWidget/edit_device_dialog.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/model/device.dart';

import '../helper/constants.dart' as Constants;

class DeviceListScreen extends StatefulWidget {
  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  Device device = Device(
    '_id',
    'iduser',
    'idnha',
    'idphong',
    'Thiết bị 1',
    'IVNR1000001',
    'Thân nhiệt',
    'Bật',
    'mac',
  );
  List<Device> devices = List();
  MQTTClientWrapper mqttClientWrapper;

  @override
  void initState() {
    for (int i = 0; i < 100; i++) {
      if (i.isEven) {
        device.isEnable = true;
      } else {
        device.isEnable = false;
      }
      devices.add(device);
    }
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleDevice(message));
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
          title: Text('Danh sách thiết bị'),
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
          buildTextLabel('Tên', 4),
          verticalLine(),
          buildTextLabel('Mã', 4),
          verticalLine(),
          buildTextLabel('Loại', 2),
          verticalLine(),
          buildTextLabel('Trạng thái', 2),
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
          itemCount: devices.length,
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
                  child: EditDeviceDialog(
                    device: devices[index],
                    callback: (param) => {
                      removeDevice(index),
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
              height: 40,
              child: Row(
                children: [
                  buildTextData('${index + 1}', 1),
                  verticalLine(),
                  buildTextData(devices[index].tentbDecode, 4),
                  verticalLine(),
                  buildTextData(devices[index].matb, 4),
                  verticalLine(),
                  buildTextData(devices[index].loaitb, 2),
                  verticalLine(),
                  buildTextData(devices[index].trangthai, 2),
                ],
              ),
            ),
            horizontalLine(),
          ],
        ),
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

  Widget buildStatusDevice(bool data, int flexValue) {
    return Expanded(
      child: data
          ? Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            )
          : Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
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

  void removeDevice(int index) async {
    setState(() {
      devices.remove(index);
    });
  }

  void handleDevice(String message) {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
