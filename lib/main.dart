import 'dart:async';

import 'package:flutter/material.dart';

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners =
      <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle =
      const TextStyle(fontSize: 30.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Schulte Table",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Dependencies dependencies = new Dependencies();
  int minutes = 0;
  int seconds = 0;
  int hundreds = 0;
  Timer timer;
  Duration duration;
  int milliseconds;
  int count;
  int nextNum;
  int curNum;
  int secondsPassed;
  int millPassed;
  List<int> data = List<int>();
  List<String> rankList = List<String>();
  AnimationController controller;
  Animation<Color> animation;
  bool tcVisibility = false;
  bool tbVisibility = false;
  bool colour = false;
  int bestScore;
  String timerText = "";

  void leftButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        print("${dependencies.stopwatch.elapsedMilliseconds}");
        dependencies.stopwatch.reset();
      }
      init(25);
    });
  }

  void rightButtonPressed() {
    setState(() {
      dependencies.stopwatch.reset();
      dependencies.stopwatch.start();
      init(25);

      tcVisibility = true;
    });
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    timer = new Timer.periodic(
        new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate),
        callback);
    dependencies.timerListeners.add(onTick);
    init(25);
    super.initState();
  }

  void init(int count) {
    this.count = count;
    nextNum = 0;
    curNum = 0;
    secondsPassed = 0;
    millPassed = 0;
    animation = ColorTween(
      begin: Colors.white,
      end: Colors.green,
    ).animate(controller);
    data = List.generate(count, (index) => index + 1)..shuffle();
  }

  void startTick() {
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      ++millPassed;
      if (millPassed == 10) {
        millPassed = 0;
        ++secondsPassed;
      }
      setState(() {});
    });
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes ||
        elapsed.seconds != seconds ||
        elapsed.hundreds != hundreds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  Widget buildFloatingButton(String text, VoidCallback callback) {
    TextStyle roundTextStyle =
        const TextStyle(fontSize: 16.0, color: Colors.white);
    return new FloatingActionButton(
        child: new Text(text, style: roundTextStyle), onPressed: callback);
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(
        title: Text("Schulte Table"),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            tcVisibility
                ? Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('$minutesStr:$secondsStr.$hundredsStr',
                            style: TextStyle(fontSize: 30)),
                      ),
                      Expanded(
                          child: Text(
                        'Current: $nextNum',
                        style: TextStyle(fontSize: 30),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                      ))
                    ],
                  )
                : new Container(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 5,
                children: List.generate(count, (index) {
                  return InkWell(
                    onTap: () async {
                      curNum = data[index];
                      if (nextNum + 1 == curNum) {
                        ++nextNum;
                        animation = ColorTween(
                          begin: Colors.white,
                          end: Colors.green,
                        ).animate(controller)
                          ..addListener(() {
                            setState(() {});
                          });
                      } else {
                        animation = ColorTween(
                          begin: Colors.white,
                          end: Colors.red,
                        ).animate(controller)
                          ..addListener(() {
                            setState(() {});
                          });
                      }
                      await controller.forward();
                      await controller.reverse();
                      if (nextNum == count) {
                        nextNum++;
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Tebrikler',
                            textAlign: TextAlign.center,
                          ),
                        ));
                        setState(() {
                          nextNum = 25;
                          print(
                              "${dependencies.stopwatch.elapsedMilliseconds}");
                          dependencies.stopwatch.stop();
                          if (bestScore == null) {
                            tbVisibility = true;
                            bestScore =
                                dependencies.stopwatch.elapsedMilliseconds;
                            timerText = "$minutesStr:$secondsStr.$hundredsStr";
                          } else if (dependencies
                                  .stopwatch.elapsedMilliseconds <
                              bestScore) {
                            tbVisibility = true;
                            bestScore =
                                dependencies.stopwatch.elapsedMilliseconds;
                            timerText = "$minutesStr:$secondsStr.$hundredsStr";
                          }
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        color: curNum == data[index]
                            ? animation.value
                            : Colors.white,
                      ),
                      child: Text(
                        '${data[index]}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              flex: 0,
              child: new Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    tcVisibility
                        ? Text("Best Score: " + '$timerText',
                            style: TextStyle(fontSize: 20))
                        : Text(""),
                    buildFloatingButton(
                        dependencies.stopwatch.isRunning ? "reset" : "start",
                        dependencies.stopwatch.isRunning
                            ? leftButtonPressed
                            : rightButtonPressed),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
