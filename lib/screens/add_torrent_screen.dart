import 'package:flutter/material.dart';
import '../torrent_service.dart';

class AddTorrentScreen extends StatefulWidget {
  final TorrentService service;
  const AddTorrentScreen({super.key, required this.service});

  @override
  State<AddTorrentScreen> createState() => _AddTorrentScreenState();
}

class _AddTorrentScreenState extends State<AddTorrentScreen> {
  final _magnetCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _magnetCtrl.dispose();
    super.dispose();
  }

  void _validateAndAdd() async {
    final magnet = _magnetCtrl.text.trim();
    if (magnet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a magnet link')),
      );
      return;
    }
    if (!magnet.startsWith('magnet:')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid magnet link')),
      );
      return;
    }
    setState(() => _adding = true);
    final id = await widget.service.addMagnet(magnet);
    if (!mounted) return;
    setState(() => _adding = false);
    if (id >= 0) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add torrent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Torrent'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste a magnet link below:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _magnetCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'magnet:?xt=urn:btih:...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _adding ? null : _validateAndAdd,
                icon: _adding
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add),
                label: Text(_adding ? 'Adding...' : 'Add Torrent'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
