class FileInfo {
  final int index;
  final String name;
  final String path;
  final int size;
  final bool isStreamable;

  FileInfo({
    required this.index,
    required this.name,
    required this.path,
    required this.size,
    required this.isStreamable,
  });

  factory FileInfo.fromMap(Map<String, dynamic> map) {
    return FileInfo(
      index: map['index'] as int,
      name: map['name'] as String,
      path: map['path'] as String,
      size: (map['size'] as num).toInt(),
      isStreamable: map['isStreamable'] == 1,
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
