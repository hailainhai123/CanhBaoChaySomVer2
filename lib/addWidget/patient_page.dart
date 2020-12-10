import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/addWidget/line_chart.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/user.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

class PatientPage extends StatefulWidget {
  PatientPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  MQTTClientWrapper mqttClientWrapper;
  User registerUser;
  Patient tempPatient = Patient(
    'BN11021',
    'Tên bệnh nhân',
    '099999999',
    'Sốt Virus',
    '',
    '',
    '',
    '',
    0.0,
    '',
    '',
    '',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _success;
  String _userEmail;

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

  Widget _entryField(String title, TextEditingController _controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter some text!';
                }
                return null;
              },
              controller: _controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        print('submitButton onTap');
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.lightBlueAccent, Colors.blueAccent])),
        child: Text(
          'Lưu thông tin',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email", _idController),
        _entryField("Mật khẩu", _informationController, isPassword: true),
        _entryField("Tên", _nameController),
        _entryField("SĐT", _phoneNumberController),
      ],
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Thông tin bệnh nhân"),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  height: 20,
                ),
                _emailPasswordWidget(),
                SizedBox(
                  height: 20,
                ),
                buildLineChart(),
                _submitButton(),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
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

  Widget buildLineChart() {
    return SimpleTimeSeriesChart.withSampleData();
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
