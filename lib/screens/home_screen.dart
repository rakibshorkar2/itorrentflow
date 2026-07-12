import 'package:flutter/material.dart';
import '../torrent_service.dart';
import '../models/torrent_status.dart';
import '../widgets/torrent_tile.dart';
import 'add_torrent_screen.dart';
import 'torrent_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final TorrentService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final ok = await widget.service.initialize();
    if (!mounted) return;
    setState(() {
      _initializing = false;
      if (!ok) {
        _error = 'Failed to initialize torrent engine';
      }
    });
    if (ok) {
      final pending = await widget.service.getPendingMagnetURL();
      if (pending != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddTorrentScreen(service: widget.service, initialMagnet: pending),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _removeTorrent(TorrentStatus s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Torrent'),
        content: Text('Delete "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirm == true) {
      await widget.service.removeTorrent(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torrents'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTorrentScreen(service: widget.service),
                ),
              ).then((added) {
                if (added == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Torrent added')),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() { _initializing = true; _error = null; });
                _initService();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<TorrentStatus>>(
      stream: widget.service.statusStream,
      builder: (context, snapshot) {
        final torrents = snapshot.data ?? widget.service.torrents;
        if (torrents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.movie_creation_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No torrents yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTorrentScreen(service: widget.service),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Torrent'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: torrents.length,
            itemBuilder: (context, index) {
              final s = torrents[index];
              return TorrentTile(
                status: s,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TorrentDetailScreen(
                        service: widget.service,
                        status: s,
                      ),
                    ),
                  );
                },
                onPause: () => widget.service.pauseTorrent(s.id),
                onResume: () => widget.service.resumeTorrent(s.id),
                onRemove: () => _removeTorrent(s),
              );
            },
          ),
        );
      },
    );
  }
}
