import 'package:flutter/material.dart';
import 'package:flutter_google_maps/post.dart';
import 'package:flutter_google_maps/profile.dart';
import 'package:flutter_google_maps/signIn.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'listtrip.dart';
import 'main.dart';
import 'dart:convert';

class PostPage extends StatefulWidget {
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Post> posts = [];
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    getAllPost();
  }
  Future<void> getAllPost() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7238/api/Post/getAllPost'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> postData = json.decode(response.body);
      setState(() {
        posts = postData.map((data) => Post.fromJson(data)).toList();
      });
    }
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
          padding: const EdgeInsets.all(90.0),
          child: Text('Thông báo'),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Tìm kiếm",
                    contentPadding: const EdgeInsets.all(16.0),
                    fillColor: Colors.black12,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    )),
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Slidable(
                      endActionPane: ActionPane(
                        extentRatio: .3,
                        motion: ScrollMotion(
                        ),
                        children: [
                          SlidableAction(
                            onPressed: (context) {}, icon: Icons.reply, backgroundColor: Colors.grey[300]!,
                          ),
                          SlidableAction(
                            onPressed: (context) {}, icon: Icons.delete, foregroundColor: Colors.white, backgroundColor: Colors.red[700]!,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 32,
                          child: Image.asset("assets/image/logo.png"),
                        ),
                        title: Text('${post.title}', style: TextStyle(fontWeight: FontWeight.w700),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${post.description}" , style: TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis,),
                            Text("${post.createdate}" , style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        // trailing: Icon(Icons.arrow_forward),
                        // onTap: () {},
                      ),
                  );
                },
              ),
            ),
          ],
        ),
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
