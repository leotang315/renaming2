enum RenameMode {
  normal('normal'),    // 跳过错误状态的映射
  error('error'),      // 只重试错误状态的映射
  undo('undo');        // 执行映射回退

  final String value;
  const RenameMode(this.value);

  factory RenameMode.fromString(String value) {
    return RenameMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => RenameMode.normal,
    );
  }
}