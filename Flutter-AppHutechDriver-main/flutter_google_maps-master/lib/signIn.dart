import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/forgotPassword.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_google_maps/main.dart';
import 'package:flutter_google_maps/driver.dart';
import 'package:flutter_google_maps/register.dart';
import 'package:flutter_google_maps/token.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String userRole = "";
  String locationIP = "";
  late String lat;
  late String long;
  Future<void> decodetoken(String Token) async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7238/api/Auth/DecodeToken?token=$Token'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      userRole = responseData['role'];
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }
  //Chức năng lấy địa chỉ GPS của tài xế
  Future<void> getCurrentLocation() async{
    bool serviceEnable = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnable){
      Geolocator.openAppSettings();
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Dịch vụ lấy vị trí bị từ chối.');
      }
    }
     if (permission == LocationPermission.deniedForever) {
       return Future.error('Dịch vụ lấy vị trí bị từ chối vĩnh viễn! Tôi không thể lấy vị trí của bạn');
     }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      locationIP = '${position.latitude},${position.longitude}';
    });
    login();
  }
  Future<void> login() async {
    final Map<String, dynamic> data = {
      'userName': usernameController.text,
      'passWord': passwordController.text,
      'locationIP' : locationIP,
    };

    final response = await http.post(
      Uri.parse('https://10.0.2.2:7238/api/Auth/Login'),
      body: jsonEncode(data), // Chuyển đổi dữ liệu thành JSON
      headers: {
        'Content-Type':
            'application/json', // Đặt header Content-Type thành application/json
      },
    );

    if (response.statusCode == 200) {
      // Xử lý đăng nhập thành công
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['token'] != null) {
        TokenManager.setToken(responseData['token']);
        decodetoken(responseData['token']);
        if (userRole == "Member") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
        } else if (userRole == "Driver") {
          Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DriverPage()),
              );
        }
      } else {
        debugPrint("Error: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    }
  }

  bool isObscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.all(140.0),
              child: Text('Đăng nhập'),
            ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              SizedBox(
                height: 45,
              ),
              Image.asset('assets/image/logo.png',width: 300.0, height: 180.0,),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: Text(
                  'HUTECH DRIVER',
                  style: TextStyle(fontSize: 30, color: Color(0xff333333), fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Đăng nhập để sử dụng dịch vụ đặt xe',
                style: TextStyle(fontSize: 18, color: Color(0xff606470) , fontWeight: FontWeight.w700),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 80, 0, 20),
                child: TextField(
                  controller: usernameController,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: 'Tài khoản',
                      prefixIcon: Container(
                        width: 50,
                        child: Icon(
                           Icons.person_outline,
                        )
                      ),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffCED0D2), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(6)))),
                ),
              ),
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  TextField(
                    controller: passwordController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    obscureText: isObscurePassword,
                    decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: Container(
                          width: 50,
                          child: Image.asset('assets/image/ic_lock.png'),
                        ),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xffCED0D2), width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6)))),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isObscurePassword = !isObscurePassword;
                      });
                    },
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            GestureDetector(
              onTap: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              );
              },
              child: Container(
              constraints: BoxConstraints.loose(Size(double.infinity, 30)),
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
              'Quên mật khẩu?',
              style: TextStyle(fontSize: 16, color: Color(0xff3277D8)),
              ),
              ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: getCurrentLocation,
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                child: RichText(
                    text: TextSpan(
                        text: 'Bạn là người mới? ',
                        style: TextStyle(color: Color(0xff606470), fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                                },
                              text: 'Đăng ký tài khoản mới',
                              style: TextStyle(
                                  color: Color(0xff3277D8), fontSize: 16
                              )
                          )
                        ]
                    )
                ),
              )
            ]
          ),
      ),
      )
      );
  }
}
