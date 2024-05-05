import 'dart:convert';
import 'package:get/get.dart';
import 'package:plog_us/app/controllers/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as mhttp;
import 'package:plog_us/flavors/build_config.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    LoginController loginController = Get.find<LoginController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
              future: fetchData(loginController.userId.value),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(
                    heightFactor: 10,
                    widthFactor: 10,
                    child: Text("Todays Quiz is done"),
                  );
                } else {
                  print(snapshot.data);
                  return Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      alignment: Alignment.center,
                      transformAlignment: Alignment.center,
                      padding: const EdgeInsets.all(10.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 1.0),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 0.5,
                            spreadRadius: 0.0,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${snapshot.data['questionContext']}",
                            style: const TextStyle(fontSize: 22),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (snapshot.data['questionCorrect'] == 'O') {
                                    print("정답");
                                    showDialog(
                                      context: context,
                                      builder: acDialog,
                                    );
                                    uploadQuiz(
                                      "correct",
                                      loginController.userId.value,
                                      snapshot.data['questionUuid'],
                                    );
                                  } else {
                                    print("오답");
                                    showDialog(
                                      context: context,
                                      builder: waDialog,
                                    );
                                    uploadQuiz(
                                      "incorrect",
                                      loginController.userId.value,
                                      snapshot.data['questionUuid'],
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.green,
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(10.0),
                                  ),
                                ),
                                child: const Text("O"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (snapshot.data['questionCorrect'] == 'X') {
                                    print("정답");
                                    showDialog(
                                      context: context,
                                      builder: acDialog,
                                    );
                                    uploadQuiz(
                                      "correct",
                                      loginController.userId.value,
                                      snapshot.data['questionUuid'],
                                    );
                                  } else {
                                    print("오답");
                                    showDialog(
                                      context: context,
                                      builder: waDialog,
                                    );
                                    uploadQuiz(
                                      "incorrect",
                                      loginController.userId.value,
                                      snapshot.data['questionUuid'],
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.red,
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(10.0),
                                  ),
                                ),
                                child: const Text("X"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

  Widget acDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Quiz'),
      shadowColor: Colors.green,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text("정답입니다!!"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget waDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Quiz'),
      shadowColor: Colors.red,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text("오답입니다ㅠㅠ"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future fetchData(String userUUid) async {
    var uri =
        Uri.parse('${BuildConfig.instance.config.baseUrl}/quiz/$userUUid');
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
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print(e);
      throw Exception("Error: $e");
    }
  }

  Future<void> uploadQuiz(String ans, String userUuid, int quizUuid) async {
    String apiUrl =
        '${BuildConfig.instance.config.baseUrl}/quiz/$ans/$userUuid/$quizUuid';
    print('upload quiz : $apiUrl');
    try {
      mhttp.Response response = await mhttp.post(Uri.parse(apiUrl));
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
}
