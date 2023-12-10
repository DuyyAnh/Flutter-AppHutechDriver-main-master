import 'package:flutter/material.dart';
import 'package:flutter_google_maps/driver.dart';
import 'package:flutter_google_maps/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_google_maps/token.dart';

class DetailTripPage extends StatefulWidget {
  final int tripId;

  DetailTripPage({required this.tripId});
  @override
  _DetailTripState createState() => _DetailTripState();
}

class _DetailTripState extends State<DetailTripPage> {
  late Trip trip;
  String startLocation = "";
  String endLocation = "";
  String timeBook = "";
  double price = 0.0;
  String status = "";
  int userId = 0;
  int tripId = 0;
  String userName = "";
  String phone = "";
  int driverId = 0;
  String driverName = "";
  String phoneNumber = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    decodetoken(TokenManager.getToken());
    trip = new Trip(
        startLocation: startLocation,
        endLocation: endLocation,
        timeBook: timeBook,
        price: price,
        status: status,
        userId: userId,
        tripId: tripId); // Gọi hàm lấy chi tiết chuyến đi khi widget được tạo
    getTripDetails();
  }

  //Lấy chi tiết trip
  Future<void> getTripDetails() async {
    final response = await http.get(
      Uri.parse(
          'https://10.0.2.2:7238/api/Trip/GetDetailTrip?id=${widget.tripId}'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Xử lý dữ liệu và cập nhật state
      setState(() {
        trip = Trip.fromJson(json.decode(response.body));
        getUserInfo(trip.userId);
      });
    }
  }

  //Lấy chi tiết user
  Future<void> getUserInfo(int id) async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7238/api/Auth/UserInfo?id=$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        userName = responseData['fullName'];
        phone = responseData['phoneNumber'];
      });
    }
  }

  //giải mã
  Future<void> decodetoken(String Token) async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7238/api/Auth/DecodeToken?token=$Token'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    setState(() {
      driverId = int.parse(responseData['userId']);
      driverName = responseData['fullName'];
      phoneNumber = responseData['phoneNumber'];
      role = responseData['role'];
    });
  } else {
     debugPrint("Error: ${response.statusCode}");
     debugPrint("Response body: ${response.body}");
  }
  }

  //Chức năng chấp nhận
  Future<void> acceptTrip() async {
    // Kiểm tra nếu chuyến đi đã được chấp nhận rồi
    if (trip.driverId != 0 && trip.driverId != null) {
      // Hiển thị thông báo hoặc thực hiện các xử lý khác nếu cần
      print('Chuyến đi đã được chấp nhận.');
      return;
    }

    // Gọi API để cập nhật thông tin chuyến đi (ví dụ: /api/Trip/AcceptTrip)
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7238/api/Trip/AcceptTrip'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tripId': trip.tripId,
        'driverId': driverId, // Điền hàm để lấy id người dùng hiện tại
      }),
    );

    if (response.statusCode == 200) {
      // Nếu cập nhật thành công, cập nhật trạng thái trong ứng dụng
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nhận đơn thành công'),
            content:
                Text('Bạn có thể liên hệ với khách hàng qua số điện thoại'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Đóng dialog
                  Navigator.of(context).pop();

                  // Chuyển đến trang mới
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => DriverPage()));
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Text('Chi tiết chuyến đi'),
        ),
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child:
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          Card(
                            elevation: 10,
                            child: ListTile(
                                leading: Icon(
                                  Icons.access_time_outlined,
                                  color: Colors.black,
                                ),
                                title: Text('Thời gian \n${trip.timeBook}', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Card(
                            elevation: 10,
                            child: ListTile(
                              leading: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              title: Text('Người đặt: $userName',  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Card(
                            elevation: 10,
                            child: ListTile(
                              leading: Icon(
                                Icons.phone,
                                color: Colors.black,
                              ),
                              title: Text('SDT: $phone',  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Card(
                            elevation: 10,
                            child: ListTile(
                              leading: Icon(
                                Icons.attach_money,
                                color: Colors.black,
                              ),
                              title: Text('Giá: ${trip.price} đ',  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Card(
                            elevation: 10,
                            child: ListTile(
                              leading: Icon(
                                Icons.accessibility,
                                color: Colors.black,
                              ),
                              title: Text('Điểm đón \n${trip.startLocation}',  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          Card(
                            elevation: 10,
                            child: ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.black,
                              ),
                              title: Text('Điểm đến \n${trip.endLocation}',  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          if (trip.driverId == null && trip.driverId == 0)
                          Column(
                            children: [
                                Card(
                                  elevation: 10,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.accessibility,
                                      color: Colors.black,
                                    ),
                                    title: Text('Tên tài xế \n${driverName}', style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                              Card(
                                elevation: 10,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.phone,
                                    color: Colors.black,
                                  ),
                                  title: Text('SDT \n${phoneNumber}', style: TextStyle(fontSize: 20)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          if(role!="Member")
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                acceptTrip();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, side: BorderSide.none, shape: StadiumBorder()),
                              child: Text('Chấp nhận đơn'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ),
      ),
    );
  }
}
