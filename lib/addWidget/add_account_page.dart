import 'package:flutter/material.dart';

class AddAccountScreen extends StatefulWidget {
  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final scrollController = ScrollController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final makhoaController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() async {
    // nameController.text = widget.patient.ten;
    // phoneController.text = widget.patient.sdt;
    // addressController.text = widget.patient.nha;
    // idDeviceController.text = widget.patient.matb;
    // roomController.text = widget.patient.phong;
    // bedController.text = widget.patient.giuong;
    // patientController.text = widget.patient.benhan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm bệnh nhân',
        ),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: scrollController,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTextField(
                  'Username',
                  Icon(Icons.email),
                  TextInputType.text,
                  usernameController,
                ),
                buildTextField(
                  'Mật khẩu',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  passwordController,
                ),
                buildTextField(
                  'Mã Khoa',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  makhoaController,
                ),
                buildTextField(
                  'Tên',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  nameController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  addressController,
                ),
                buildTextField(
                  'Số điện thoại',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  phoneController,
                ),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, Icon prefixIcon,
      TextInputType keyboardType, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
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
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    makhoaController.dispose();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
