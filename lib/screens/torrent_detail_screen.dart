import 'package:flutter/material.dart';
import '../torrent_service.dart';
import '../models/torrent_status.dart';
import '../models/file_info.dart';

class TorrentDetailScreen extends StatefulWidget {
  final TorrentService service;
  final TorrentStatus status;
  const TorrentDetailScreen({super.key, required this.service, required this.status});

  @override
  State<TorrentDetailScreen> createState() => _TorrentDetailScreenState();
}

class _TorrentDetailScreenState extends State<TorrentDetailScreen> {
  List<FileInfo>? _files;
  late TorrentStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (!_status.hasMetadata) return;
    final files = await widget.service.getFiles(_status.id);
    if (mounted) setState(() => _files = files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_status.name.isNotEmpty ? _status.name : 'Torrent Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_status.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () async {
              if (_status.isPaused) {
                await widget.service.resumeTorrent(_status.id);
              } else {
                await widget.service.pauseTorrent(_status.id);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          if (_files != null) ...[
            const SizedBox(height: 16),
            _buildFilesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_status.state.label}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _status.isPaused ? Colors.orange : null,
              ),
            ),
            const SizedBox(height: 8),
            Text('Save path: ${_status.savePath}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _status.progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_status.progressPercent}  '
              '(${(_status.totalDone / 1048576).toStringAsFixed(1)} / '
              '${(_status.totalWanted / 1048576).toStringAsFixed(1)} MB)',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _statRow(Icons.arrow_downward, 'Download', _status.downloadSpeed),
            _statRow(Icons.arrow_upward, 'Upload', _status.uploadSpeed),
            _statRow(Icons.people, 'Peers', '${_status.numPeers}'),
            _statRow(Icons.person, 'Seeds', '${_status.numSeeds}'),
            if (_status.totalUploaded > 0)
              _statRow(Icons.cloud_upload, 'Total Uploaded',
                '${(_status.totalUploaded / 1048576).toStringAsFixed(1)} MB'),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[700])),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFilesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Files', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...?_files?.map((f) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                f.isStreamable ? Icons.play_circle_outline : Icons.insert_drive_file_outlined,
                color: Colors.grey[600],
              ),
              title: Text(f.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text(f.formattedSize, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            )),
          ],
        ),
      ),
    );
  }
}
