import 'package:flutter/material.dart';
import 'package:flutter_google_maps/detailTrip.dart';
import 'package:flutter_google_maps/profile.dart';
import 'package:flutter_google_maps/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'listpost.dart';
import 'main.dart';

class ListTripPage extends StatefulWidget {
  @override
  _ListTripPageState createState() => _ListTripPageState();
}

class _ListTripPageState extends State<ListTripPage> {
  List<Trip> trips = [];
  int driverId = 0;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    getAllTrip();
  }
  Future<void> getDetailTrip(int id) async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7238/api/Trip/GetDetailTrip?id=$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DetailTripPage(tripId: id)));
    }
  }

  Future<void> getAllTrip() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7238/api/Trip/GetAllTrips'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tripData = json.decode(response.body);
      setState(() {
        trips = tripData.map((data) => Trip.fromJson(data)).toList();
      });
    }
  }

  Icon _buildStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case 'Chưa nhận':
        iconData = Icons.access_alarm;
        iconColor = Colors.indigo;
        break;
      case 'Đã nhận đơn':
        iconData = Icons.alarm_on;
        iconColor = Colors.deepPurple;
        break;
      case 'Đang chạy':
        iconData = Icons.motorcycle;
        iconColor = Colors.deepOrange;
        break;
      case 'Hoàn thành':
        iconData = Icons.done;
        iconColor = Colors.green;
        break;
      default:
        // Trạng thái không xác định, sử dụng một mặc định hoặc hiển thị cảnh báo
        iconData = Icons.warning;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text('Lịch sử hoạt động'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                final timeBookString = trip.timeBook;
                final timeBookDateTime = DateTime.parse(timeBookString);
                final formattedDateTime =
                    DateFormat('dd-MM-yyyy HH:mm').format(timeBookDateTime);
                final startLocation = trip.startLocation.substring(0, 16);
                final endLocation = trip.endLocation.substring(0, 16);
                return Card(
                  child: ListTile(
                    leading: _buildStatusIcon(trip.status),
                    title: Text('Chuyến đi lúc $formattedDateTime'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$startLocation - $endLocation'),
                        Text('Giá: ${trip.price} đ'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await getDetailTrip(trip.tripId);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Họạt động',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Thông báo',
            backgroundColor: Colors.pink,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Tài Khoản',
            backgroundColor: Colors.cyanAccent,
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MapSample()));
          }
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ListTripPage()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PostPage()));
          }
          if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfilePage()));
          }
        },
      ),
    );
  }
}
