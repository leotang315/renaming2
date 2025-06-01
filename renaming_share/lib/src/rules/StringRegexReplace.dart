/// 扩展 String 类，添加支持 ${n} 分组替换的方法
extension StringRegexReplace on String {
  /// 仿 Go 的 ReplaceAllString，支持 ${n} 或 $n 分组引用
  String replaceAllWithGroups(RegExp regex, String replacement) {
    return replaceAllMapped(regex, (Match match) {
      String result = replacement;

      // 替换所有 $n 或 ${n} 格式的分组引用
      for (int i = 1; i <= match.groupCount; i++) {
        result = result
            .replaceAll('\$$i', match.group(i) ?? '') // 替换 $1, $2 等
            .replaceAll('\${$i}', match.group(i) ?? ''); // 替换 ${1}, ${2} 等
      }
      return result;
    });
  }
}