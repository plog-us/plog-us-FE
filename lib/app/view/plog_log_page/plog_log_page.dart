import 'dart:convert';
import 'package:get/get.dart';
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as mhttp;
import 'package:plog_us/flavors/build_config.dart';

class PlogLogScreen extends StatefulWidget {
  const PlogLogScreen({super.key});

  @override
  State<PlogLogScreen> createState() => _PlogLogScreenState();
}

class _PlogLogScreenState extends State<PlogLogScreen> {
  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find<LoginController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("PlogLog"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: fetchData(loginController.userId.value),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                print(snapshot.data);
                return Flexible(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        index: index + 1,
                        title: snapshot.data[index]['ploggingTime'],
                        subtitle:
                            snapshot.data[index]['ploggingScore'].toString(),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future fetchData(String userUUid) async {
    var uri = Uri.parse(
        '${BuildConfig.instance.config.baseUrl}/plogginglog/list/$userUUid');
    //print('id : ${loginController.userId.value}');

    try {
      mhttp.Response response = await mhttp.get(uri);
      //resText = response.body;
      print(response.runtimeType);
      print("----------------------------------");
      print(response.body);
      print("----------------------------------");
      print(response.headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Container ListTile(
      {int index = 0, String title = "Nickname", String subtitle = "Score"}) {
    return Container(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.green, width: 1.0),
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(
              color: Colors.lightGreen,
              blurRadius: 0.5,
              spreadRadius: 0.0,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
        margin: const EdgeInsets.all(10.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Text(
              "$index. ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const Text(
              " : ",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  } // ListTile(Widget child) {}
}
