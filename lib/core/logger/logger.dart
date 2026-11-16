import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { info, debug, warn, error, success, trace }

/// Tagged, timestamped console logging, following the Reelstay logger pattern.
abstract final class Logger {
  static bool isEnabled = kDebugMode;
  static bool showTimestamp = true;

  @visibleForTesting
  static void Function(String message)? output;

  static void info({required Object? message, required String tag}) =>
      _log(message, tag, LogLevel.info);

  static void debug({required Object? message, required String tag}) =>
      _log(message, tag, LogLevel.debug);

  static void success({required Object? message, required String tag}) =>
      _log(message, tag, LogLevel.success);

  static void warn({required Object? message, required String tag}) =>
      _log(message, tag, LogLevel.warn);

  static void trace({required Object? message, required String tag}) =>
      _log(message, tag, LogLevel.trace);

  static void error({
    required Object? message,
    required String tag,
    StackTrace? stackTrace,
  }) => _log(message, tag, LogLevel.error, stackTrace);

  static void _log(
    Object? message,
    String tag,
    LogLevel level, [
    StackTrace? stackTrace,
  ]) {
    if (!isEnabled) return;
    final (label, emoji, color) = switch (level) {
      LogLevel.info => ('INFO', 'ℹ️', 36),
      LogLevel.debug => ('DEBUG', '🐛', 34),
      LogLevel.success => ('SUCCESS', '✅', 32),
      LogLevel.warn => ('WARN', '⚠️', 33),
      LogLevel.error => ('ERROR', '❌', 31),
      LogLevel.trace => ('TRACE', '📍', 35),
    };
    final now = DateTime.now();
    final timestamp = showTimestamp
        ? '(${[now.hour, now.minute, now.second].map((value) => value.toString().padLeft(2, '0')).join(':')}) '
        : '';
    String text;
    try {
      text = message is Map || message is List
          ? const JsonEncoder.withIndent('  ').convert(message)
          : message.toString();
    } catch (_) {
      text = message.toString();
    }
    final formatted =
        '\x1B[${color}m[$label] $timestamp$emoji [${tag.toUpperCase()}] $text\x1B[0m';
    if (output case final writer?) {
      writer(formatted);
      return;
    }
    developer.log(
      formatted,
      name: tag.toUpperCase(),
      level: level == LogLevel.error ? 1000 : 800,
      stackTrace: stackTrace,
    );
  }
}
