import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Dalem/components/app_colors.dart';
import 'package:Dalem/components/bar.dart';
import 'package:Dalem/components/bps_theme.dart';
import 'package:Dalem/providers/theme_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Could not launch $urlString: $e');
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.slateDark,
              content: Text('Tidak dapat membuka tautan: $urlString'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final theme = themeProvider.currentTheme;

        return Scaffold(
          backgroundColor: AppColors.backgroundScaffold,
          appBar: const AppBar2(
            title: 'Tentang Aplikasi',
          ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // 1. Header Card App Branding
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryNavy,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/img/homei.png',
                      height: 48,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.analytics_rounded,
                              size: 48, color: Color(0xFF0F2B5C)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'DALEM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data & Layanan Statistik BPS Kabupaten Demak',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Version & Active Activity Pill
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Versi 3.0.0',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.primaryLight.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(theme.badgeIcon,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              // Tampilkan nama kegiatan (bisa diatur dengan showYear: true atau ubah langsung di _getThemeDisplayName)
                              _getThemeDisplayName(theme.activity),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Tema Tampilan Aplikasi
            _buildThemeSection(context, themeProvider),

            const SizedBox(height: 14),

            // 3. Profil & Layanan BPS Demak
            _buildSectionCard(
              title: 'Profil & Layanan BPS Demak',
              icon: Icons.account_balance_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BPS Kabupaten Demak berkomitmen menyediakan data statistik yang berkualitas, akurat, mutakhir, dan tepercaya untuk mewujudkan Indonesia Maju.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Pelayanan Statistik Terpadu (PST)',
                    subtitle: 'Konsultasi statistik, metadata, & rekomendasi kegiatan statistik.',
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Jam Pelayanan PST',
                    subtitle: 'Senin - Kamis (08.00 - 15.30) | Jumat (08.00 - 16.00 WIB)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 3. Kontak & Lokasi
            _buildSectionCard(
              title: 'Kontak & Lokasi Kantor',
              icon: Icons.location_on_rounded,
              child: Column(
                children: [
                  _buildContactTile(
                    icon: Icons.place_rounded,
                    title: 'Alamat Kantor',
                    subtitle: 'Jl. Kyai Singkil No. 24, Bintoro, Kec. Demak, Kab. Demak, Jawa Tengah 59511',
                    actionLabel: 'Buka Maps',
                    onTap: () => _openUrl(
                      context,
                      'https://www.google.com/maps/search/?api=1&query=BPS+Kabupaten+Demak',
                    ),
                  ),
                  const Divider(height: 18),
                  _buildContactTile(
                    icon: Icons.language_rounded,
                    title: 'Website Resmi',
                    subtitle: 'demakkab.bps.go.id',
                    actionLabel: 'Kunjungi',
                    onTap: () => _openUrl(context, 'https://demakkab.bps.go.id'),
                  ),
                  const Divider(height: 18),
                  _buildContactTile(
                    icon: Icons.email_rounded,
                    title: 'Email Resmi',
                    subtitle: 'bps3321@bps.go.id',
                    actionLabel: 'Kirim Email',
                    onTap: () => _openUrl(context, 'mailto:bps3321@bps.go.id'),
                  ),
                  const Divider(height: 18),
                  _buildContactTile(
                    icon: Icons.policy_rounded,
                    title: 'Portal PPID BPS Demak',
                    subtitle: 'Layanan Permohonan Informasi Publik Terpadu',
                    actionLabel: 'Buka Portal',
                    onTap: () => _openUrl(
                      context,
                      'https://ppid.bps.go.id/app/konten/3321/Profil-BPS.html',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 4. Media Sosial Resmi
            _buildSectionCard(
              title: 'Media Sosial Resmi',
              icon: Icons.public_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      label: 'Instagram',
                      subtitle: '@bpskabdemak',
                      icon: Icons.camera_alt_rounded,
                      color: const Color(0xFFE1306C),
                      onTap: () => _openUrl(
                        context,
                        'https://www.instagram.com/bpskabdemak/',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSocialButton(
                      label: 'YouTube',
                      subtitle: 'BPS Kab. Demak',
                      icon: Icons.play_circle_fill_rounded,
                      color: const Color(0xFFFF0000),
                      onTap: () => _openUrl(
                        context,
                        'https://www.youtube.com/@bpskabupatendemak',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Copyright Footer
            Center(
              child: Text(
                'Hak Cipta © ${DateTime.now().year} Badan Pusat Statistik Kabupaten Demak',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryNavy),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryNavy),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isAuto = themeProvider.isAuto;
    final autoTheme = themeProvider.autoTheme;
    final manualActivity = themeProvider.manualActivity;

    const themeOptions = [
      BpsActivity.sensusEkonomi2026,
      BpsActivity.sensusPertanian2023,
      BpsActivity.sensusPenduduk2020,
      BpsActivity.defaultBps,
    ];

    return _buildSectionCard(
      title: 'Tema Tampilan Aplikasi',
      icon: Icons.palette_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sesuaikan tema warna aplikasi secara manual atau biarkan otomatis mengikuti agenda rilis kegiatan sensus dan survei resmi BPS.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // 1. Opsi Otomatis (Rekomendasi)
          InkWell(
            onTap: () {
              if (!isAuto) {
                themeProvider.resetToAuto();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isAuto
                    ? autoTheme.primary.withValues(alpha: 0.08)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAuto ? autoTheme.primary : AppColors.borderDefault,
                  width: isAuto ? 1.8 : 1,
                ),
                boxShadow: isAuto
                    ? [
                        BoxShadow(
                          color: autoTheme.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAuto
                          ? autoTheme.primary
                          : AppColors.textSecondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: isAuto ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Otomatis',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isAuto
                                    ? autoTheme.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Rekomendasi',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Sesuai agenda BPS: ${_getThemeDisplayName(autoTheme.activity)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isAuto
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isAuto ? autoTheme.primary : AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle Manual
          Row(
            children: [
              Text(
                'Atau Pilih Tema Khusus:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2x2 Grid Theme Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: themeOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final activity = themeOptions[index];
              final actTheme = ActivityThemes.getTheme(activity);
              final isSelected = !isAuto && manualActivity == activity;

              return InkWell(
                onTap: () => themeProvider.setManualTheme(activity),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? actTheme.primary.withValues(alpha: 0.08)
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? actTheme.primary
                          : AppColors.borderDefault,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: actTheme.primary.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  actTheme.primary,
                                  actTheme.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      actTheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: actTheme.primary,
                            )
                          else
                            Icon(
                              Icons.radio_button_off_rounded,
                              size: 16,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.6),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: actTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getThemeShortBadge(activity),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: actTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getThemeDisplayName(activity),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? actTheme.primary
                                  : AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Nama label kegiatan/tema yang ditampilkan di header dan kartu tema.
  /// Berpusat di ActivityTheme.displayName() agar sinkron dengan AppBar Home.
  String _getThemeDisplayName(BpsActivity activity, {bool showYear = false}) {
    return ActivityThemes.getTheme(activity).displayName(showYear: showYear);
  }

  /// Badge singkatan tema pada kartu (berpusat di ActivityTheme.displayBadge).
  String _getThemeShortBadge(BpsActivity activity) {
    return ActivityThemes.getTheme(activity).displayBadge();
  }
}
