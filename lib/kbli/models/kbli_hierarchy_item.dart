class KbliHierarchyItem {
  final String kode;
  final String judul;
  final String deskripsi;
  final String level;
  final bool isLeaf;

  KbliHierarchyItem({
    required this.kode,
    required this.judul,
    required this.deskripsi,
    required this.level,
    required this.isLeaf,
  });

  factory KbliHierarchyItem.fromJson(Map<String, dynamic> json) {
    return KbliHierarchyItem(
      kode: json['kode']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      level: json['level']?.toString() ?? 'kategori',
      isLeaf: json['is_leaf'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode': kode,
      'judul': judul,
      'deskripsi': deskripsi,
      'level': level,
      'is_leaf': isLeaf,
    };
  }
}
