import 'package:flutter/material.dart';
import 'package:flutter_google_maps/detailTrip.dart';
import 'package:flutter_google_maps/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_google_maps/token.dart';
class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  List<Trip> trips = [];
  String selectedStatus = 'Chưa nhận';
  int driverId = 0;
  String locationIP = "";
  
  // Map to group statuses together
  Map<String, List<String>> statusGroups = {
    'Chưa nhận': ['Chưa nhận'],
    'Đã nhận': [
      'Đã nhận đơn',
      'Đang chạy',
      'Hoàn thành'
    ], 
  };
Future<List<Trip>> filterTrips() async {
  final double maxDistance = 5000; // Khoảng cách tối đa trong mét (5 km)
  List<Trip> filteredList = [];
  for (var trip in trips) {
    if (selectedStatus == 'Chưa nhận') {
      if (trip.status == 'Chưa nhận') {
        // Lấy tọa độ từ tên địa điểm
        LatLng? destinationCoordinates =
            await getCoordinatesFromAddress(trip.startLocation);
        if (destinationCoordinates != null) {
          // Tính khoảng cách giữa điểm xuất phát của chuyến đi và vị trí tài xế
          double distance = await calculateDistance(
            destinationCoordinates,
          );

          // Chỉ thêm vào danh sách nếu khoảng cách nhỏ hơn 5 km
          if (distance < maxDistance) {
            filteredList.add(trip);
          }
        }
      }
    } else {
      if (trip.status != 'Chưa nhận' && trip.driverId == driverId) {
        filteredList.add(trip);
      }
    }
  }

  return filteredList;
}
LatLng convertStringToLatLng(String ip) {
  List<String> coordinates = ip.split(',');
  double latitude = double.parse(coordinates[0]);
  double longitude = double.parse(coordinates[1]);
  return LatLng(latitude, longitude);
}
 @override
  void initState() {
    super.initState();
    getAllTrip();
    decodetoken(TokenManager.getToken());
  }
  //hàm tính khoảng cách
 Future<double> calculateDistance(LatLng point1) async {
 LatLng location = convertStringToLatLng(locationIP);
  return Geolocator.distanceBetween(
    point1.latitude,
    point1.longitude,
    location.latitude,
    location.longitude,
  );
}
//hàm đổi địa chỉ thành lng
Future<LatLng?> getCoordinatesFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    print('Error getting coordinates: $e');
  }
  return null;
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
        locationIP = responseData['location'];
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
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
          padding: const EdgeInsets.all(50.0),
          child: Text('Danh sách đơn đặt xe'),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: statusGroups.keys.map((status) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedStatus = status;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: status == selectedStatus ? Colors.blue : null,
                ),
                child: Text(status),
              );
            }).toList(),
          ),
       Expanded(
        child: FutureBuilder<List<Trip>>(
        future: filterTrips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Đang đợi dữ liệu
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Xử lý lỗi
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Không có dữ liệu hoặc danh sách rỗng
            return Text('Không có chuyến đi nào phù hợp.');
          } else {
        // Hiển thị danh sách chuyến đi đã lọc
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final trip = snapshot.data![index];
            final timeBookString = trip.timeBook;
            final timeBookDateTime = DateTime.parse(timeBookString);
            final formattedDateTime =
                DateFormat('dd-MM-yyyy HH:mm').format(timeBookDateTime);
            final startLocation = trip.startLocation.substring(0, 16);
            final endLocation = trip.endLocation.substring(0, 16);

            return Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Chuyến đi lúc $formattedDateTime',
                    style: TextStyle(fontSize: 20)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$startLocation - $endLocation',
                        style: TextStyle(fontSize: 20)),
                    Text('Giá: ${trip.price} đ', style: TextStyle(fontSize: 20)),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () async {
                  await getDetailTrip(trip.tripId);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
