import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:tomato_project/provider/background_provider.dart';
import 'package:tomato_project/provider/mode_Provider.dart';
import 'package:tomato_project/provider/task_provider.dart';
import 'ClockPainter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late AudioPlayer _audioPlayer;
  late DateTime _now;

  Timer? _countdownTimer;

  int workDuration = 25;
  int breakDuration = 5;
  bool isTimerRunning = false;
  bool isMusicPlaying = false;
  bool isWorkMode = true;
  String nowTask = "Please select a task";
  double _progressRatio = 0.0;
  double _pausedAngle = -pi / 2;

  // 初始化狀態
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });

    _now = DateTime.now();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });

    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: workDuration * 60),
    )..addListener(() {
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
    super.dispose();
  }

  // 開始計時器
  void _startTimer() {
    setState(() => isTimerRunning = true);
    _animationController.forward();
  }

  // 暫停計時器
  void _pauseTimer() {
    _pausedAngle = -pi / 2 + (_progressRatio * 2 * pi);
    _animationController.stop();
    setState(() => isTimerRunning = false);
  }

  // 重置計時器
  void _resetTimer() {
    _animationController.reset();
    setState(() {
      isTimerRunning = false;
      _progressRatio = 0.0;
      _pausedAngle = -pi / 2;
    });
  }

  // 播放音樂
  Future<void> _playMusic() async {
    await _audioPlayer.play(AssetSource('birds-339196.mp3'));
    setState(() => isMusicPlaying = true);
  }

  // 停止音樂
  Future<void> _stopMusic() async {
    await _audioPlayer.stop();
    setState(() => isMusicPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final modeProvider = context.watch<ModeProvider>();
    if (nowTask != "Please select a task") {
      final exists = taskProvider.tasks.any(
        (task) => nowTask.contains(task["taskName"] ?? ""),
      );
      if (!exists) {
        setState(() {
          nowTask = "Please select a task";
        });
      }
    }
    final bg = Provider.of<BackgroundProvider>(context);
    return Scaffold(
      body: Container(
        decoration:
            bg.backgroundImage != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(bg.backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                )
                : bg.backgroundAssetImage != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bg.backgroundAssetImage!),
                    fit: BoxFit.cover,
                  ),
                )
                : BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bg.backgroundColor, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // 選擇任務按鈕
              _glassButton(nowTask, () {
                _chooseTaskDialog();
              }),
              const SizedBox(height: 8),
              Text(
                isWorkMode ? 'Work Time' : 'Rest Time',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: Center(
                  child:
                      modeProvider.isDigitalMode
                          ? _buildDigitalClock()
                          : _buildAnalogClock(),
                ),
              ),
              const SizedBox(height: 8),
              // 音樂和計時器控制按鈕
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _iconButton(
                    isMusicPlaying ? Icons.music_note : Icons.music_off,
                    isMusicPlaying ? _stopMusic : _playMusic,
                  ),
                  const SizedBox(width: 16),
                  _iconButton(
                    isTimerRunning ? Icons.stop : Icons.play_arrow,
                    isTimerRunning ? _pauseTimer : _startTimer,
                  ),
                  const SizedBox(width: 16),
                  _iconButton(Icons.refresh, _resetTimer),
                ],
              ),
              const SizedBox(height: 16),
              // 任務清單
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _glassCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              "Task List",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: taskProvider.tasks.length,
                            separatorBuilder:
                                (context, index) =>
                                    Divider(color: Colors.white24, height: 1),
                            itemBuilder: (context, index) {
                              final task = taskProvider.tasks[index];
                              return ListTile(
                                title: Text(
                                  task["taskName"] ?? "",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  "Work: ${task["workTime"] ?? 0} min | Rest: ${task["restTime"] ?? 0} min",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _chooseTaskDialog() async {
    final taskProvider = context.read<TaskProvider>();
    int? selectedIndex; // 用來記錄目前選中的任務 index

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // 讓 Dialog 內可以 setState
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Select Task",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (taskProvider.tasks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                "No tasks yet",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: SizedBox(
                              height: 400,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: taskProvider.tasks.length,
                                separatorBuilder:
                                    (context, index) =>
                                        Divider(color: Colors.white24),
                                itemBuilder: (context, index) {
                                  final task = taskProvider.tasks[index];
                                  final isSelected = selectedIndex == index;
                                  return ListTile(
                                    tileColor:
                                        isSelected
                                            ? Colors.white24.withOpacity(0.3)
                                            : Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      task["taskName"] ?? "",
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.amberAccent
                                                : Colors.white,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Work: ${task["workTime"] ?? 0} min | Rest: ${task["restTime"] ?? 0} min",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    onTap: () {
                                      setStateDialog(() {
                                        selectedIndex = index;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amberAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  selectedIndex == null
                                      ? null
                                      : () {
                                        final selectedTask =
                                            taskProvider.tasks[selectedIndex!];
                                        setState(() {
                                          nowTask =
                                              "'${selectedTask["taskName"]}' in progress";
                                        });
                                        Navigator.pop(context);
                                      },
                              child: const Text(
                                "select",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ====================== 自訂 Widget ======================

  Widget _glassButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    final bg = Provider.of<BackgroundProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bg.backgroundColor, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDigitalClock() {
    int totalSeconds = isWorkMode ? workDuration * 60 : breakDuration * 60;
    int elapsedSeconds = (_animationController.value * totalSeconds).round();
    int remainingSeconds = totalSeconds - elapsedSeconds;
    if (remainingSeconds < 0) remainingSeconds = 0;

    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Text(
      "$minutes:$seconds",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 64,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        shadows: [
          Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  Widget _buildAnalogClock() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ClockPainter(
            progressRatio: _progressRatio,
            workDuration: workDuration,
            breakDuration: breakDuration,
            isRunning: isTimerRunning,
            pausedNeedleAngle: _pausedAngle,
            pausedProgressRatio: _progressRatio,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}
