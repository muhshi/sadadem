import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/kbli/models/kbli_submission.dart';
import 'package:Dalem/kbli/services/kbli_repository.dart';
import 'package:Dalem/kbli/services/kbli_local_db_service.dart';

class KbliSubmissionPage extends StatefulWidget {
  final String? initialType;
  final String? initialKode;
  final String? initialJudul;

  const KbliSubmissionPage({
    super.key,
    this.initialType,
    this.initialKode,
    this.initialJudul,
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

  bool _isSubmitting = false;
  List<KbliSubmission> _historyList = [];
  bool _isLoadingHistory = true;
  String _selectedStatusFilter = 'ALL';
  final Map<String, String> _titleCache = {};

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
      _resolveMissingTitles(list);
    }
  }

  Future<void> _resolveMissingTitles(List<KbliSubmission> list) async {
    for (final item in list) {
      if (item.judul != null && item.judul!.isNotEmpty) {
        _titleCache[item.kode] = item.judul!;
      } else if (!_titleCache.containsKey(item.kode)) {
        final title = await _repository.getTitleByCode(item.type, item.kode);
        if (title != null && mounted) {
          setState(() {
            _titleCache[item.kode] = title;
          });
        }
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final submission = KbliSubmission(
      type: _selectedType,
      kode: _kodeController.text.trim(),
      judul: widget.initialJudul,
      content: _contentController.text.trim(),
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
            const SizedBox(height: 24),

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

    final unsyncedCount = _historyList.where((s) => !s.isSynced).length;
    final filteredList = _selectedStatusFilter == 'ALL'
        ? _historyList
        : _historyList.where((s) => s.normalizedStatus == _selectedStatusFilter).toList();

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16.0),
        children: [
          // Pending Sync Card
          if (unsyncedCount > 0) ...[
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
                          '$unsyncedCount Catatan Belum Disinkronkan',
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

          // Filter Chips (Semua, Pending, Approve, Reject)
          _buildStatusFilterChips(),
          const SizedBox(height: 16),

          // Content List or Empty State
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
          else if (filteredList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20),
                child: Column(
                  children: [
                    const Icon(Icons.filter_list_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak Ada Catatan Status ${_getStatusFilterTitle(_selectedStatusFilter)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pilih filter status lainnya untuk melihat catatan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredList.map((item) => _buildHistoryCard(item)),
        ],
      ),
    );
  }

  String _getStatusFilterTitle(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending';
      case 'approve':
        return 'Approve';
      case 'reject':
        return 'Reject';
      default:
        return '';
    }
  }

  Widget _buildStatusFilterChips() {
    final pendingCount = _historyList.where((s) => s.isPending).length;
    final approvedCount = _historyList.where((s) => s.isApproved).length;
    final rejectedCount = _historyList.where((s) => s.isRejected).length;

    final filters = [
      {'key': 'ALL', 'label': 'Semua', 'count': _historyList.length, 'color': AppColors.slateDark},
      {'key': 'pending', 'label': 'Pending', 'count': pendingCount, 'color': const Color(0xFFD97706)},
      {'key': 'approve', 'label': 'Approve', 'count': approvedCount, 'color': const Color(0xFF16A34A)},
      {'key': 'reject', 'label': 'Reject', 'count': rejectedCount, 'color': const Color(0xFFDC2626)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedStatusFilter == f['key'];
          final color = f['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStatusFilter = f['key'] as String;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppColors.borderDefault,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${f['count']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryCard(KbliSubmission item) {
    Color statusColor;
    Color statusBg;
    Color statusBorder;
    IconData statusIcon;
    String statusText;
    String statusDesc;

    if (item.isApproved) {
      statusText = 'Approve';
      statusColor = const Color(0xFF16A34A);
      statusBg = const Color(0xFFF0FDF4);
      statusBorder = const Color(0xFFBBF7D0);
      statusIcon = Icons.check_circle_rounded;
      statusDesc = 'Disetujui & masuk contoh lapangan BPS';
    } else if (item.isRejected) {
      statusText = 'Reject';
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusIcon = Icons.cancel_rounded;
      statusDesc = 'Ditolak: Belum memenuhi standar kegiatan';
    } else {
      statusText = 'Pending';
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
      statusIcon = Icons.hourglass_top_rounded;
      statusDesc = item.isSynced
          ? 'Terkirim ke server, menunggu review admin'
          : 'Draft lokal, menunggu sinkronisasi online';
    }

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
              // Badge Jenis & Kode
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

              // Offline Tag if !isSynced
              if (!item.isSynced) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        'Lokal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 3 Status Badge: Pending / Approve / Reject
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Judul Resmi Klasifikasi (KBLI/KBJI)
          Builder(
            builder: (context) {
              final title = (item.judul != null && item.judul!.isNotEmpty)
                  ? item.judul!
                  : _titleCache[item.kode];
              if (title != null && title.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Content
          Text(
            item.content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.slateLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Status Explanation info bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  size: 13,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    statusDesc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Date Footer
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
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
  }
}
