import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as mhttp;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  //var resText = "";
  var curState = "plogging";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    curState == "plogging" ? Colors.green : Colors.grey,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    curState == "plogging" ? Colors.white : Colors.black,
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.all(10.0),
                  ),
                ),
                onPressed: () {
                  print("plogging");
                  setState(() {
                    curState = "plogging";
                  });
                },
                child: const Text("plogging"),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    curState == "quiz" ? Colors.green : Colors.grey,
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    curState == "quiz" ? Colors.white : Colors.black,
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.all(10.0),
                  ),
                ),
                onPressed: () {
                  print("quiz");
                  setState(() {
                    curState = "quiz";
                  });
                },
                child: const Text("quiz"),
              ),
            ],
          ),
          FutureBuilder(
            future: fetchData("plogging"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (curState == "plogging") {
                print(snapshot.data);
                return Flexible(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        index: index + 1,
                        title: snapshot.data[index]['username'],
                        subtitle: snapshot.data[index]['totalPloggingScore']
                            .toString(),
                      );
                    },
                  ),
                );
              }
              return const Text("");
            },
          ),
          FutureBuilder(
            future: fetchData("quiz"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else if (curState == "quiz") {
                //return Text(snapshot.data.toString());
                print(snapshot.data);
                return Flexible(
                  child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        index: index + 1,
                        title: snapshot.data[index]['username'],
                        subtitle:
                            snapshot.data[index]['totalQuizScore'].toString(),
                      );
                    },
                  ),
                );
              }
              return const Text("");
            },
          ),
        ],
      ),
    );
  }

  Future fetchData(String query) async {
    var uri = Uri.parse("http://35.212.137.41:8080/leaderboard/$query");

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
