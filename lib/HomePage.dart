import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tomato_project/SettingPage.dart';
import 'package:tomato_project/TaskPage.dart';
import 'ClockPainter.dart';
import 'dart:math';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;

  Timer? _countdownTimer;

  // 宣告變數
  int workDuration = 25;
  int breakDuration = 5;
  int totalDurationInSeconds = 1500;
  bool isTimerRunning = false;
  bool isTimerPaused = false;
  bool isMusicPlaying = false;
  bool isWorkMode = true;
  bool onTask = false;
  bool showModel = false;
  String nowTask = "Please select a task";
  double _progressRatio = 0.0;
  double _pausedAngle = -pi / 2; // 暫停時保留指針角度
  double _pausedProgressRatio = 0.0;

  // 初始化資源
  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 1), // totalDurationInSeconds
    // );
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1500), // 25分鐘
    )
      ..addListener(() {
        setState(() {
          _progressRatio = _animationController.value;
          if (!isTimerRunning) {
            _pausedAngle = -pi / 2 + (_progressRatio * 2 * pi);
          }
        });
      });
  }

  // 釋放資源
  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    // _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // 開始計時
  void _startTimer() {
    setState(() => isTimerRunning = true);
    _animationController.forward();
  }

  // 停止計時
  void _pauseTimer() {
    if (!isTimerRunning) return;
    _pausedAngle = -pi / 2 + (_progressRatio * 2 * pi); // 暫停時記錄目前角度
    _pausedProgressRatio = _progressRatio;
    _countdownTimer?.cancel(); // 停止倒數
    _animationController.stop(); // 停止動畫
    setState(() => isTimerRunning = false); // 切換狀態
  }

  // 重設計時
  void _resetTimer() {
    _countdownTimer?.cancel();
    _animationController.reset();

    setState(() {
      isTimerRunning = false;
      _animationController.reset();
      _progressRatio = 0.0;
      _pausedProgressRatio = 0.0;
      _pausedAngle = -pi / 2;
    });
  }

  // 播放音樂
  Future<void> _playMusic() async {
    await _audioPlayer.play(AssetSource('birds-339196.mp3')); // 播放 assets 音樂
    print("音樂播放中...");
    setState(() {
      isMusicPlaying = true;
    });
  }

  // 停止播放音樂
  Future<void> _stopMusic() async {
    await _audioPlayer.stop(); // 停止播放
    setState(() {
      isMusicPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade400, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _chooseTaskDialog();
                  },
                  child: Text(
                      nowTask,
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                ),
                SizedBox(height: 8),
                // 工作/休息時間顯示
                Text(
                  isWorkMode ? 'Work Time' : 'Rest Time',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // 計時器顯示
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ClockPainter(
                        progressRatio: _progressRatio,
                        workDuration: 25,
                        breakDuration: 5,
                        isRunning: isTimerRunning,
                        pausedNeedleAngle: _pausedAngle,
                        pausedProgressRatio: _pausedProgressRatio,
                      ),
                      size: Size(300, 300),
                    );
                  },
                ),
                SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 背景音樂播放鈕
                      IconButton(
                        onPressed: isMusicPlaying ? _stopMusic : _playMusic,
                        icon:
                            isMusicPlaying
                                ? Icon(Icons.music_note_sharp)
                                : Icon(Icons.music_off_sharp),
                        iconSize: 42,
                      ),
                      // 計時開始暫停鈕
                      IconButton(
                        onPressed: isTimerRunning ? _pauseTimer : _startTimer,
                        icon:
                            isTimerRunning
                                ? Icon(Icons.stop)
                                : Icon(Icons.play_arrow),
                        iconSize: 42,
                      ),
                      // 計時重置鈕
                      IconButton(
                        onPressed: () {
                          _resetTimer();
                        },
                        icon: Icon(Icons.refresh),
                        iconSize: 42,
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 8, // 視覺層次
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              "Task List",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ListTile(
                              title: Text("write program"),
                              subtitle: Text("work 0 minute,\nrest 0 minute"),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  // await TaskStorage.deleteTask(index);
                                  // setState(() {
                                  //   tasks.removeAt(index);
                                  // });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 1,
                              child: Container(color: Colors.grey),
                            ),
                            ListTile(
                              title: Text("read english"),
                              subtitle: Text("work 0 minute, rest 0 minute"),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _chooseTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Task"),
          content: SizedBox(
            height: 250, // 給定固定高度
            width: double.maxFinite,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                ListTile(
                  title: Text("read english"),
                  subtitle: Text("work 0 minute,\nrest 0 minute"),
                  onTap: () {
                    setState(() {
                      nowTask = "'read english' in progress";
                    });
                    Navigator.pop(context); // 關閉 dialog
                  },
                ),
                Divider(),
                ListTile(
                  title: Text("write program"),
                  subtitle: Text("work 0 minute,\nrest 0 minute"),
                  onTap: () {
                    setState(() {
                      nowTask = "'write program' in progress";
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateTimerMode() {
    int workTimeInSeconds = workDuration * 60;
    int elapsedSeconds =
        ((workDuration + breakDuration) * 60) - totalDurationInSeconds;
    setState(() {
      isWorkMode = elapsedSeconds < workTimeInSeconds;
    });
  }
}
