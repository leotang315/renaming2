class AppConstants {
  static const String appTitle = 'ReNamer Lite (仅用于非商业使用)';
  static const String filesLabel = '文件列表:';
  static const String rulesLabel = '规则列表:';
  static const String previewLabel = '预览:';
  static const String dryRunLabel = '预览模式';
  static const String addRuleTitle = '添加规则';
  static const String cancelButton = '取消';
  static const String addButton = '添加';
  static const String previewButton = '预览';
  static const String renameButton = '重命名';
  
  // 工具提示
  static const String addFilesTooltip = '添加文件';
  static const String clearFilesTooltip = '清空文件';
  static const String addRuleTooltip = '添加规则';
  static const String clearRulesTooltip = '清空规则';
  
  // 规则类型
  static const Map<String, String> ruleTypes = {
    'addPrefix': '添加前缀',
    'addSuffix': '添加后缀',
    'removePattern': '删除模式',
    'replacePattern': '替换模式',
  };
  
  // 参数标签
  static const Map<String, String> paramLabels = {
    'addPrefix': '前缀',
    'addSuffix': '后缀',
    'removePattern': '要删除的模式',
    'replacePattern_old': '原模式',
    'replacePattern_new': '新模式',
  };
}