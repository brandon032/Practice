import 'dart:async';
import 'package:eos_01/timer_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassApp extends StatefulWidget {
  const ClassApp({super.key});

  @override
  State<ClassApp> createState() => _ClassAppState();
}

class _ClassAppState extends State<ClassApp> {
  var _time = 0;
  var _timeSum = 0;
  var _isRunning = false;
  var _timer;
  List<TimerItem> timerItems = [];

  @override
  void initState() {
    super.initState();
    initializeTimerItems();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimer);
  }

  void initializeTimerItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? subjectNameList = prefs.getStringList("subjectNameList");
    if (subjectNameList == null) return;

    for (String subjectName in subjectNameList) {
      timerItems.add(TimerItem(subjectName));
    }
  }

  void _updateTimer(Timer timer) {
    setState(() {
      if (_isRunning) {
        _timeSum++;
        timerItems.forEach((element) {
          if (element.isRunning) element.time++;
        });
      }
      ;
    });
  }

  void _startTimer(index) {
    setState(() {
      _isRunning = true;
      for (int i = 0; i < timerItems.length; i++) {
        if (timerItems[i].isRunning) timerItems[i].isRunning = false;
      }
      timerItems[index].isRunning = true;
    });
  }

  void _pauseTimer(index) {
    setState(() {
      timerItems[index].isRunning = false;
      if (!timerItems.any((element) => element.isRunning)) _isRunning = false;
    });
  }

  void _resetTimer() {
    setState(() {
      _timeSum = 0;
      _isRunning = false;
      timerItems.forEach((element) {
        element.time = 0;
        element.isRunning = false;
      });
    });
  }

  void _resetEachTimer(index) {
    setState(() {
      _timeSum -= timerItems[index].time;
      timerItems[index].time = 0;
      _pauseTimer(index);
    });
  }

  void _saveItemToDatabase() async {
    final subjectNameList = timerItems.map((timer) => timer.name).toList();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("subjectNameList", subjectNameList);
  }

  void _addItem(String subjectName) {
    timerItems.add(TimerItem(subjectName));
    _saveItemToDatabase();
  }

  void _deleteItem(int index) {
    _resetEachTimer(index);
    timerItems.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    var secSum = (_timeSum % 60).toString().padLeft(2, "0");
    var minSum = ((_timeSum ~/ 60) % 60).toString().padLeft(2, "0");
    var hourSum = (_timeSum ~/ 3600).toString().padLeft(2, "0");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.dehaze),
              onPressed: () {},
            ),
            Center(
              child: const Text('EOS BASIC'),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController controller = TextEditingController();
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SizedBox(
                    height: 300,
                    child: Column(
                      children: [
                        Spacer(),
                        Text(
                          "과목명을 입력하시오",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: TextField(
                            controller: controller,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _addItem(controller.text);
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.check_circle_outline,
                            size: 40,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _resetTimer,
                child: Image.asset(
                  'assets/eos_logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              Text(
                "$hourSum:$minSum:$secSum",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 100,
              ),
              Divider(
                height: 3,
                color: Colors.black,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: timerItems.length,
                    itemBuilder: (context, index) {
                      var tme = timerItems[index].time;
                      var sec = (tme % 60).toString().padLeft(2, "0");
                      var min = ((tme ~/ 60) % 60).toString().padLeft(2, "0");
                      var hour = (tme ~/ 3600).toString().padLeft(2, "0");
                      return Dismissible(
                        key: ValueKey(timerItems[index]),
                        onDismissed: (_) {
                          _deleteItem(index);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.all(0),
                                          onPressed: () {
                                            timerItems[index].isRunning
                                                ? _pauseTimer(index)
                                                : _startTimer(index);
                                          },
                                          icon: timerItems[index].isRunning
                                              ? Icon(
                                                  Icons.pause_circle,
                                                  size: 40,
                                                  color: Colors.green,
                                                )
                                              : Icon(
                                                  Icons.play_circle,
                                                  size: 40,
                                                  color: Colors.green,
                                                ),
                                        ),
                                        if (timerItems[index].time != 0)
                                          IconButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () {
                                              _resetEachTimer(index);
                                            },
                                            icon: Icon(
                                              Icons.stop_circle,
                                              size: 40,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                      ]),
                                  Expanded(
                                    child: Text(
                                      timerItems[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    "$hour:$min:$sec",
                                    style: TextStyle(fontSize: 25),
                                  )
                                ],
                              ),
                            ),
                            Divider(
                              height: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
