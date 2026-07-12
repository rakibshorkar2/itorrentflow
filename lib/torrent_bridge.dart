import 'package:flutter/services.dart';
import 'models/torrent_status.dart';
import 'models/file_info.dart';

class TorrentBridge {
  static const _channel = MethodChannel('com.torrent.app/bridge');

  TorrentBridge._();

  static final TorrentBridge instance = TorrentBridge._();

  Future<bool> createSession({
    String listenInterface = '0.0.0.0',
    int downloadLimit = 0,
    int uploadLimit = 0,
  }) async {
    final result = await _channel.invokeMethod<bool>('createSession', {
      'listenInterface': listenInterface,
      'downloadLimit': downloadLimit,
      'uploadLimit': uploadLimit,
    });
    return result ?? false;
  }

  Future<void> destroySession() async {
    await _channel.invokeMethod('destroySession');
  }

  Future<({int id, String? error})> addMagnet(String uri, String savePath, {bool streamOnly = false}) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('addMagnet', {
      'uri': uri,
      'savePath': savePath,
      'streamOnly': streamOnly ? 1 : 0,
    });
    if (result == null) return (id: -1, error: 'No response from native');
    final id = result['id'] as int;
    final error = result['error'] as String?;
    return (id: id, error: error);
  }

  Future<void> removeTorrent(int id, {bool deleteFiles = false}) async {
    await _channel.invokeMethod('removeTorrent', {
      'id': id,
      'deleteFiles': deleteFiles ? 1 : 0,
    });
  }

  Future<void> pauseTorrent(int id) async {
    await _channel.invokeMethod('pauseTorrent', {'id': id});
  }

  Future<void> resumeTorrent(int id) async {
    await _channel.invokeMethod('resumeTorrent', {'id': id});
  }

  Future<void> recheckTorrent(int id) async {
    await _channel.invokeMethod('recheckTorrent', {'id': id});
  }

  Future<int> getTorrentCount() async {
    final result = await _channel.invokeMethod<int>('getTorrentCount');
    return result ?? 0;
  }

  Future<List<TorrentStatus>> getAllStatuses() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getAllStatuses');
    if (result == null) return [];
    return result.map((e) => TorrentStatus.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<FileInfo>> getFiles(int torrentId) async {
    final result = await _channel.invokeMethod<List<dynamic>>('getFiles', {'id': torrentId});
    if (result == null) return [];
    return result.map((e) => FileInfo.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<bool> configureSession(Map<String, dynamic> config) async {
    final result = await _channel.invokeMethod<bool>('configureSession', config);
    return result ?? false;
  }

  Future<void> setDownloadLimit(int bytesPerSec) async {
    await _channel.invokeMethod('setDownloadLimit', {'bytesPerSec': bytesPerSec});
  }

  Future<void> setUploadLimit(int bytesPerSec) async {
    await _channel.invokeMethod('setUploadLimit', {'bytesPerSec': bytesPerSec});
  }

  Future<String> getVersion() async {
    final result = await _channel.invokeMethod<String>('version');
    return result ?? '';
  }

  Future<String?> getPendingMagnetURL() async {
    final result = await _channel.invokeMethod<String>('getPendingMagnetURL');
    return result;
  }
}
