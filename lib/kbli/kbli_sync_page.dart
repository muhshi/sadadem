import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';

class KbliSyncPage extends StatefulWidget {
  const KbliSyncPage({super.key});

  @override
  State<KbliSyncPage> createState() => _KbliSyncPageState();
}

class _KbliSyncPageState extends State<KbliSyncPage> {
  final KbliRepository _repository = KbliRepository();

  bool _isChecking = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatusText = '';

  Map<String, dynamic>? _serverInfo;
  Map<String, dynamic> _localDbInfo = {};
  int _pendingSubmissionsCount = 0;
  bool _isSyncingSubmissions = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);

    try {
      // 1. Cek info database server
      final serverInfo = await _repository.checkSyncInfo();

      // 2. Cek status database lokal
      final localInfo = await KbliLocalDbService.getLocalDbInfo();

      // 3. Cek catatan lapangan offline tertunda
      final pending = await KbliLocalDbService.getPendingSubmissions();

      if (mounted) {
        setState(() {
          _serverInfo = serverInfo;
          _localDbInfo = localInfo;
          _pendingSubmissionsCount = pending.length;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _startDownload() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Penyimpanan SQLite FTS5 offline hanya didukung pada aplikasi Android/iOS/Desktop.'),
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatusText = 'Menyiapkan unduhan...';
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/kbli_download_${DateTime.now().millisecondsSinceEpoch}.tmp';
      final targetVersion = _serverInfo?['version']?.toString() ?? '2026.08';

      final success = await _repository.syncOfflineBundle(
        tempSavePath: tempPath,
        targetVersion: targetVersion,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
              final mbReceived = (received / (1024 * 1024)).toStringAsFixed(1);
              final mbTotal = (total / (1024 * 1024)).toStringAsFixed(1);
              _downloadStatusText = '$mbReceived MB / $mbTotal MB (${(_downloadProgress * 100).toInt()}%)';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.statusOnline,
              content: const Text('Database offline berhasil diunduh dan dipasang!'),
            ),
          );
          _checkStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFFDC2626),
              content: Text('Gagal memasang database offline.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Gagal mengunduh: $e'),
          ),
        );
      }
    }
  }

  Future<void> _syncPendingSubmissions() async {
    setState(() => _isSyncingSubmissions = true);
    try {
      final syncedCount = await _repository.syncPendingSubmissions();
      if (mounted) {
        setState(() => _isSyncingSubmissions = false);
        if (syncedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.statusOnline,
              content: Text('Berhasil menyinkronkan $syncedCount catatan lapangan ke server!'),
            ),
          );
          _checkStatus();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.statusOffline,
              content: Text('Tidak ada data yang perlu disinkronkan atau perangkat sedang offline.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncingSubmissions = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _localDbInfo['is_ready'] == true;
    final localVersion = _localDbInfo['version']?.toString() ?? 'Belum terpasang';
    final kbliCount = _localDbInfo['kbli_count'] ?? 0;
    final kbjiCount = _localDbInfo['kbji_count'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: const AppBar2(
        title: 'Sinkronisasi Database Offline',
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
                      ? const [Color(0xFF0F766E), Color(0xFF0D9488)]
                      : const [Color(0xFF9A3412), AppColors.campaignOrange],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isReady ? const Color(0xFF0F766E) : AppColors.campaignOrange)
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
                              : 'Unduh paket database untuk pencarian cepat di lapangan.',
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
            const SizedBox(height: 16),

            // Local Database Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.storage_rounded, size: 20, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Database Lokal di HP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow('Status', isReady ? 'Terpasang (FTS5 Aktif)' : 'Belum Ada'),
                  _buildInfoRow('Versi Master', localVersion),
                  _buildInfoRow('Jumlah KBLI 2025', '$kbliCount item'),
                  _buildInfoRow('Jumlah KBJI 2014', '$kbjiCount item'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Server Master Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kbliSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_sync_rounded, size: 20, color: AppColors.kbliPrimary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Master Server BPS Demak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_isChecking)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_serverInfo != null) ...[
                    _buildInfoRow('Versi Tersedia', _serverInfo!['version'] ?? '-'),
                    _buildInfoRow('Ukuran Bundle', _serverInfo!['size_formatted'] ?? (_serverInfo!['bundle_size'] != null ? '${((_serverInfo!['bundle_size'] as int) / (1024 * 1024)).toStringAsFixed(2)} MB' : '-')),
                    _buildInfoRow('Total KBLI', '${_serverInfo!['kbli_count'] ?? 1569} item'),
                    _buildInfoRow('Total KBJI', '${_serverInfo!['kbji_count'] ?? 2735} item'),
                    if (_serverInfo!['sha256'] != null)
                      _buildInfoRow('Checksum SHA-256', '${(_serverInfo!['sha256'] as String).substring(0, 12)}...'),
                  ] else ...[
                    Text(
                      _isChecking ? 'Menghubungkan ke server...' : 'Tidak dapat terhubung ke server live.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  if (_isDownloading) ...[
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: AppColors.borderDefault,
                      color: AppColors.kbliPrimary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _downloadStatusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.slateLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.slateDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                  color: AppColors.statusOfflineSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_upload_rounded, color: AppColors.statusOffline, size: 22),
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
                          backgroundColor: AppColors.campaignOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
