import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/user.dart';

import '../helper/constants.dart' as Constants;

class EditUserDialog extends StatefulWidget {
  final User user;
  final List<String> dropDownItems;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditUserDialog({
    Key key,
    this.user,
    this.dropDownItems,
    this.updateCallback,
    this.deleteCallback,
  }) : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog>
    with SingleTickerProviderStateMixin {
  static const UPDATE_USER = 'updateuser';
  static const DELETE_USER = 'deleteuser';
  static const CHANGE_PASSWORD = 'updatepass';
  static const GET_DEPARTMENT = 'loginkhoa';

  final scrollController = ScrollController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final departmentController = TextEditingController();
  final permissionController = TextEditingController();

  final List<Tab> myTabs = <Tab>[
    Tab(
      icon: Icon(Icons.edit),
      text: 'Thông tin',
    ),
    Tab(
      icon: Icon(Icons.security),
      text: 'Mật khẩu',
    ),
  ];

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  User updatedUser;
  String pubTopic = '';
  String currentSelectedValue;
  TabController _tabController;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();
    initMqtt();
    initController();
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  void handle(String message) {
    print('_EditUserDialogState.handle $message');
    Map responseMap = jsonDecode(message);

    if (responseMap['errorCode'] != '0' || responseMap['result'] != 'true') {
      return;
    }
    switch (pubTopic) {
      case UPDATE_USER:
        widget.updateCallback(updatedUser);
        Navigator.pop(context);
        break;
      case CHANGE_PASSWORD:
        Navigator.pop(context);
        break;
      case DELETE_USER:
        widget.deleteCallback('true');
        Navigator.pop(context);
        Navigator.pop(context);
        break;
    }
  }

  void initController() async {
    emailController.text = widget.user.user;
    passwordController.text = widget.user.pass;
    nameController.text = widget.user.tenDecode;
    phoneController.text = widget.user.sdt;
    addressController.text = widget.user.nhaDecode;
    departmentController.text = widget.user.khoa;
    permissionController.text = widget.user.quyen;
    currentSelectedValue = widget.user.khoa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
        title: Text('Tài khoản'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          updateUserTab(),
          changePasswordTab(),
        ],
      ),
    );
  }

  Widget changePasswordTab() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextField(
                'Username',
                Icon(Icons.vpn_key),
                TextInputType.text,
                emailController,
              ),
              buildTextField(
                'Mật khẩu cũ',
                Icon(Icons.vpn_key),
                TextInputType.text,
                passwordController,
                obscure: true,
              ),
              buildTextField(
                'Mật khẩu mới',
                Icon(Icons.vpn_key),
                TextInputType.text,
                newPasswordController,
                obscure: true,
              ),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget updateUserTab() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextField(
                'Username',
                Icon(Icons.email),
                TextInputType.text,
                emailController,
              ),
              buildTextField(
                'password',
                Icon(Icons.vpn_key),
                TextInputType.text,
                passwordController,
                obscure: true,
              ),
              buildTextField(
                'Tên',
                Icon(Icons.perm_identity),
                TextInputType.text,
                nameController,
              ),
              buildTextField(
                'SĐT',
                Icon(Icons.phone_android),
                TextInputType.text,
                phoneController,
              ),
              buildTextField(
                'Địa chỉ',
                Icon(Icons.location_city),
                TextInputType.text,
                addressController,
              ),
              // buildTextField(
              //   'Khoa',
              //   Icon(Icons.location_city),
              //   TextInputType.text,
              //   departmentController,
              // ),
              buildTextField(
                'Quyền',
                Icon(Icons.location_city),
                TextInputType.text,
                permissionController,
              ),
              widget.user.quyen == '1' ? Container() : buildDepartment(),
              deleteButton(),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String labelText,
    Icon prefixIcon,
    TextInputType keyboardType,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      child: TextField(
        obscureText: obscure,
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        enabled:
            labelText == 'Username' || labelText == 'password' ? false : true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: labelText,
          // labelStyle: ,
          // hintStyle: ,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          // suffixIcon: Icon(Icons.account_balance_outlined),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget deleteButton() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 86,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(1.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: new Text(
                'Xóa tài khoản ?',
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => widget.updateCallback(updatedUser),
                  child: new Text(
                    'Hủy',
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    pubTopic = DELETE_USER;
                    var u = User(Constants.mac, widget.user.user,
                        widget.user.pass, '', '', '', '', '', '');
                    publishMessage(pubTopic, jsonEncode(u));
                  },
                  child: new Text(
                    'Đồng ý',
                  ),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            Text(
              'Xóa tài khoản',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 32,
      ),
      child: Row(
        children: [
          Expanded(
            child: FlatButton(
              onPressed: () {
                Navigator.pop(context);
                widget.updateCallback('abc');
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                switch (_tabController.index) {
                  case 0:
                    pubTopic = UPDATE_USER;
                    _tryEdit();
                    break;
                  case 1:
                    pubTopic = CHANGE_PASSWORD;
                    changePass();
                    break;
                }
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDepartment() {
    return Container(
      height: 44,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.green,
        ),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Khoa',
            ),
          ),
          Expanded(
            child: dropdownDepartment(),
          ),
        ],
      ),
    );
  }

  Widget dropdownDepartment() {
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Chọn khoa"),
          value: currentSelectedValue,
          isDense: true,
          onChanged: (newValue) {
            setState(() {
              currentSelectedValue = newValue;
            });
            print(currentSelectedValue);
          },
          items: widget.dropDownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _tryEdit() async {
    updatedUser = User(
      Constants.mac,
      emailController.text,
      passwordController.text,
      utf8.encode(nameController.text).toString(),
      phoneController.text,
      utf8.encode(addressController.text).toString(),
      currentSelectedValue,
      permissionController.text,
      '',
    );
    updatedUser.iduser = await sharedPrefsHelper.getStringValuesSF('iduser');
    publishMessage(pubTopic, jsonEncode(updatedUser));
  }

  Future<void> changePass() async {
    updatedUser = User(
      Constants.mac,
      emailController.text,
      passwordController.text,
      utf8.encode(nameController.text).toString(),
      phoneController.text,
      utf8.encode(addressController.text).toString(),
      currentSelectedValue,
      permissionController.text,
      '',
    );
    updatedUser.passmoi = newPasswordController.text;
    updatedUser.iduser = await sharedPrefsHelper.getStringValuesSF('iduser');
    ChangePassword changePassword = ChangePassword(updatedUser.user,
        updatedUser.pass, updatedUser.passmoi, updatedUser.mac);
    publishMessage(pubTopic, jsonEncode(changePassword));
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

  @override
  void dispose() {
    scrollController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    departmentController.dispose();
    permissionController.dispose();
    newPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

class ChangePassword {
  final String user;
  final String pass;
  final String passmoi;
  final String mac;

  ChangePassword(this.user, this.pass, this.passmoi, this.mac);

  Map<String, dynamic> toJson() => {
        'user': user,
        'pass': pass,
        'passmoi': passmoi,
        'mac': mac,
      };
}
