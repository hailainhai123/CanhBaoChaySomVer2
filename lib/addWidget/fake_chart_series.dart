class FakeChartSeries {
  Map<DateTime, double> createLineData(double factor) {
    Map<DateTime, double> data = {};

    for (int c = 50; c > 0; c--) {
      data[DateTime.now().subtract(Duration(minutes: c))] =
          c.toDouble() * factor;
    }

    return data;
  }

  Map<DateTime, double> createLineAlmostSaveValues() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 24.9;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 25.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 25.0;

    return data;
  }

  Map<DateTime, double> createLine1() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;

    return data;
  }

  Map<DateTime, double> createLine2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;
    return data;
  }

  Map<DateTime, double> createLine2_2() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(minutes: 40))] = 37.0;
    data[DateTime.now().subtract(Duration(minutes: 30))] = 37.1;
    data[DateTime.now().subtract(Duration(minutes: 22))] = 37.3;
    data[DateTime.now().subtract(Duration(minutes: 20))] = 37.5;
    data[DateTime.now().subtract(Duration(minutes: 15))] = 37.9;
    data[DateTime.now().subtract(Duration(minutes: 12))] = 40.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 37.0;
    return data;
  }

  Map<DateTime, double> createLine3() {
    Map<DateTime, double> data = {};
    data[DateTime.now().subtract(Duration(days: 6))] = 1100.0;
    data[DateTime.now().subtract(Duration(days: 5))] = 2233.0;
    data[DateTime.now().subtract(Duration(days: 4))] = 3744.0;
    data[DateTime.now().subtract(Duration(days: 3))] = 3100.0;
    data[DateTime.now().subtract(Duration(days: 2))] = 2900.0;
    data[DateTime.now().subtract(Duration(days: 1))] = 1100.0;
    data[DateTime.now().subtract(Duration(minutes: 5))] = 3700.0;
    return data;
  }
}
