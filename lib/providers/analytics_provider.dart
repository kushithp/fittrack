import 'package:flutter/foundation.dart';
import '../data/models/analytics_point.dart';
import '../data/models/score_config.dart';
import '../data/models/streak_info.dart';
import '../data/repositories/analytics_repository.dart';
import '../data/services/database_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;
  final IDatabaseService _db;

  AnalyticsMetric _selectedMetric = AnalyticsMetric.steps;
  AnalyticsTimeframe _timeframe = AnalyticsTimeframe.daily;
  ScoreConfig _scoreConfig = const ScoreConfig();

  List<AnalyticsPoint> _chartPoints = [];
  StreakInfo? _streakInfo;
  Map<String, double> _heatmapData = {};
  double _todayFitnessScore = 82.0;

  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsProvider(this._repository, this._db);

  AnalyticsMetric get selectedMetric => _selectedMetric;
  AnalyticsTimeframe get timeframe => _timeframe;
  ScoreConfig get scoreConfig => _scoreConfig;
  List<AnalyticsPoint> get chartPoints => _chartPoints;
  StreakInfo? get streakInfo => _streakInfo;
  Map<String, double> get heatmapData => _heatmapData;
  double get todayFitnessScore => _todayFitnessScore;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _scoreConfig = await _db.getScoreConfig();
      await refreshAnalytics();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load analytics: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshAnalytics() async {
    final now = DateTime.now();
    _todayFitnessScore = await _repository.calculateDailyFitnessScore(now, _scoreConfig);
    _streakInfo = await _repository.calculateStreaks();
    _heatmapData = await _repository.getHeatmapIntensityData(28); // Past 4 weeks heatmap
    _chartPoints = await _repository.getChartDataPoints(
      metric: _selectedMetric,
      timeframe: _timeframe,
    );
    notifyListeners();
  }

  Future<void> setSelectedMetric(AnalyticsMetric metric) async {
    _selectedMetric = metric;
    _chartPoints = await _repository.getChartDataPoints(
      metric: _selectedMetric,
      timeframe: _timeframe,
    );
    notifyListeners();
  }

  Future<void> setTimeframe(AnalyticsTimeframe tf) async {
    _timeframe = tf;
    _chartPoints = await _repository.getChartDataPoints(
      metric: _selectedMetric,
      timeframe: _timeframe,
    );
    notifyListeners();
  }

  Future<void> saveScoreConfig(ScoreConfig config) async {
    _scoreConfig = config;
    await _db.saveScoreConfig(config);
    await refreshAnalytics();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
