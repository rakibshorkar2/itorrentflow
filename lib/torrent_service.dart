import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'torrent_bridge.dart';
import 'models/torrent_status.dart';
import 'models/file_info.dart';

class TorrentService {
  final TorrentBridge _bridge = TorrentBridge.instance;
  List<TorrentStatus> _torrents = [];
  Timer? _pollTimer;
  String? _downloadPath;

  List<TorrentStatus> get torrents => List.unmodifiable(_torrents);

  Stream<List<TorrentStatus>> get statusStream => _statusController.stream;
  final _statusController = StreamController<List<TorrentStatus>>.broadcast();

  bool _initialized = false;

  Future<bool> initialize({
    String listenInterface = '0.0.0.0',
    int downloadLimit = 0,
    int uploadLimit = 0,
  }) async {
    _downloadPath = '${(await getApplicationDocumentsDirectory()).path}/downloads';
    final success = await _bridge.createSession(
      listenInterface: listenInterface,
      downloadLimit: downloadLimit,
      uploadLimit: uploadLimit,
    );
    if (success) {
      _initialized = true;
      _startPolling();
    }
    return success;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _refreshStatuses();
    });
  }

  Future<void> _refreshStatuses() async {
    try {
      _torrents = await _bridge.getAllStatuses();
      _statusController.add(List.from(_torrents));
    } catch (_) {}
  }

  Future<({int id, String? error})> addMagnet(String magnetUri, {bool streamOnly = false}) async {
    if (!_initialized) return (id: -1, error: 'Engine not initialized');
    final dir = Directory('${_downloadPath!}/torrents');
    if (!await dir.exists()) await dir.create(recursive: true);
    return await _bridge.addMagnet(magnetUri, dir.path, streamOnly: streamOnly);
  }

  Future<void> removeTorrent(int id, {bool deleteFiles = false}) async {
    if (!_initialized) return;
    await _bridge.removeTorrent(id, deleteFiles: deleteFiles);
    await _refreshStatuses();
  }

  Future<void> pauseTorrent(int id) async {
    if (!_initialized) return;
    await _bridge.pauseTorrent(id);
  }

  Future<void> resumeTorrent(int id) async {
    if (!_initialized) return;
    await _bridge.resumeTorrent(id);
  }

  Future<List<FileInfo>> getFiles(int torrentId) async {
    if (!_initialized) return [];
    return await _bridge.getFiles(torrentId);
  }

  Future<void> setDownloadLimit(int bytesPerSec) async {
    if (!_initialized) return;
    await _bridge.setDownloadLimit(bytesPerSec);
  }

  Future<void> setUploadLimit(int bytesPerSec) async {
    if (!_initialized) return;
    await _bridge.setUploadLimit(bytesPerSec);
  }

  Future<String?> getPendingMagnetURL() async {
    return await _bridge.getPendingMagnetURL();
  }

  Future<void> dispose() async {
    _pollTimer?.cancel();
    await _statusController.close();
    await _bridge.destroySession();
    _initialized = false;
  }
}
