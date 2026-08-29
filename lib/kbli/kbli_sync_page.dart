import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';

class KbliSyncPage extends StatefulWidget {
  const KbliSyncPage({super.key});

  @override
  State<KbliSyncPage> createState() => _KbliSyncPageState();
}

class _KbliSyncPageState extends State<KbliSyncPage> {
  final KbliRepository _repository = KbliRepository();

  Map<String, dynamic> _localDbInfo = {};
  Map<String, dynamic>? _serverSyncInfo;
  bool _isCheckingServer = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatusText = '';
  int _pendingSubmissionsCount = 0;
  bool _isSyncingSubmissions = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final localInfo = await KbliLocalDbService.getLocalDbInfo();
    final pending = await KbliLocalDbService.getPendingSubmissions();
    if (mounted) {
      setState(() {
        _localDbInfo = localInfo;
        _pendingSubmissionsCount = pending.length;
      });
    }
    _checkServerUpdate();
  }

  Future<void> _checkServerUpdate() async {
    setState(() => _isCheckingServer = true);
    try {
      final info = await _repository.checkSyncInfo();
      if (mounted) {
        setState(() {
          _serverSyncInfo = info;
          _isCheckingServer = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCheckingServer = false);
      }
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatusText = 'Menghubungkan ke server...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = p.join(tempDir.path, 'kbli_bundle_download.db.gz');
      final targetVersion = _serverSyncInfo?['version']?.toString() ??
          DateTime.now().toIso8601String().substring(0, 10);

      final success = await _repository.syncOfflineBundle(
        tempSavePath: tempPath,
        targetVersion: targetVersion,
        onProgress: (count, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = count / total;
              final downloadedMb = (count / (1024 * 1024)).toStringAsFixed(1);
              final totalMb = (total / (1024 * 1024)).toStringAsFixed(1);
              _downloadStatusText = 'Mengunduh: $downloadedMb MB / $totalMb MB (${(_downloadProgress * 100).toInt()}%)';
            });
          }
        },
      );

      if (mounted) {
        setState(() => _isDownloading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF16A34A),
              content: Text('Database offline KBLI & KBJI berhasil diperbarui!'),
            ),
          );
          _loadStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFFDC2626),
              content: Text('Gagal mengekstrak atau memasang database offline.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Terjadi kesalahan: $e'),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingSubmissions() async {
    setState(() => _isSyncingSubmissions = true);
    final count = await _repository.syncPendingSubmissions();
    if (mounted) {
      setState(() => _isSyncingSubmissions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? 'Berhasil menyinkronkan $count catatan lapangan.'
              : 'Gagal menyinkronkan atau tidak ada koneksi internet.'),
        ),
      );
      _loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _localDbInfo['is_ready'] == true;
    final localVersion = _localDbInfo['version']?.toString() ?? 'Belum terpasang';
    final kbliCount = _localDbInfo['kbli_count'] ?? 0;
    final kbjiCount = _localDbInfo['kbji_count'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          'Sinkronisasi Database Offline',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isReady
                      ? [const Color(0xFF0F766E), const Color(0xFF0D9488)]
                      : [const Color(0xFFB45309), const Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isReady ? const Color(0xFF0F766E) : const Color(0xFFB45309))
                        .withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isReady ? Icons.offline_pin_rounded : Icons.cloud_download_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isReady ? 'Mode Offline Siap' : 'Database Belum Diunduh',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isReady
                              ? 'Aplikasi siap digunakan mencari KBLI & KBJI tanpa internet.'
                              : 'Unduh paket database agar tetap bisa mencari di wilayah tanpa sinyal.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Local Database Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storage_rounded, size: 20, color: Color(0xFF1E293B)),
                      const SizedBox(width: 8),
                      Text(
                        'Status Database Lokal HP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Versi Bundle', localVersion),
                  _buildInfoRow('Master KBLI 2025', '$kbliCount item'),
                  _buildInfoRow('Master KBJI 2014', '$kbjiCount item'),
                  _buildInfoRow('FTS5 Virtual Search Index', isReady ? 'Aktif' : 'Tidak Aktif'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Server Update Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cloud_sync_rounded, size: 20, color: Color(0xFF1D4ED8)),
                      const SizedBox(width: 8),
                      Text(
                        'Pembaruan dari Server BPS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: _isCheckingServer
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Periksa Server',
                        onPressed: _isCheckingServer ? null : _checkServerUpdate,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (_serverSyncInfo != null) ...[
                    _buildInfoRow('Versi Server', _serverSyncInfo!['version']?.toString() ?? '-'),
                    _buildInfoRow('Ukuran Download', '${_serverSyncInfo!['file_size_mb'] ?? 14.2} MB'),
                    _buildInfoRow('Total KBLI + KBJI', '${(_serverSyncInfo!['kbli_count'] ?? 1569) + (_serverSyncInfo!['kbji_count'] ?? 2735)} entri'),
                  ] else ...[
                    Text(
                      _isCheckingServer
                          ? 'Sedang memeriksa informasi server...'
                          : 'Tidak dapat menghubungi server sync. Pastikan terhubung internet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Download Button / Progress
                  if (_isDownloading) ...[
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: AppColors.primaryNavy,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _downloadStatusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: Text(
                          isReady ? 'Perbarui Database Offline' : 'Unduh Database Offline',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                        onPressed: _startDownload,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pending Submissions Sync Card
            if (_pendingSubmissionsCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload_rounded, color: Color(0xFFD97706), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Lapangan Tertunda',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terdapat $_pendingSubmissionsCount catatan lapangan yang belum dikirim ke server.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD97706),
                        ),
                        onPressed: _isSyncingSubmissions ? null : _syncPendingSubmissions,
                        child: _isSyncingSubmissions
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Kirim Semua Sekarang'),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
