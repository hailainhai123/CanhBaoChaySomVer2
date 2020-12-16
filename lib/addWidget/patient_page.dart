import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/chart/animated_line_chart.dart';
import 'package:health_care/chart/area_line_chart.dart';
import 'package:health_care/chart/line_chart.dart';
import 'package:health_care/common/pair.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/user.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';
import 'fake_chart_series.dart';

class PatientPage extends StatefulWidget {
  PatientPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> with FakeChartSeries {
  int chartIndex = 0;
  MQTTClientWrapper mqttClientWrapper;
  User registerUser;
  Patient tempPatient = Patient(
    'BN11021',
    'Tên bệnh nhân',
    '099999999',
    'HN',
    'IVNR1000001',
    '1',
    '5',
    'Sốt Virus',
    39.0,
    'PS1',
    '1',
    '',
  );

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Timer timer;
  int minute = 40;

  @override
  void initState() {
    _idController.text = tempPatient.mabenhnhan;
    _nameController.text = tempPatient.ten;
    _informationController.text = tempPatient.mathietbi;
    _phoneNumberController.text = tempPatient.sdt;

    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => register(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
    super.initState();
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Thông tin bệnh nhân"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, double> line1 = createLine2();
    Map<DateTime, double> line2 = createLine2_2();

    LineChart chart;

    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      print('_PatientPageState.buildTimer');
      minute += 10;
      line1[DateTime.now().subtract(Duration(minutes: 50))] = 15.0;
      line1[DateTime.now().subtract(Duration(minutes: 60))] = 15.0;
      line1[DateTime.now().subtract(Duration(minutes: 70))] = 15.0;
      line1[DateTime.now().subtract(Duration(minutes: 80))] = 15.0;
      line1[DateTime.now().subtract(Duration(minutes: 90))] = 15.0;
      setState(() {});
    });

    if (chartIndex == 0) {
      chart = LineChart.fromDateTimeMaps(
          [line1, line2], [Colors.green, Colors.blue], ['C', 'C'],
          tapTextFontWeight: FontWeight.w400);
    } else if (chartIndex == 1) {
      chart = LineChart.fromDateTimeMaps(
          [createLineAlmostSaveValues()], [Colors.green], ['C'],
          tapTextFontWeight: FontWeight.w400);
    } else {
      chart = AreaLineChart.fromDateTimeMaps(
          [line1], [Colors.red.shade900], ['C'],
          gradients: [Pair(Colors.yellow.shade400, Colors.red.shade700)]);
    }

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildPatientInfo(),
                buildTempLayout(tempPatient.nhietdo),
                buildChart(chart),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientInfo() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${tempPatient.tenDecode}',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTempLayout(double temp) {
    return Container(
      width: 120,
      height: 70,
      decoration: BoxDecoration(
        color: temp > 37.5 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/thermometer.png',
            color: Colors.white,
            width: 25,
            height: 25,
          ),
          SizedBox(width: 5),
          Text(
            '$temp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChart(LineChart chart) {
    return Container(
      child: Expanded(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text(
                        'LineChart',
                        style: TextStyle(
                            color: chartIndex == 0
                                ? Colors.black
                                : Colors.black12),
                      ),
                      onPressed: () {
                        setState(() {
                          chartIndex = 0;
                        });
                      },
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text('LineChart2',
                          style: TextStyle(
                              color: chartIndex == 1
                                  ? Colors.black
                                  : Colors.black12)),
                      onPressed: () {
                        setState(() {
                          chartIndex = 1;
                        });
                      },
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.all(Radius.circular(3))),
                      child: Text('AreaChart',
                          style: TextStyle(
                              color: chartIndex == 2
                                  ? Colors.black
                                  : Colors.black12)),
                      onPressed: () {
                        setState(() {
                          chartIndex = 2;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedLineChart(
                  chart,
                  key: UniqueKey(),
                ), //Unique key to force animations
              )),
              // SizedBox(width: 200, height: 50, child: Text('')),
            ]),
      ),
    );
  }

  register(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      print('Login success');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    registerUser: registerUser,
                  )));
    } else {
      final snackBar = SnackBar(
        content: Text('Yay! A SnackBar!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      // Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
