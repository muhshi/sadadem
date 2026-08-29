class KbliSubmission {
  final int? id;
  final String type; // 'KBLI' or 'KBJI'
  final String kode;
  final String content;
  final String submitterName;
  final String deviceId;
  final String localCreatedAt;
  final String status; // 'pending', 'approved', 'synced', 'rejected'
  final bool isSynced;

  KbliSubmission({
    this.id,
    required this.type,
    required this.kode,
    required this.content,
    required this.submitterName,
    required this.deviceId,
    required this.localCreatedAt,
    this.status = 'pending',
    this.isSynced = false,
  });

  factory KbliSubmission.fromJson(Map<String, dynamic> json) {
    return KbliSubmission(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      type: json['type']?.toString() ?? 'KBLI',
      kode: json['kode']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      submitterName: json['submitter_name']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      localCreatedAt: json['local_created_at']?.toString() ?? DateTime.now().toIso8601String(),
      status: json['status']?.toString() ?? 'pending',
      isSynced: json['is_synced'] == 1 || json['is_synced'] == true,
    );
  }

  Map<String, dynamic> toServerJson() {
    return {
      'type': type,
      'kode': kode,
      'content': content,
      'submitter_name': submitterName,
      'device_id': deviceId,
      'local_created_at': localCreatedAt,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'kode': kode,
      'content': content,
      'submitter_name': submitterName,
      'device_id': deviceId,
      'local_created_at': localCreatedAt,
      'status': status,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  KbliSubmission copyWith({
    int? id,
    String? type,
    String? kode,
    String? content,
    String? submitterName,
    String? deviceId,
    String? localCreatedAt,
    String? status,
    bool? isSynced,
  }) {
    return KbliSubmission(
      id: id ?? this.id,
      type: type ?? this.type,
      kode: kode ?? this.kode,
      content: content ?? this.content,
      submitterName: submitterName ?? this.submitterName,
      deviceId: deviceId ?? this.deviceId,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
