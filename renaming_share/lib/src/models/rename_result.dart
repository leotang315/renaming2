import 'rename_status.dart';

class RenameResult {
  final String oldPath;
  final String newPath;
  final RenameStatus status;
  final String? message;

  const RenameResult({
    required this.oldPath,
    required this.newPath,
    this.status = RenameStatus.pending,
    this.message,
  });

  RenameResult copyWith({
    String? oldPath,
    String? newPath,
    RenameStatus? status,
    String? message,
  }) {
    return RenameResult(
      oldPath: oldPath ?? this.oldPath,
      newPath: newPath ?? this.newPath,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toJson() => {
        'oldPath': oldPath,
        'newPath': newPath,
        'status': status.value,
        if (message != null) 'message': message,
      };

  factory RenameResult.fromJson(Map<String, dynamic> json) => RenameResult(
        oldPath: json['oldPath'] as String,
        newPath: json['newPath'] as String,
        status: RenameStatus.fromString(json['status'] as String),
        message: json['message'] as String?,
      );
}
