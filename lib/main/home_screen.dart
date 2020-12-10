import 'package:flutter/material.dart';
import 'package:health_care/addWidget/add_page.dart';
import 'package:health_care/addWidget/add_patient_page.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/main/department_list_screen.dart';
import 'package:health_care/main/detail_page.dart';
import 'package:health_care/main/device_list_screen.dart';
import 'package:health_care/main/home_page.dart';
import 'package:health_care/main/user_list_screen.dart';
import 'package:health_care/main/user_profile_page.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.loginResponse}) : super(key: key);

  final Map loginResponse;

  @override
  _HomeScreenState createState() => _HomeScreenState(loginResponse);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState(this.loginResponse);

  final Map loginResponse;
  int _selectedIndex = 0;
  SharedPrefsHelper sharedPrefsHelper;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions;
  static List<BottomNavigationBarItem> bottomBarItems;

  @override
  void initState() {
    sharedPrefsHelper = SharedPrefsHelper();

    initBottomBarItems(loginResponse['quyen']);
    initWidgetOptions(loginResponse['quyen']);
    sharedPrefsHelper.addStringToSF('khoa', loginResponse['khoa']);
    super.initState();
  }

  void initBottomBarItems(int quyen) {
    switch (quyen) {
      case 1:
        bottomBarItems = [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle_outlined,
            ),
            label: 'Tài khoản',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
            ),
            label: 'Thiết bị',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.meeting_room_outlined,
            ),
            label: 'Khoa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Thêm',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_box_outlined,
            ),
            label: 'Cá nhân',
          ),
        ];
        break;
      case 2:
        bottomBarItems = [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.details,
            ),
            label: 'Cảnh báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu,
            ),
            label: 'Danh sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Thêm',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_box_outlined,
            ),
            label: 'Cá nhân',
          ),
        ];
        break;
    }
  }

  void initWidgetOptions(int quyen) {
    switch (quyen) {
      case 1:
        _widgetOptions = <Widget>[
          UserListScreen(
            response: loginResponse,
          ),
          DeviceListScreen(),
          DepartmentListScreen(),
          AddScreen(),
          UserProfilePage(
            quyen: '1',
          ),
        ];
        break;
      case 2:
        _widgetOptions = <Widget>[
          HomePage(),
          DetailPage(),
          AddPatientScreen(),
          UserProfilePage(
            quyen: '1',
          ),
        ];
        break;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: bottomBar(),
    );
  }

  Widget buildBody() {
    return Container(
      child: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  Widget bottomBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: Colors.blue,
        // sets the active color of the `BottomNavigationBar` if `Brightness` is light
        primaryColor: Colors.red,
        textTheme: Theme.of(context).textTheme.copyWith(
              caption: new TextStyle(color: Colors.white),
            ),
      ),
      child: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: bottomBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
