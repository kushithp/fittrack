enum AppThemeMode { system, light, dark }

/// User preference and profile settings.
class UserSettings {
  final String userName;
  final AppThemeMode themeMode;
  final bool enableNotifications;
  final bool hasLoadedDemoData;
  final DateTime? lastBackupDate;

  UserSettings({
    this.userName = 'Alex',
    this.themeMode = AppThemeMode.system,
    this.enableNotifications = true,
    this.hasLoadedDemoData = false,
    this.lastBackupDate,
  });

  UserSettings copyWith({
    String? userName,
    AppThemeMode? themeMode,
    bool? enableNotifications,
    bool? hasLoadedDemoData,
    DateTime? lastBackupDate,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      hasLoadedDemoData: hasLoadedDemoData ?? this.hasLoadedDemoData,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'themeMode': themeMode.name,
      'enableNotifications': enableNotifications,
      'hasLoadedDemoData': hasLoadedDemoData,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userName: (json['userName'] as String?) ?? 'Alex',
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      hasLoadedDemoData: json['hasLoadedDemoData'] as bool? ?? false,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
    );
  }
}
