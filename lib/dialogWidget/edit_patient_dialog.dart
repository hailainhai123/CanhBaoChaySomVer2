import 'package:flutter/material.dart';
import 'package:health_care/model/patient.dart';

class EditPatientDialog extends StatefulWidget {
  final Patient patient;
  final Function(dynamic) callback;

  const EditPatientDialog({
    Key key,
    this.patient,
    this.callback,
  }) : super(key: key);

  @override
  _EditPatientDialogState createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  final scrollController = ScrollController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final idDeviceController = TextEditingController();
  final roomController = TextEditingController();
  final bedController = TextEditingController();
  final patientController = TextEditingController();

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() async {
    nameController.text = widget.patient.ten;
    phoneController.text = widget.patient.sdt;
    addressController.text = widget.patient.nha;
    idDeviceController.text = widget.patient.matb;
    roomController.text = widget.patient.phong;
    bedController.text = widget.patient.giuong;
    patientController.text = widget.patient.benhan;
  }

  @override
  Widget build(BuildContext context) {
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
                buildTempLayout(
                  double.parse(widget.patient.nhietdo),
                ),
                buildTextField(
                  'Tên',
                  Icon(Icons.email),
                  TextInputType.text,
                  nameController,
                ),
                buildTextField(
                  'SĐT',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  phoneController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  addressController,
                ),
                buildTextField(
                  'Mã thiết bị',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  idDeviceController,
                ),
                buildTextField(
                  'Phòng',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  roomController,
                ),
                buildTextField(
                  'Giường',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  bedController,
                ),
                buildTextField(
                  'Bệnh án',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  patientController,
                ),
                deleteButton(),
                buildButton(),
              ],
            ),
          ),
        ),
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

  Widget deleteButton() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 86,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
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
                'Xóa bệnh nhân ?',
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: new Text(
                    'Hủy',
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    widget.callback(true);
                    Navigator.of(context).pop(false);
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
              'Xóa bệnh nhân',
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
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    idDeviceController.dispose();
    roomController.dispose();
    bedController.dispose();
    patientController.dispose();
    super.dispose();
  }
}
