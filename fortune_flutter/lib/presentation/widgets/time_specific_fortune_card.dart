import 'package:flutter/material.dart';
import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme.dart';

class TimeSpecificFortuneCard extends StatelessWidget {
  final TimeSpecificFortune fortune;
  final VoidCallback? onTap;
  final bool isExpanded;

  const TimeSpecificFortuneCard({
    Key? key,
    required this.fortune,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isExpanded ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getScoreColor(fortune.score).withValues(alpha: 0.1),
                _getScoreColor(fortune.score).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fortune.time,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fortune.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildScoreIndicator(),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  fortune.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.textColor,
                  ),
                ),
                if (fortune.recommendation != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fortune.recommendation!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getScoreColor(fortune.score).withValues(alpha: 0.2),
        border: Border.all(
          color: _getScoreColor(fortune.score),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${fortune.score}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(fortune.score),
              ),
            ),
            Text(
              '점',
              style: TextStyle(
                fontSize: 12,
                color: _getScoreColor(fortune.score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

// List widget for multiple time-specific fortunes
class TimeSpecificFortuneList extends StatefulWidget {
  final List<TimeSpecificFortune> fortunes;
  final String? title;

  const TimeSpecificFortuneList({
    Key? key,
    required this.fortunes,
    this.title,
  }) : super(key: key);

  @override
  _TimeSpecificFortuneListState createState() => _TimeSpecificFortuneListState();
}

class _TimeSpecificFortuneListState extends State<TimeSpecificFortuneList> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        ...widget.fortunes.asMap().entries.map((entry) {
          final index = entry.key;
          final fortune = entry.value;
          final isExpanded = expandedIndex == index;

          return TimeSpecificFortuneCard(
            fortune: fortune,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
          );
        }).toList(),
      ],
    );
  }
}