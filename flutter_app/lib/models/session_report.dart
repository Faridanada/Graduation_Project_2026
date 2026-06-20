class SessionReport {
  DateTime? generatedAt;
  String model;
  String summary;
  SessionMetrics metrics;
  List<String> observations;
  List<Concern> concerns;
  List<String> recommendations;
  List<SafetyEvent> safetyEvents;

  SessionReport({
    this.generatedAt,
    required this.model,
    required this.summary,
    required this.metrics,
    this.observations = const [],
    this.concerns = const [],
    this.recommendations = const [],
    this.safetyEvents = const [],
  });

  factory SessionReport.fromJson(Map<String, dynamic> json) {
    return SessionReport(
      generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt']) : null,
      model: json['model'] ?? 'Unknown',
      summary: json['summary'] ?? '',
      metrics: SessionMetrics.fromJson(json['metrics'] ?? {}),
      observations: List<String>.from(json['observations'] ?? []),
      concerns: (json['concerns'] as List?)?.map((x) => Concern.fromJson(x)).toList() ?? [],
      recommendations: List<String>.from(json['recommendations'] ?? []),
      safetyEvents: (json['safetyEvents'] as List?)?.map((x) => SafetyEvent.fromJson(x)).toList() ?? [],
    );
  }
}

class SessionMetrics {
  MeasureValue duration;
  RangeOfMotionPair rangeOfMotion;
  PeakEmgPair peakEmg;
  SymmetryReading muscleSymmetry;
  FatigueReading fatigueIndex;
  int repetitionsCompleted;

  SessionMetrics({
    required this.duration,
    required this.rangeOfMotion,
    required this.peakEmg,
    required this.muscleSymmetry,
    required this.fatigueIndex,
    required this.repetitionsCompleted,
  });

  factory SessionMetrics.fromJson(Map<String, dynamic> json) {
    return SessionMetrics(
      duration: MeasureValue.fromJson(json['duration'] ?? {}),
      rangeOfMotion: RangeOfMotionPair.fromJson(json['rangeOfMotion'] ?? {}),
      peakEmg: PeakEmgPair.fromJson(json['peakEmg'] ?? {}),
      muscleSymmetry: SymmetryReading.fromJson(json['muscleSymmetry'] ?? {}),
      fatigueIndex: FatigueReading.fromJson(json['fatigueIndex'] ?? {}),
      repetitionsCompleted: json['repetitionsCompleted'] ?? 0,
    );
  }
}

class MeasureValue {
  double value;
  String unit;

  MeasureValue({required this.value, required this.unit});

  factory MeasureValue.fromJson(Map<String, dynamic> json) {
    return MeasureValue(
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }
}

class RomReading {
  double min;
  double max;
  double average;

  RomReading({required this.min, required this.max, required this.average});

  factory RomReading.fromJson(Map<String, dynamic> json) {
    return RomReading(
      min: (json['min'] ?? 0).toDouble(),
      max: (json['max'] ?? 0).toDouble(),
      average: (json['average'] ?? 0).toDouble(),
    );
  }
}

class RangeOfMotionPair {
  RomReading imu1;
  RomReading imu2;
  String unit;

  RangeOfMotionPair({required this.imu1, required this.imu2, required this.unit});

  factory RangeOfMotionPair.fromJson(Map<String, dynamic> json) {
    return RangeOfMotionPair(
      imu1: RomReading.fromJson(json['imu1'] ?? {}),
      imu2: RomReading.fromJson(json['imu2'] ?? {}),
      unit: json['unit'] ?? 'degrees',
    );
  }
}

class EmgReading {
  double peak;
  double rms;

  EmgReading({required this.peak, required this.rms});

  factory EmgReading.fromJson(Map<String, dynamic> json) {
    return EmgReading(
      peak: (json['peak'] ?? 0).toDouble(),
      rms: (json['rms'] ?? 0).toDouble(),
    );
  }
}

class PeakEmgPair {
  EmgReading emg1;
  EmgReading emg2;
  String unit;

  PeakEmgPair({required this.emg1, required this.emg2, required this.unit});

  factory PeakEmgPair.fromJson(Map<String, dynamic> json) {
    return PeakEmgPair(
      emg1: EmgReading.fromJson(json['emg1'] ?? {}),
      emg2: EmgReading.fromJson(json['emg2'] ?? {}),
      unit: json['unit'] ?? 'normalized',
    );
  }
}

class SymmetryReading {
  double score;
  String interpretation;

  SymmetryReading({required this.score, required this.interpretation});

  factory SymmetryReading.fromJson(Map<String, dynamic> json) {
    return SymmetryReading(
      score: (json['score'] ?? 0).toDouble(),
      interpretation: json['interpretation'] ?? '',
    );
  }
}

class FatigueReading {
  double emg1;
  double emg2;
  String interpretation;

  FatigueReading({required this.emg1, required this.emg2, required this.interpretation});

  factory FatigueReading.fromJson(Map<String, dynamic> json) {
    return FatigueReading(
      emg1: (json['emg1'] ?? 0).toDouble(),
      emg2: (json['emg2'] ?? 0).toDouble(),
      interpretation: json['interpretation'] ?? '',
    );
  }
}

class Concern {
  String severity; // 'low' | 'medium' | 'high'
  String type;
  String description;

  Concern({required this.severity, required this.type, required this.description});

  factory Concern.fromJson(Map<String, dynamic> json) {
    return Concern(
      severity: json['severity'] ?? 'low',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SafetyEvent {
  String type;
  DateTime? timestamp;
  double atSecond;
  String context;

  SafetyEvent({required this.type, this.timestamp, required this.atSecond, required this.context});

  factory SafetyEvent.fromJson(Map<String, dynamic> json) {
    return SafetyEvent(
      type: json['type'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
      atSecond: (json['atSecond'] ?? 0).toDouble(),
      context: json['context'] ?? '',
    );
  }
}

class SessionReportEnvelope {
  String reportStatus; // pending | processing | completed | failed
  SessionReport? report;
  DateTime? reportGeneratedAt;
  String? reportError;

  SessionReportEnvelope({
    required this.reportStatus,
    this.report,
    this.reportGeneratedAt,
    this.reportError,
  });

  factory SessionReportEnvelope.fromJson(Map<String, dynamic> json) {
    return SessionReportEnvelope(
      reportStatus: json['reportStatus'] ?? 'pending',
      report: json['report'] != null ? SessionReport.fromJson(json['report']) : null,
      reportGeneratedAt: json['reportGeneratedAt'] != null ? DateTime.tryParse(json['reportGeneratedAt']) : null,
      reportError: json['reportError'],
    );
  }
}

class SessionListItem {
  String id;
  DateTime startTime;
  DateTime? endTime;
  int? durationSeconds;
  String status;
  String reportStatus;
  String? summary;

  SessionListItem({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    required this.status,
    required this.reportStatus,
    this.summary,
  });

  factory SessionListItem.fromJson(Map<String, dynamic> json) {
    return SessionListItem(
      id: json['id'] ?? '',
      startTime: DateTime.tryParse(json['createdAt'] ?? json['startTime'] ?? '') ?? DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      durationSeconds: json['durationSeconds'],
      status: json['status'] ?? '',
      reportStatus: json['reportStatus'] ?? 'pending',
      summary: json['summary'],
    );
  }
}
