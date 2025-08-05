import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import './traditional_fortune_enhanced_page.dart';

enum TraditionalType {
  saju('정통 사주', 'saju', '사주팔자로 보는 운명', Icons.auto_stories_rounded, [Color(0xFF7C3AED), Color(0xFF6D28D9)], false),
  sajuChart('사주 차트', 'saju-chart', '시각적 사주 분석', Icons.analytics_rounded, [Color(0xFF0284C7), Color(0xFF0369A1)], false),
  tojeong('토정비결', 'tojeong', '전통 토정비결', Icons.menu_book_rounded, [Color(0xFF8B5CF6), Color(0xFF7C3AED)], true);
  
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isPremium;
  
  const TraditionalType(this.label, this.value, this.description, this.icon, this.gradientColors, this.isPremium);
}

class TraditionalFortuneUnifiedPage extends ConsumerStatefulWidget {
  const TraditionalFortuneUnifiedPage({super.key});

  @override
  ConsumerState<TraditionalFortuneUnifiedPage> createState() => _TraditionalFortuneUnifiedPageState();
}

class _TraditionalFortuneUnifiedPageState extends ConsumerState<TraditionalFortuneUnifiedPage> {
  @override
  Widget build(BuildContext context) {
    // Navigate directly to the enhanced page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TraditionalFortuneEnhancedPage());
});
    
    // Show loading while navigating
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEF4444)),;
}

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity),
                  padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
                  colors: [
            Color(0xFFEF4444).withValues(alpha: 0.1),
            Color(0xFFEC4899).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 1),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded),
                  size: 48),
                  color: Color(0xFFEF4444),
          const SizedBox(height: 12),
          Text(
            '전통 운세',
            style: TextStyle(
              fontSize: 20),
                  fontWeight: FontWeight.bold),
                  color: Color(0xFFEF4444)),
          const SizedBox(height: 8),
          Text(
            '5000년 역사의 동양 철학으로 보는 운명',
            style: TextStyle(
              fontSize: 14),
                  color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center),;
}

  Widget _buildTraditionalGrid() {
    return Column(
      children: TraditionalType.values.asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildEnhancedTraditionalCard(type, index),;
}).toList();
}

  Widget _buildEnhancedTraditionalCard(TraditionalType type, int index) {
    switch (type) {
      case TraditionalType.saju:
        return _buildSajuCard(type, index);
      case TraditionalType.sajuChart:
        return _buildSajuChartCard(type, index);
      case TraditionalType.tojeong:
        return _buildTojeongCard(type, index);
}
  }

  Widget _buildSajuCard(TraditionalType type, int index) {
    return InkWell(
      onTap: () => _navigateToFortune(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
                  colors: type.gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: type.gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: SajuPatternPainter()),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        type.icon),
                  size: 36),
                  color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: const TextStyle(
                                fontSize: 20),
                  fontWeight: FontWeight.bold),
                  color: Colors.white),
                            Text(
                              type.description),
                  style: TextStyle(
                                fontSize: 14),
                  color: Colors.white.withValues(alpha: 0.9))),
                  const Spacer(),
                  // Preview elements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround),
                  children: [
                      _buildElementIcon('목': null,
                      _buildElementIcon('화': null,
                      _buildElementIcon('토': null,
                      _buildElementIcon('금': null,
                      _buildElementIcon('수'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded),
                  size: 16),
                  color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '생년월일시로 정밀 분석',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white),
                  fontWeight: FontWeight.w500))),
            // Premium badge
            if (type.isPremium), Positioned(
                top: 16,
                right: 16),
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber),
                  borderRadius: BorderRadius.circular(16),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  color: Colors.black87)))).animate(delay: (100 * index).ms,
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
}

  Widget _buildSajuChartCard(TraditionalType type, int index) {
    return InkWell(
      onTap: () => _navigateToFortune(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
                  colors: type.gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: type.gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        child: Stack(
          children: [
            // Chart preview
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 150),
                  height: 150),
                  decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
                child: CustomPaint(
                  painter: ChartPreviewPainter()),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    type.icon),
                  size: 36),
                  color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    type.description),
                  style: TextStyle(
                      fontSize: 14),
                  color: Colors.white.withValues(alpha: 0.9)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.analytics_rounded),
                  size: 16),
                  color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '인터랙티브 차트 분석',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white),
                  fontWeight: FontWeight.w500))))).animate(delay: (100 * index).ms,
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
}

  Widget _buildTojeongCard(TraditionalType type, int index) {
    return InkWell(
      onTap: () => _navigateToFortune(type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
                  colors: type.gradientColors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: type.gradientColors[0].withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        child: Stack(
          children: [
            // Traditional pattern
            Positioned.fill(
              child: CustomPaint(
                painter: TojeongPatternPainter()),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        type.icon),
                  size: 36),
                  color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: const TextStyle(
                                fontSize: 20),
                  fontWeight: FontWeight.bold),
                  color: Colors.white),
                            Text(
                              type.description),
                  style: TextStyle(
                                fontSize: 14),
                  color: Colors.white.withValues(alpha: 0.9))),
                  const Spacer(),
                  // 64괘 preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center),
                  children: [
                      _buildHexagramPreview(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded),
                  size: 16),
                  color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '월별 상세 운세',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white),
                  fontWeight: FontWeight.w500))),
            // Premium badge
            if (type.isPremium), Positioned(
                top: 16,
                right: 16),
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber),
                  borderRadius: BorderRadius.circular(16),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  color: Colors.black87)))).animate(delay: (100 * index).ms,
      .fadeIn(duration: 500.ms)
      .slideY(begin: 0.2, end: 0);
}

  Widget _buildElementIcon(String element, Color color) {
    return Container(
      width: 32),
                  height: 32),
                  decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1),
      child: Center(
        child: Text(
          element,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold),
                  fontSize: 14)),;
}

  Widget _buildHexagramPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Text(
            '☰'),
                  style: TextStyle(
              fontSize: 24),
                  color: Colors.white),
          const SizedBox(height: 4),
          Text(
            '건위천',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white),
                  fontWeight: FontWeight.w500));
}

  // Original grid card method (kept for reference,
  Widget _buildTraditionalCard(TraditionalType type, int index) {
    return InkWell(
      onTap: () => _navigateToFortune(type),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
                  colors: type.gradientColors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: type.gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type.icon),
                  size: 40),
                  color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    type.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  color: Colors.white),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    type.description),
                  style: TextStyle(
                      fontSize: 12),
                  color: Colors.white.withValues(alpha: 0.8),
                    textAlign: TextAlign.center)),
            // Premium Badge
            if (type.isPremium), Positioned(
                top: 8,
                right: 8),
                  child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  color: Colors.black87)))).animate(delay: (50 * index).ms,
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0);
}

  void _navigateToFortune(TraditionalType type) {
    // Special handling for different fortune types
    switch (type) {
      case TraditionalType.saju:
        context.push('/fortune/saju');
        break;
      case TraditionalType.sajuChart:
        context.push('/fortune/saju-chart');
        break;
      case TraditionalType.tojeong:
        context.push('/fortune/tojeong');
        break;
}
  }}

