import 'package:flutter/material.dart';
import 'package:renaming_share/renaming_share.dart';
import '../utils/theme.dart';

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
  String _selectedCategory = 'Insert';

  final Map<String, List<RuleOption>> _ruleCategories = {
    'Insert': [
      RuleOption('Position Insert', 'Insert text at a specific index',
          Icons.pin_drop, 'position_insert'),
      RuleOption('Marker Insert', 'Insert text before/after a marker',
          Icons.label, 'marker_insert'),
    ],
    'Delete': [
      RuleOption('Marker Delete', 'Delete text using a marker',
          Icons.delete_outline, 'marker_delete'),
      RuleOption('Range Delete', 'Delete text in a specific range',
          Icons.linear_scale, 'range_delete'),
      RuleOption('Delimiter Delete', 'Delete text between delimiters',
          Icons.code, 'delimiter_delete'),
      RuleOption('Type Delete', 'Delete specific character types',
          Icons.category, 'character_type_delete'),
    ],
    'Replace': [
      RuleOption('Range Replace', 'Replace text in a specific range',
          Icons.find_replace, 'range_replace'),
      RuleOption('Marker Replace', 'Replace text using a marker',
          Icons.label_important, 'marker_replace'),
      RuleOption('Type Replace', 'Replace specific character types',
          Icons.font_download, 'character_type_replace'),
      RuleOption('Delimiter Replace', 'Replace text between delimiters',
          Icons.code_off, 'delimiter_replace'),
    ],
    'Pattern': [
      RuleOption('Regex Pattern', 'Advanced replacement using Regex',
          Icons.data_object, 'pattern'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = (screenSize.width * 0.8).clamp(600.0, 900.0);
    final dialogHeight = (screenSize.height * 0.75).clamp(420.0, 560.0);
    final sidebarWidth = (dialogWidth * 0.24).clamp(120.0, 180.0);
    final compactLayout = dialogWidth <= 700;
    final compactSidebar = sidebarWidth <= 150;
    return Container(
      width: dialogWidth,
      height: dialogHeight,
      decoration: BoxDecoration(
        color: AppTheme.panelColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Rule',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close,
                      size: 18, color: AppTheme.textColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: compactLayout
                ? Container(
                    color: AppTheme.panelColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _ruleCategories.keys.map((category) {
                              final isSelected = category == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => setState(
                                      () => _selectedCategory = category),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: isSelected
                                          ? AppTheme.backgroundColor
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.textSecondaryColor
                                            : AppTheme.textMutedColor,
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$_selectedCategory Rules',
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final columns = (w / 240).floor().clamp(2, 3);
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.3,
                                ),
                                itemCount:
                                    _ruleCategories[_selectedCategory]!.length,
                                itemBuilder: (context, idx) {
                                  final option =
                                      _ruleCategories[_selectedCategory]![idx];
                                  return _buildOptionCard(option);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        width: sidebarWidth,
                        decoration: const BoxDecoration(
                          border: Border(
                              right: BorderSide(color: AppTheme.borderColor)),
                          color: AppTheme.backgroundColor,
                        ),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: _ruleCategories.keys.map((category) {
                            final isSelected = category == _selectedCategory;
                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedCategory = category),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: compactSidebar ? 10 : 16,
                                    vertical: compactSidebar ? 10 : 12),
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? const Border(
                                          left: BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 3))
                                      : const Border(
                                          left: BorderSide(
                                              color: Colors.transparent,
                                              width: 3)),
                                  color: isSelected
                                      ? AppTheme.panelColor
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.textSecondaryColor
                                        : AppTheme.textMutedColor,
                                    fontSize: compactSidebar ? 12 : 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: AppTheme.panelColor,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_selectedCategory Rules',
                                style: const TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final w = constraints.maxWidth;
                                    final columns =
                                        (w / 260).floor().clamp(2, 4);
                                    return GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 1.35,
                                      ),
                                      itemCount:
                                          _ruleCategories[_selectedCategory]!
                                              .length,
                                      itemBuilder: (context, idx) {
                                        final option = _ruleCategories[
                                            _selectedCategory]![idx];
                                        return _buildOptionCard(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(RuleOption option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _createRule(option.type),
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(6),
            color: AppTheme.backgroundColor,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(option.icon, size: 28, color: AppTheme.textSecondaryColor),
              const SizedBox(height: 8),
              Text(
                option.label,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                option.description,
                style: const TextStyle(
                  color: AppTheme.textMutedColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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

class RuleOption {
  final String label;
  final String description;
  final IconData icon;
  final String type;

  RuleOption(this.label, this.description, this.icon, this.type);
}
