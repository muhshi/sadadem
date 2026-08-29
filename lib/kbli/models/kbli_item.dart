class KbliItem {
  final String type;
  final String kode;
  final String judul;
  final String deskripsi;
  final List<String> contohLapangan;
  final int score;
  final String matchType;
  final bool isEquivalent;

  KbliItem({
    required this.type,
    required this.kode,
    required this.judul,
    required this.deskripsi,
    required this.contohLapangan,
    required this.score,
    required this.matchType,
    this.isEquivalent = false,
  });

  factory KbliItem.fromJson(Map<String, dynamic> json) {
    var rawContoh = json['contoh_lapangan'];
    List<String> listContoh = [];
    if (rawContoh is List) {
      listContoh = rawContoh.map((e) => e.toString()).toList();
    }

    return KbliItem(
      type: json['type']?.toString() ?? 'KBLI 2025',
      kode: json['kode']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      contohLapangan: listContoh,
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      matchType: json['match_type']?.toString() ?? 'exact',
      isEquivalent: json['is_equivalent'] == true,
    );
  }

  factory KbliItem.fromSqlite(Map<String, dynamic> row) {
    var rawContoh = row['contoh_lapangan'];
    List<String> listContoh = [];
    if (rawContoh is String && rawContoh.isNotEmpty) {
      listContoh = rawContoh.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return KbliItem(
      type: row['type']?.toString() ?? 'KBLI 2025',
      kode: row['kode']?.toString() ?? '',
      judul: row['judul']?.toString() ?? '',
      deskripsi: row['deskripsi']?.toString() ?? '',
      contohLapangan: listContoh,
      score: 80,
      matchType: 'offline_fts',
      isEquivalent: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'kode': kode,
      'judul': judul,
      'deskripsi': deskripsi,
      'contoh_lapangan': contohLapangan,
      'score': score,
      'match_type': matchType,
      'is_equivalent': isEquivalent,
    };
  }
}
