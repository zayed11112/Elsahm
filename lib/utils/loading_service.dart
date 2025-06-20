import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'loading_route.dart';
import 'data_loading_route.dart';

/// خدمة مركزية للتحكم بالتحميل في جميع أنحاء التطبيق
class LoadingService {
  static final LoadingService _instance = LoadingService._internal();
  static bool _debugMode = false;

  factory LoadingService() => _instance;

  LoadingService._internal();

  /// تمكين وضع التصحيح لعرض سجلات تفصيلية
  static set debugMode(bool value) => _debugMode = value;

  /// ضبط وقت التحميل الافتراضي
  static Duration defaultMinimumLoadingTime = const Duration(
    milliseconds: 1500,
  );

  /// ضبط حجم مؤشر التحميل الافتراضي
  static double defaultIndicatorSize = 120;

  /// التنقل باستخدام أنيميشن التحميل
  static Future<T?> navigateWithLoading<T>({
    required BuildContext context,
    required Widget page,
    Duration? minimumLoadingTime,
    bool replaceCurrent = false,
    Color? backgroundColor,
    double? indicatorSize,
  }) {
    if (_debugMode) {
      debugPrint('🔄 التنقل مع التحميل: ${page.runtimeType.toString()}');
    }

    // استخدم القيم الافتراضية إذا لم يتم تحديد قيم مخصصة
    final route = LoadingRoute<T>(
      page: page,
      minimumLoadingTime: minimumLoadingTime ?? defaultMinimumLoadingTime,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      indicatorSize: indicatorSize ?? defaultIndicatorSize,
    );

    // استخدم أحدث frame لتشغيل الانتقال (مهم لضمان سلاسة UI)
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _performNavigation(context, route, replaceCurrent);
      });
      return Future.value(null);
    } else {
      return _performNavigation(context, route, replaceCurrent);
    }
  }

  /// التنقل مع تحميل البيانات
  static Future<T?> navigateWithDataLoading<T, D>({
    required BuildContext context,
    required Future<D> Function() dataLoader,
    required Widget Function(BuildContext, D) pageBuilder,
    Duration? minimumLoadingTime,
    bool replaceCurrent = false,
    Color? backgroundColor,
    double? indicatorSize,
  }) {
    if (_debugMode) {
      debugPrint('🔄 التنقل مع تحميل البيانات: [${D.toString()}]');
    }

    final route = DataLoadingRoute<T, D>(
      dataLoader: dataLoader,
      buildPageWithData: pageBuilder,
      minimumLoadingTime: minimumLoadingTime ?? defaultMinimumLoadingTime,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      indicatorSize: indicatorSize ?? defaultIndicatorSize,
    );

    // استخدم أحدث frame لتشغيل الانتقال (مهم لضمان سلاسة UI)
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _performNavigation(context, route, replaceCurrent);
      });
      return Future.value(null);
    } else {
      return _performNavigation(context, route, replaceCurrent);
    }
  }

  /// تنفيذ الانتقال فعلياً
  static Future<T?> _performNavigation<T>(
    BuildContext context,
    PageRouteBuilder<T> route,
    bool replaceCurrent,
  ) {
    if (replaceCurrent) {
      return Navigator.pushReplacement(context, route);
    } else {
      return Navigator.push(context, route);
    }
  }
}
