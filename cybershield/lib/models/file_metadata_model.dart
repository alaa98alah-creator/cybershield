class FileMetadataModel {
  final String fileId;
  final String scanId;
  final String fileName;
  final int fileSize;
  final String fileHash;
  final String mimeType;

  const FileMetadataModel({
    required this.fileId,
    required this.scanId,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
    required this.mimeType,
  });

  factory FileMetadataModel.fromJson(Map<String, dynamic> json) {
    return FileMetadataModel(
      fileId: json['file_id'] as String,
      scanId: json['scan_id'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      fileHash: json['file_hash'] as String,
      mimeType: json['mime_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'scan_id': scanId,
      'file_name': fileName,
      'file_size': fileSize,
      'file_hash': fileHash,
      'mime_type': mimeType,
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1048576) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / 1048576).toStringAsFixed(1)} MB';
  }
}
