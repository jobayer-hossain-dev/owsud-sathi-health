import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SyncAction {
  final String id;
  final String method; // POST, PUT, DELETE
  final String endpoint;
  final Map<String, dynamic> data;
  final String createdAt;

  SyncAction({
    required this.id,
    required this.method,
    required this.endpoint,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'endpoint': endpoint,
        'data': data,
        'createdAt': createdAt,
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        id: json['id'],
        method: json['method'],
        endpoint: json['endpoint'],
        data: Map<String, dynamic>.from(json['data'] ?? {}),
        createdAt: json['createdAt'],
      );
}

class SyncQueueService {
  static const String _keyQueue = 'offline_sync_queue';

  static Future<void> enqueue(String method, String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final currentQueue = await getQueue();
    final action = SyncAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      method: method,
      endpoint: endpoint,
      data: data,
      createdAt: DateTime.now().toIso8601String(),
    );
    currentQueue.add(action);
    final rawList = currentQueue.map((a) => a.toJson()).toList();
    await prefs.setString(_keyQueue, jsonEncode(rawList));
  }

  static Future<List<SyncAction>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_keyQueue);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str);
      return decoded.map((item) => SyncAction.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyQueue);
  }

  static Future<void> processQueue(ApiService apiService) async {
    final queue = await getQueue();
    if (queue.isEmpty) return;

    final remainingQueue = <SyncAction>[];

    for (final action in queue) {
      try {
        if (action.method == 'POST') {
          await apiService.client.post(action.endpoint, data: action.data);
        } else if (action.method == 'PUT') {
          await apiService.client.put(action.endpoint, data: action.data);
        } else if (action.method == 'DELETE') {
          await apiService.client.delete(action.endpoint, data: action.data);
        }
      } on DioException catch (e) {
        // If server is still unreachable, retain action in queue
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          remainingQueue.add(action);
        }
      } catch (_) {
        // Drop malformed requests
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final rawList = remainingQueue.map((a) => a.toJson()).toList();
    await prefs.setString(_keyQueue, jsonEncode(rawList));
  }
}