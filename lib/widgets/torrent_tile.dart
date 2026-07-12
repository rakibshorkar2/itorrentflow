import 'package:flutter/material.dart';
import '../models/torrent_status.dart';

class TorrentTile extends StatelessWidget {
  final TorrentStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onRemove;

  const TorrentTile({
    super.key,
    required this.status,
    this.onTap,
    this.onPause,
    this.onResume,
    this.onRemove,
  });

  Color _stateColor(TorrentState state) {
    switch (state) {
      case TorrentState.downloading:
      case TorrentState.downloadingMeta:
        return Colors.blue;
      case TorrentState.seeding:
        return Colors.green;
      case TorrentState.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = status.isPaused ? Colors.orange : _stateColor(status.state);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: status.isPaused ? Colors.orange : stateColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      status.name.isNotEmpty ? status.name : 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    status.state.label,
                    style: TextStyle(
                      color: status.isPaused ? Colors.orange : stateColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: status.progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    status.progressPercent,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (status.downloadRate > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.arrow_downward, size: 12, color: Colors.blue[400]),
                    ),
                  if (status.downloadRate > 0)
                    Text(status.downloadSpeed, style: TextStyle(fontSize: 11, color: Colors.blue[400])),
                  if (status.uploadRate > 0) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_upward, size: 12, color: Colors.green[400]),
                    Text(status.uploadSpeed, style: TextStyle(fontSize: 11, color: Colors.green[400])),
                  ],
                ],
              ),
              if (status.hasMetadata) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${status.numPeers} peers  ${status.numSeeds} seeds',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Text(
                      '${(status.totalDone / 1048576).toStringAsFixed(1)} / ${(status.totalWanted / 1048576).toStringAsFixed(1)} MB',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              if (onPause != null || onResume != null || onRemove != null) ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onResume != null && status.isPaused)
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 20),
                        onPressed: onResume,
                        tooltip: 'Resume',
                      ),
                    if (onPause != null && !status.isPaused)
                      IconButton(
                        icon: const Icon(Icons.pause, size: 20),
                        onPressed: onPause,
                        tooltip: 'Pause',
                      ),
                    if (onRemove != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        onPressed: onRemove,
                        tooltip: 'Remove',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
