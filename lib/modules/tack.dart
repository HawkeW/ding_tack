import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

abstract class AbstractTackMission {
  /// 是否是在线任务
  abstract bool online;

  /// 任务id
  abstract String id;

  /// 持续时间
  abstract Duration time;

  /// 剩余时间
  abstract Duration runTime;

  /// 开始时间
  abstract DateTime? startTime;

  /// 结束时间。未结束则为空
  abstract DateTime? endTime;

  /// 暂停时间
  abstract DateTime? pauseTime;

  /// 描述/笔记
  abstract String? description;
}

class TackMission extends ChangeNotifier implements AbstractTackMission {
  @override
  String? description;

  @override
  DateTime? endTime;

  @override
  String id;

  @override
  Duration runTime;

  @override
  bool online;

  @override
  DateTime? pauseTime;

  @override
  DateTime? startTime;

  @override
  Duration time;

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'endTime': endTime,
      'id': id,
      'runTime': runTime.inSeconds,
      'online': online,
      'pauseTime': pauseTime,
      'startTime': startTime,
      'time': time.inSeconds,
    };
  }

  TackMission({
    required this.id,
    required this.time,
    required this.runTime,
    required this.online,
    this.description,
    this.endTime,
    this.pauseTime,
    this.startTime,
  });

  factory TackMission.fromMap(Map<String, dynamic> map) {
    return TackMission(
      description: map['description'] as String,
      endTime: DateTime.parse(map['endTime'] as String),
      id: map['id'] as String,
      runTime: Duration(seconds: map['runTime'] as int),
      online: map['online'] as bool,
      pauseTime: DateTime.parse(map['pauseTime'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      time: Duration(seconds: map['time'] as int),
    );
  }

  TackMission copyWith({
    String? description,
    DateTime? endTime,
    String? id,
    Duration? runTime,
    bool? online,
    DateTime? pauseTime,
    DateTime? startTime,
    Duration? time,
  }) {
    return TackMission(
      description: description ?? this.description,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
      runTime: runTime ?? this.runTime,
      online: online ?? this.online,
      pauseTime: pauseTime ?? this.pauseTime,
      startTime: startTime ?? this.startTime,
      time: time ?? this.time,
    );
  }

  double get percent {
    var total = time.inSeconds;
    var ran = runTime.inSeconds;
    return startTime == null ? 0 : (ran / total) * 100;
  }

  bool get isRunning {
    return startTime != null && leftTime.inSeconds > 0;
  }

  bool get isPausing {
    return pauseTime != null;
  }

  bool get isCompleted {
    return leftTime.inSeconds == 0;
  }

  Duration get leftTime {
    var total = time.inSeconds;
    var ran = runTime.inSeconds;
    return Duration(seconds: total - ran);
  }
}

class TackMissionController extends TackMission {
  TackMissionController({required super.id, required super.time, required super.runTime, required super.online});

  pauseTo() {
    pauseTime = DateTime.now();
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  addTime(Duration time) {
    if(time.isNegative && time.inSeconds + runTime.inSeconds <= 0) {
      return;
    }
    this.time = Duration(seconds: time.inSeconds + this.time.inSeconds);
    notifyListeners();
  }

  continueTo() {
    pauseTime = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(timer.isActive) {
        var seconds = leftTime.inSeconds;
        if(seconds == 0) {
          timer.cancel();
          stopTo();
          _timer = null;
          return;
        }
        runTime = Duration(seconds: runTime.inSeconds + 1);
        notifyListeners();
      }
    });
    notifyListeners();
  }

  startTo() {
    startTime = DateTime.now();
    continueTo();
    notifyListeners();
  }

  stopTo() {
    _timer = null;
    notifyListeners();
  }

  Timer? _timer;
}