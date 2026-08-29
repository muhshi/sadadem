import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';

class KbliSubmissionPage extends StatefulWidget {
  final String? initialType;
  final String? initialKode;

  const KbliSubmissionPage({
    super.key,
    this.initialType,
    this.initialKode,
  });

  @override
  State<KbliSubmissionPage> createState() => _KbliSubmissionPageState();
}

class _KbliSubmissionPageState extends State<KbliSubmissionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final KbliRepository _repository = KbliRepository();

  late String _selectedType;
  late TextEditingController _kodeController;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSubmitting = false;
  List<KbliSubmission> _historyList = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedType = (widget.initialType?.toUpperCase().contains('KBJI') ?? false)
        ? 'KBJI'
        : 'KBLI';
    _kodeController = TextEditingController(text: widget.initialKode ?? '');
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _kodeController.dispose();
    _contentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final list = await KbliLocalDbService.getAllLocalSubmissions();
    if (mounted) {
      setState(() {
        _historyList = list;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final submission = KbliSubmission(
      type: _selectedType,
      kode: _kodeController.text.trim(),
      content: _contentController.text.trim(),
      submitterName: _nameController.text.trim(),
      deviceId: 'mobile_device',
      localCreatedAt: DateTime.now().toIso8601String(),
    );

    final success = await _repository.submitExample(submission);

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.statusOnline,
            content: const Text('Catatan lapangan berhasil disimpan!'),
          ),
        );
        _contentController.clear();
        _loadHistory();
        _tabController.animateTo(1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFDC2626),
            content: Text('Gagal menyimpan catatan. Silakan periksa kembali formulir Anda.'),
          ),
        );
      }
    }
  }

  Future<void> _syncPending() async {
    final synced = await _repository.syncPendingSubmissions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: synced > 0 ? AppColors.statusOnline : AppColors.statusOffline,
          content: Text(
            synced > 0
                ? 'Berhasil menyinkronkan $synced catatan lapangan ke server.'
                : 'Tidak ada catatan tertunda atau perangkat sedang offline.',
          ),
        ),
      );
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundScaffold,
      appBar: AppBar(
        title: Text(
          'Catatan Lapangan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.subAppBarGradient,
          ),
        ),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondaryGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Formulir'),
            Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'Riwayat Catatan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.kbliSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.kbliBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.kbliPrimary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bantu lengkapi data sensus dengan memasukkan contoh kegiatan atau bahasa lapangan yang ditemui saat pendataan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.kbliText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Classification Type Selector
            Text(
              'Tipe Klasifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'KBLI'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'KBLI'
                            ? AppColors.kbliPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == 'KBLI'
                              ? AppColors.kbliPrimary
                              : AppColors.borderDefault,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'KBLI 2025 (Usaha)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedType == 'KBLI'
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 'KBJI'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 'KBJI'
                            ? AppColors.kbjiPrimary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == 'KBJI'
                              ? AppColors.kbjiPrimary
                              : AppColors.borderDefault,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'KBJI 2014 (Jabatan)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _selectedType == 'KBJI'
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Kode Field
            Text(
              'Kode Klasifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kodeController,
              decoration: InputDecoration(
                hintText: _selectedType == 'KBLI' ? 'Contoh: 01121' : 'Contoh: 6111',
                prefixIcon: const Icon(Icons.tag_rounded, size: 20, color: AppColors.textSecondary),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Kode klasifikasi wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Contoh Lapangan / Deskripsi
            Text(
              'Aktivitas / Bahasa Lapangan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Tuliskan contoh kegiatan nyata, bahasa pasar, atau deskripsi pekerjaan di lapangan...',
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().length < 5) {
                  return 'Tuliskan deskripsi minimal 5 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Nama Petugas
            Text(
              'Nama Petugas / Pengaju',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Nama lengkap atau inisial petugas sensus',
                prefixIcon: Icon(Icons.person_rounded, size: 20, color: AppColors.textSecondary),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Nama pengaju wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Submit Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.subAppBarGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.slateDark.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                label: Text(
                  _isSubmitting ? 'Mengirim Data...' : 'Kirim Catatan Lapangan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitForm,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendingCount = _historyList.where((s) => !s.isSynced).length;

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16.0),
        children: [
          // Pending Sync Card
          if (pendingCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusOfflineSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: AppColors.statusOffline, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$pendingCount Catatan Belum Disinkronkan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          'Tersimpan lokal di HP Anda',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.campaignOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _syncPending,
                    child: const Text('Sinkron'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_historyList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    Text(
                      'Belum Ada Catatan Lapangan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catatan yang Anda ajukan akan dicatat di sini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._historyList.map((item) {
              final isSynced = item.isSynced;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderDefault),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.type == 'KBLI'
                                ? AppColors.kbliSurface
                                : AppColors.kbjiSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.type} ${item.kode}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: item.type == 'KBLI'
                                  ? AppColors.kbliPrimary
                                  : AppColors.kbjiPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSynced
                                ? const Color(0xFFF0FDF4)
                                : AppColors.statusOfflineSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSynced
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                                size: 12,
                                color: isSynced
                                    ? AppColors.statusOnline
                                    : AppColors.statusOffline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSynced ? 'Tersinkron' : 'Menunggu Sinkron',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSynced
                                      ? AppColors.statusOnline
                                      : AppColors.statusOffline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          item.submitterName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.localCreatedAt.length >= 10
                              ? item.localCreatedAt.substring(0, 10)
                              : '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
