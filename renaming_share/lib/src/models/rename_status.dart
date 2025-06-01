enum RenameStatus {
  pending('pending'),
  success('success'),
  error('error');

  final String value;
  const RenameStatus(this.value);

  factory RenameStatus.fromString(String value) {
    return RenameStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => RenameStatus.pending,
    );
  }
}