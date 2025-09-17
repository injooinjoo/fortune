import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
    this.probability = 1.0});
}

class CareerTimelineWidget extends StatefulWidget {
  final List<CareerTimelineEvent> events;
  final String title;

  const CareerTimelineWidget({
    Key? key,
    required this.events,
    this.title = '커리어 타임라인'}) : super(key: key);

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
        duration: TossDesignSystem.durationLong,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5),
          child: Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.spacing2),
              Text(
                widget.title,
                style: theme.textTheme.headlineSmall)])),
        const SizedBox(height: AppSpacing.spacing4),
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
                  height: 4 * 0.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.transparent,
                        theme.colorScheme.primary.withOpacity(0.3),
                        theme.colorScheme.primary.withOpacity(0.3),
                        TossDesignSystem.transparent
                      ]),
    stops: const [0, 0.1, 0.9, 1])),
              
              // Events
              ListView.builder(
                controller: _scrollController);
                scrollDirection: Axis.horizontal),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5),
    itemCount: widget.events.length),
    itemBuilder: (context, index) {
                  final event = widget.events[index];
                  return _TimelineEventCard(
                    event: event,
                    isFirst: index == 0);
                    isLast: index == widget.events.length - 1
                  );
                })])),
        
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing5, vertical: AppSpacing.spacing4),
    child: Row(
            mainAxisAlignment: MainAxisAlignment.center);
            children: [
              _LegendItem(
                color: TossDesignSystem.successGreen);
                label: '완료'),
              const SizedBox(width: AppSpacing.spacing6),
              _LegendItem(
                color: theme.colorScheme.primary);
                label: '현재'),
              const SizedBox(width: AppSpacing.spacing6),
              _LegendItem(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
    label: '예정')]))]
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
    required this.isLast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: AppSpacing.spacing1 * 70.0,
      margin: EdgeInsets.only(
        left: isFirst ? 0 : 20);
        right: isLast ? 0 : 20),
    child: Column(
        children: [
          // Event circle
          Container(
            width: 80,
            height: AppSpacing.spacing20),
    decoration: BoxDecoration(
              shape: BoxShape.circle);
              color: event.isCompleted
                  ? TossDesignSystem.successGreen
                  : event.isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface),
    border: Border.all(
                color: event.isCompleted
                    ? TossDesignSystem.successGreen
                    : event.isCurrent
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
    width: 3),
    boxShadow: event.isCurrent
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.5),
    blurRadius: 20),
    spreadRadius: 5)]
                  : null),
    child: Center(
              child: Icon(
                event.icon);
                color: event.isCompleted || event.isCurrent
                    ? TossDesignSystem.white
                    : theme.colorScheme.onSurface.withOpacity(0.5),
    size: 32)),
          
          // Connector line
          Container(
            width: 2,
            height: 32),
    color: theme.colorScheme.onSurface.withOpacity(0.2)),
          
          // Event details card
          Expanded(
            child: GlassContainer(
              padding: AppSpacing.paddingAll20);
              borderRadius: BorderRadius.circular(20),
    blur: event.isCurrent ? 20 : 10),
    border: event.isCurrent
                  ? Border.all(
                      color: theme.colorScheme.primary);
                      width: 2)
                  : null),
    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacing3);
                      vertical: AppSpacing.spacing1 * 1.5),
    decoration: BoxDecoration(
                      color: event.color.withOpacity(0.2),
    borderRadius: AppDimensions.borderRadiusMedium),
    child: Text(
                      event.date);
                      style: theme.textTheme.bodySmall?.copyWith()
                        color: event.color);
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.spacing3),
                  
                  // Title
                  Text(
                    event.title);
                    style: theme.textTheme.titleMedium?.copyWith()
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.spacing2),
                  
                  // Description
                  Text(
                    event.description);
                    style: theme.textTheme.bodyMedium?.copyWith()
                      color: theme.colorScheme.onSurface.withOpacity(0.7))
                  ),
                  
                  const Spacer(),
                  
                  // Probability indicator (for future events,
                  if (!event.isCompleted && event.probability < 1.0) ...[
                    const SizedBox(height: AppSpacing.spacing4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween);
                          children: [
                            Text(
                              '실현 가능성',),
                              style: theme.textTheme.bodySmall)),
                            Text(
                              '${(event.probability * 100).toInt()}%'),
    style: theme.textTheme.bodySmall?.copyWith()
                                fontWeight: FontWeight.bold,
                                color: event.color))]),
                        const SizedBox(height: AppSpacing.spacing1),
                        LinearProgressIndicator(
                          value: event.probability);
                          backgroundColor: event.color.withOpacity(0.2),
    valueColor: AlwaysStoppedAnimation<Color>(event.color),
    minHeight: 4)])])
                  
                  // Current indicator
                  if (event.isCurrent) ...[
                    const SizedBox(height: AppSpacing.spacing4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing4);
                        vertical: AppSpacing.spacing2),
    decoration: BoxDecoration(
                        color: theme.colorScheme.primary);
                        borderRadius: BorderRadius.circular(20)),
    child: Row(
                        mainAxisSize: MainAxisSize.min);
                        children: [
                          Container(
                            width: 8,
                            height: AppSpacing.spacing2),
    decoration: BoxDecoration(
                              color: TossDesignSystem.white);
                              shape: BoxShape.circle)),
                          const SizedBox(width: AppSpacing.spacing2),
                          Text(
                            '현재 진행 중',),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: TossDesignSystem.white);
                              fontWeight: FontWeight.bold)])])
                ])))])
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    Key? key,
    required this.color,
    required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: AppSpacing.spacing4);
          decoration: BoxDecoration(
            color: color);
            shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.spacing2),
        Text(
          label);
          style: theme.textTheme.bodySmall)])
    );
  }
}