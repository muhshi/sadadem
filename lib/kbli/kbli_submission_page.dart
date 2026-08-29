import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';

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
  final _repository = KbliRepository();

  late String _selectedType;
  final TextEditingController _kodeController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSubmitting = false;
  List<KbliSubmission> _historyList = [];
  bool _isLoadingHistory = true;

  static const String _prefSubmitterKey = 'kbli_submitter_name';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedType = widget.initialType ?? 'KBLI';
    if (widget.initialKode != null) {
      _kodeController.text = widget.initialKode!;
    }
    _loadSavedName();
    _loadHistory();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_prefSubmitterKey);
    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final history = await KbliLocalDbService.getAllLocalSubmissions();
    if (mounted) {
      setState(() {
        _historyList = history;
        _isLoadingHistory = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _kodeController.dispose();
    _contentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Save submitter name for future sessions
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSubmitterKey, _nameController.text.trim());

    final submission = KbliSubmission(
      type: _selectedType,
      kode: _kodeController.text.trim(),
      content: _contentController.text.trim(),
      submitterName: _nameController.text.trim(),
      deviceId: 'android-dalem-user',
      localCreatedAt: DateTime.now().toIso8601String(),
    );

    final isSentOnline = await _repository.submitExample(submission);

    if (mounted) {
      setState(() => _isSubmitting = false);
      _contentController.clear();
      _loadHistory();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  isSentOnline
                      ? Icons.check_circle_rounded
                      : Icons.cloud_off_rounded,
                  color: isSentOnline
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isSentOnline ? 'Terkirim Online' : 'Tersimpan Offline',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              isSentOnline
                  ? 'Terima kasih! Catatan kegiatan lapangan Anda berhasil dikirim ke server PINTAR KBLI.'
                  : 'Data berhasil disimpan ke memori HP. Catatan akan disinkronkan otomatis saat terhubung ke internet.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.5),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _tabController.animateTo(1); // Switch to history tab
                },
                child: const Text('Lihat Riwayat'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _syncPending() async {
    final synced = await _repository.syncPendingSubmissions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          'Crowdsourcing Lapangan',
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
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bantu lengkapi data sensus dengan memasukkan contoh kegiatan atau bahasa lapangan yang ditemui saat pendataan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF1E40AF),
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
                color: const Color(0xFF1E293B),
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
                            ? AppColors.primaryNavy
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == 'KBLI'
                              ? AppColors.primaryNavy
                              : const Color(0xFFE2E8F0),
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
                              : const Color(0xFF475569),
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
                            ? const Color(0xFF065F46)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedType == 'KBJI'
                              ? const Color(0xFF065F46)
                              : const Color(0xFFE2E8F0),
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
                              : const Color(0xFF475569),
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
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kodeController,
              decoration: InputDecoration(
                hintText: _selectedType == 'KBLI' ? 'Contoh: 01121' : 'Contoh: 6111',
                prefixIcon: const Icon(Icons.tag_rounded, size: 20),
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
                color: const Color(0xFF1E293B),
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
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Nama lengkap atau inisial petugas sensus',
                prefixIcon: Icon(Icons.person_rounded, size: 20),
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
                gradient: LinearGradient(
                  colors: [AppColors.primaryNavy, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.3),
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
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: Color(0xFFD97706), size: 24),
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
                      backgroundColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catatan yang Anda ajukan akan dicatat di sini.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: const Color(0xFF94A3B8),
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
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.type} ${item.kode}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: item.type == 'KBLI'
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF047857),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isSynced
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFFFFBEB),
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
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSynced ? 'Tersinkron' : 'Menunggu Sinkron',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSynced
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
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
                        color: const Color(0xFF1E293B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          item.submitterName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.localCreatedAt.length >= 10
                              ? item.localCreatedAt.substring(0, 10)
                              : '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
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
