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
  abstract Duration leftTime;

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
  Duration leftTime;

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
      'leftTime': leftTime,
      'online': online,
      'pauseTime': pauseTime,
      'startTime': startTime,
      'time': time,
    };
  }

  TackMission({
    required this.id,
    required this.time,
    required this.leftTime,
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
      leftTime: Duration(seconds: map['leftTime'] as int),
      online: map['online'] as bool,
      pauseTime: DateTime.parse(map['pauseTime'] as String),
      startTime: DateTime.parse(map['startTime'] as String),
      time: map['time'] as Duration,
    );
  }

  TackMission copyWith({
    String? description,
    DateTime? endTime,
    String? id,
    Duration? leftTime,
    bool? online,
    DateTime? pauseTime,
    DateTime? startTime,
    Duration? time,
  }) {
    return TackMission(
      description: description ?? this.description,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
      leftTime: leftTime ?? this.leftTime,
      online: online ?? this.online,
      pauseTime: pauseTime ?? this.pauseTime,
      startTime: startTime ?? this.startTime,
      time: time ?? this.time,
    );
  }

  get percent {
    var total = time.inSeconds;
    var left = leftTime.inSeconds;
    return startTime == null ? 0 : ((total - left )/ total) * 100;
  }
}

class TackMissionController extends TackMission {
  TackMissionController({required super.id, required super.time, required super.leftTime, required super.online});

  pauseTo() {
    pauseTime = DateTime.now();
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  setTime(Duration time) {
    this.time = time;
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
        leftTime = Duration(seconds: seconds - 1);
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
    leftTime = Duration.zero;
    _timer = null;
    notifyListeners();
  }

  Timer? _timer;
}