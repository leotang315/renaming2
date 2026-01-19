import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renaming_share/renaming_share.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

class AddRuleDialog extends StatefulWidget {
  final Function(Rule) onRuleAdded;
  final VoidCallback onCancel;

  const AddRuleDialog({
    super.key,
    required this.onRuleAdded,
    required this.onCancel,
  });

  @override
  State<AddRuleDialog> createState() => _AddRuleDialogState();
}

class _AddRuleDialogState extends State<AddRuleDialog> {
  String? _selectedNode;

  final TreeController _treeController = TreeController();

  // 构建规则树节点
  List<TreeNode> _buildNodes() {
    return [
      TreeNode(
        content: const Text('插入类规则'),
        children: [
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('position_insert'),
              child: const Text('位置插入'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('marker_insert'),
              child: const Text('标记插入'),
            ),
          ),
        ],
      ),
      TreeNode(
        content: const Text('删除类规则'),
        children: [
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('marker_delete'),
              child: const Text('标记删除'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('range_delete'),
              child: const Text('范围删除'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('delimiter_delete'),
              child: const Text('分隔符删除'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('character_type_delete'),
              child: const Text('字符类型删除'),
            ),
          ),
        ],
      ),
      TreeNode(
        content: const Text('替换类规则'),
        children: [
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('range_replace'),
              child: const Text('范围替换'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('marker_replace'),
              child: const Text('标记替换'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('character_type_replace'),
              child: const Text('字符类型替换'),
            ),
          ),
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('delimiter_replace'),
              child: const Text('分隔符替换'),
            ),
          ),
        ],
      ),
      TreeNode(
        content: const Text('模式类规则'),
        children: [
          TreeNode(
            content: TextButton(
              onPressed: () => _createRule('pattern'),
              child: const Text('模式匹配'),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _treeController.collapseAll();
    return Card(
      margin: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text(
                //   '选择规则类型',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                // ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: TreeView(
                      indent: 5,
                      nodes: _buildNodes(),
                      treeController: _treeController,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 18),
              color: Colors.white,
              splashRadius: 20,
              onPressed: widget.onCancel,
            ),
          ),
        ],
      ),
    );
  }

  void _createRule(String ruleType) {
    Rule? rule;
    try {
      switch (ruleType) {
        case 'position_insert':
          rule = PositionInsertRule(
              name: 'position_insert',
              content: '',
              position: 0,
              fromStart: true);
          break;
        case 'marker_insert':
          rule = MarkerInsertRule(
              name: 'marker_insert', content: '', marker: '', before: true);
          break;
        case 'marker_delete':
          rule = MarkerDeleteRule(name: 'marker_delete', marker: '');
          break;
        case 'range_delete':
          rule = RangeDeleteRule(name: 'range_delete', start: 0, end: 1);
          break;
        case 'delimiter_delete':
          rule = DelimiterDeleteRule(
              name: 'delimiter_delete',
              startDelimiter: '',
              endDelimiter: '',
              keepDelimiters: false);
          break;
        case 'character_type_delete':
          rule = CharacterTypeDeleteRule(
              name: 'character_type_delete',
              characterType: CharacterType.number);
          break;
        case 'range_replace':
          rule = RangeReplaceRule(
              name: 'range_replace', start: 0, end: 1, content: '');
          break;
        case 'marker_replace':
          rule = MarkerReplaceRule(
              name: 'marker_replace', marker: '', content: '');
          break;
        case 'character_type_replace':
          rule = CharacterTypeReplaceRule(
              name: 'character_type_replace',
              characterType: CharacterType.number,
              replacement: '');
          break;
        case 'delimiter_replace':
          rule = DelimiterReplaceRule(
              name: 'delimiter_replace',
              startDelimiter: '',
              endDelimiter: '',
              replacement: '');
          break;
        case 'pattern':
          rule = PatternRule(name: 'pattern', pattern: '', replace: '');
          break;
      }

      if (rule != null) {
        widget.onRuleAdded(rule);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建规则失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