// Custom painter for Saju background pattern
class SajuPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
     
   
    ..color =,
      Colors.white.withValues(alpha: 0.1);

    // Draw Yin-Yang pattern
    final centerX = size.width * 0.85;
    final centerY = size.height * 0.2;
    final radius = 30.0;

    // Outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Inner circles
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(centerX - radius / 3, centerY), radius / 3, paint);
    paint.color = Colors.black.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(centerX + radius / 3, centerY), radius / 3, paint);
}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Chart preview
class ChartPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
     
   
    ..color =,
      Colors.white.withValues(alpha: 0.3);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw pentagon
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        paint.style = PaintingStyle.fill;
        paint.color = Colors.white.withValues(alpha: 0.2);
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(center.dx + radius * 0.7 * cos(angle), center.dy + radius * 0.7 * sin(angle),
            ..lineTo(center.dx + radius * 0.7 * cos((i + 1) * 72 - 90) * 3.14159 / 180, 
                     center.dy + radius * 0.7 * sin((i + 1) * 72 - 90) * 3.14159 / 180,
            ..lineTo(center.dx + radius * cos((i + 1) * 72 - 90) * 3.14159 / 180,
                     center.dy + radius * sin((i + 1) * 72 - 90) * 3.14159 / 180,
            ..close(),
          paint
        );
        paint.style = PaintingStyle.stroke;
        paint.color = Colors.white.withValues(alpha: 0.3);
}
      
      if (i < 4) {
        final nextAngle = ((i + 1) * 72 - 90) * 3.14159 / 180;
        final nextX = center.dx + radius * cos(nextAngle);
        final nextY = center.dy + radius * sin(nextAngle);
        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paint);
} else {
        final firstAngle = (-90) * 3.14159 / 180;
        final firstX = center.dx + radius * cos(firstAngle);
        final firstY = center.dy + radius * sin(firstAngle);
        canvas.drawLine(Offset(x, y), Offset(firstX, firstY), paint);
}
    }}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for Tojeong pattern
class TojeongPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
     
   
    ..color =,
      Colors.white.withValues(alpha: 0.1);

    // Draw traditional Korean pattern
    final spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small circle pattern
        canvas.drawCircle(Offset(x, y), 2, paint);
        
        // Draw connecting lines
        if (x + spacing < size.width) {
          canvas.drawLine(Offset(x, y), Offset(x + spacing / 2, y), paint);
}
        if (y + spacing < size.height) {
          canvas.drawLine(Offset(x, y), Offset(x, y + spacing / 2), paint);
}
      }}
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}