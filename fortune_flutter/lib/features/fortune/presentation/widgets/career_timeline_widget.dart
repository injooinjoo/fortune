import 'package:flutter/material.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';

class CareerTimelineEvent {
  final String date;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isCurrent;
  final double probability;

  const CareerTimelineEvent({
    required this.date,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.isCurrent = false,
    this.probability = 1.0,
  });
}

class CareerTimelineWidget extends StatefulWidget {
  final List<CareerTimelineEvent> events;
  final String title;

  const CareerTimelineWidget({
    Key? key,
    required this.events,
    this.title = '커리어 타임라인',
  }) : super(key: key);

  @override
  State<CareerTimelineWidget> createState() => _CareerTimelineWidgetState();
}

class _CareerTimelineWidgetState extends State<CareerTimelineWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll to current event after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentEvent();
    });
  }

  void _scrollToCurrentEvent() {
    final currentIndex = widget.events.indexWhere((e) => e.isCurrent);
    if (currentIndex != -1) {
      final scrollPosition = currentIndex * 320.0; // Approximate width per event
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: Stack(
            children: [
              // Timeline line
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        theme.colorScheme.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.1, 0.9, 1],
                    ),
                  ),
                ),
              ),
              
              // Events
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.events.length,
                itemBuilder: (context, index) {
                  final event = widget.events[index];
                  return _TimelineEventCard(
                    event: event,
                    isFirst: index == 0,
                    isLast: index == widget.events.length - 1,
                  );
                },
              ),
            ],
          ),
        ),
        
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: AppColors.success,
                label: '완료',
              ),
              const SizedBox(width: 24),
              _LegendItem(
                color: theme.colorScheme.primary,
                label: '현재',
              ),
              const SizedBox(width: 24),
              _LegendItem(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                label: '예정',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final CareerTimelineEvent event;
  final bool isFirst;
  final bool isLast;

  const _TimelineEventCard({
    Key? key,
    required this.event,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      margin: EdgeInsets.only(
        left: isFirst ? 0 : 20,
        right: isLast ? 0 : 20,
      ),
      child: Column(
        children: [
          // Event circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: event.isCompleted
                  ? AppColors.success
                  : event.isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
              border: Border.all(
                color: event.isCompleted
                    ? AppColors.success
                    : event.isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: event.isCurrent
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                event.icon,
                color: event.isCompleted || event.isCurrent
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                size: 32,
              ),
            ),
          ),
          
          // Connector line
          Container(
            width: 2,
            height: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          
          // Event details card
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              blur: event.isCurrent ? 20 : 10,
              border: event.isCurrent
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: event.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Probability indicator (for future events)
                  if (!event.isCompleted && event.probability < 1.0) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '실현 가능성',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '${(event.probability * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: event.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: event.probability,
                          backgroundColor: event.color.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(event.color),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ],
                  
                  // Current indicator
                  if (event.isCurrent) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '현재 진행 중',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}