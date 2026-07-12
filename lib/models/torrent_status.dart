class TorrentStatus {
  final int id;
  final String name;
  final String savePath;
  final TorrentState state;
  final double progress;
  final int downloadRate;
  final int uploadRate;
  final int totalDone;
  final int totalWanted;
  final int totalUploaded;
  final int numPeers;
  final int numSeeds;
  final bool isPaused;
  final bool isFinished;
  final bool hasMetadata;

  TorrentStatus({
    required this.id,
    required this.name,
    required this.savePath,
    required this.state,
    required this.progress,
    required this.downloadRate,
    required this.uploadRate,
    required this.totalDone,
    required this.totalWanted,
    required this.totalUploaded,
    required this.numPeers,
    required this.numSeeds,
    required this.isPaused,
    required this.isFinished,
    required this.hasMetadata,
  });

  factory TorrentStatus.fromMap(Map<String, dynamic> map) {
    return TorrentStatus(
      id: map['id'] as int,
      name: map['name'] as String,
      savePath: map['savePath'] as String,
      state: TorrentState.fromRaw(map['state'] as int),
      progress: (map['progress'] as num).toDouble(),
      downloadRate: map['downloadRate'] as int,
      uploadRate: map['uploadRate'] as int,
      totalDone: (map['totalDone'] as num).toInt(),
      totalWanted: (map['totalWanted'] as num).toInt(),
      totalUploaded: (map['totalUploaded'] as num).toInt(),
      numPeers: map['numPeers'] as int,
      numSeeds: map['numSeeds'] as int,
      isPaused: map['isPaused'] == 1,
      isFinished: map['isFinished'] == 1,
      hasMetadata: map['hasMetadata'] == 1,
    );
  }

  String get progressPercent => '${(progress * 100).toStringAsFixed(1)}%';
  String get downloadSpeed => _formatSpeed(downloadRate);
  String get uploadSpeed => _formatSpeed(uploadRate);

  static String _formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '$bytesPerSec B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }
}

enum TorrentState {
  error,
  unknown,
  checkingFiles,
  downloadingMeta,
  downloading,
  finished,
  seeding,
  allocating,
  checkingResume;

  static TorrentState fromRaw(int value) {
    switch (value) {
      case -2: return TorrentState.error;
      case -1: return TorrentState.unknown;
      case 0: return TorrentState.checkingFiles;
      case 1: return TorrentState.downloadingMeta;
      case 2: return TorrentState.downloading;
      case 3: return TorrentState.finished;
      case 4: return TorrentState.seeding;
      case 5: return TorrentState.allocating;
      case 6: return TorrentState.checkingResume;
      default: return TorrentState.unknown;
    }
  }

  String get label {
    switch (this) {
      case TorrentState.error: return 'Error';
      case TorrentState.unknown: return 'Unknown';
      case TorrentState.checkingFiles: return 'Checking';
      case TorrentState.downloadingMeta: return 'Fetching metadata';
      case TorrentState.downloading: return 'Downloading';
      case TorrentState.finished: return 'Finished';
      case TorrentState.seeding: return 'Seeding';
      case TorrentState.allocating: return 'Allocating';
      case TorrentState.checkingResume: return 'Checking resume';
    }
  }
}
