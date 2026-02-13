import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 포춘쿠키 조각 분해 애니메이션 위젯
/// 쿠키가 여러 조각으로 깨지면서 파티클이 흩어지는 효과
class CookieShardBreakWidget extends StatefulWidget {
  final String imagePath;
  final double size;
  final VoidCallback? onBreakComplete;
  final Color? accentColor;

  const CookieShardBreakWidget({
    super.key,
    required this.imagePath,
    this.size = 220,
    this.onBreakComplete,
    this.accentColor,
  });

  @override
  State<CookieShardBreakWidget> createState() => _CookieShardBreakWidgetState();
}

class _CookieShardBreakWidgetState extends State<CookieShardBreakWidget>
    with TickerProviderStateMixin {
  late AnimationController _breakController;
  late AnimationController _particleController;
  late Animation<double> _breakAnimation;

  final List<_CookieShard> _shards = [];
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _generateShards();
    _generateParticles();
    _startBreakAnimation();
  }

  void _initializeControllers() {
    // 메인 분해 애니메이션 (2.4초 - 2배 느리게)
    _breakController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _breakAnimation = CurvedAnimation(
      parent: _breakController,
      curve: Curves.easeOutCubic,
    );

    // 파티클 애니메이션 (3초 - 2배 느리게)
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _breakController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onBreakComplete?.call();
      }
    });
  }

  /// 쿠키 조각 8개 생성 (방사형 분할)
  void _generateShards() {
    const int shardCount = 8;
    final center = Offset(widget.size / 2, widget.size / 2);

    for (int i = 0; i < shardCount; i++) {
      final angle = (i / shardCount) * 2 * math.pi - math.pi / 2;
      final nextAngle = ((i + 1) / shardCount) * 2 * math.pi - math.pi / 2;

      // 각 조각의 이동 방향과 속도
      final midAngle = (angle + nextAngle) / 2;
      final velocity = Offset(
        math.cos(midAngle) * (80 + _random.nextDouble() * 60),
        math.sin(midAngle) * (60 + _random.nextDouble() * 40) +
            (50 + _random.nextDouble() * 30), // 중력 효과
      );

      _shards.add(_CookieShard(
        index: i,
        startAngle: angle,
        endAngle: nextAngle,
        center: center,
        velocity: velocity,
        rotation: (_random.nextDouble() - 0.5) * 2, // -1 ~ 1 라디안
        rotationSpeed: (_random.nextDouble() - 0.5) * 4, // 회전 속도
        delay: i * 0.03, // 순차적 분해
        scale: 1.0,
      ));
    }
  }

  /// 파티클(부스러기) 생성
  void _generateParticles() {
    const int particleCount = 40;
    final center = Offset(widget.size / 2, widget.size / 2);

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 30 + _random.nextDouble() * 100;

      _particles.add(_Particle(
        position: center +
            Offset(
              (_random.nextDouble() - 0.5) * 40,
              (_random.nextDouble() - 0.5) * 40,
            ),
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 20, // 약간 위로 튀어오름
        ),
        size: 2 + _random.nextDouble() * 6,
        color: _getParticleColor(),
        lifespan: 0.5 + _random.nextDouble() * 0.5,
        gravity: 200 + _random.nextDouble() * 100,
      ));
    }
  }

  Color _getParticleColor() {
    final colors = [
      const Color(0xFFE8D4A8), // 고유 색상 - 쿠키 파티클 베이지
      const Color(0xFFD4B896), // 고유 색상 - 쿠키 파티클 브라운
      const Color(0xFFC9A962), // 고유 색상 - 쿠키 파티클 금색
      const Color(0xFFBFA76A), // 고유 색상 - 쿠키 파티클 어두운 금색
      widget.accentColor ?? const Color(0xFFDC143C), // 고유 색상 - 쿠키 파티클 액센트
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _startBreakAnimation() {
    _breakController.forward();
    _particleController.forward();
  }

  @override
  void dispose() {
    _breakController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breakController, _particleController]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 파티클 레이어 (뒤)
              ..._buildParticles(),

              // 조각 레이어
              ..._buildShards(),

              // 중앙 섬광 효과
              if (_breakAnimation.value < 0.3)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 60 * (1 - _breakAnimation.value * 3),
                      height: 60 * (1 - _breakAnimation.value * 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.8 - _breakAnimation.value * 2),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildShards() {
    return _shards.map((shard) {
      final progress = (_breakAnimation.value - shard.delay).clamp(0.0, 1.0);

      if (progress <= 0) {
        // 아직 분해 시작 전 - 원본 조각 표시
        return _buildShardWidget(shard, 0);
      }

      // 이동 계산 (포물선 + 중력)
      final dx = shard.velocity.dx * progress;
      final dy = shard.velocity.dy * progress +
                 (150 * progress * progress); // 중력 가속

      // 회전 계산
      final rotation = shard.rotation + shard.rotationSpeed * progress;

      // 페이드 아웃
      final opacity = (1 - progress * 0.7).clamp(0.0, 1.0);

      // 스케일 (약간 축소)
      final scale = (1 - progress * 0.2).clamp(0.5, 1.0);

      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: rotation,
              child: _buildShardWidget(shard, progress),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildShardWidget(_CookieShard shard, double progress) {
    return ClipPath(
      clipper: _ShardClipper(
        startAngle: shard.startAngle,
        endAngle: shard.endAngle,
        center: shard.center,
        size: widget.size,
      ),
      child: Image.asset(
        widget.imagePath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
      ),
    );
  }

  List<Widget> _buildParticles() {
    return _particles.map((particle) {
      final progress = _particleController.value;

      if (progress > particle.lifespan) {
        return const SizedBox.shrink();
      }

      final normalizedProgress = progress / particle.lifespan;

      // 위치 계산 (중력 적용)
      final dx = particle.velocity.dx * progress;
      final dy = particle.velocity.dy * progress +
                 (particle.gravity * progress * progress);

      // 페이드 아웃
      final opacity = (1 - normalizedProgress).clamp(0.0, 1.0);

      // 크기 감소
      final size = particle.size * (1 - normalizedProgress * 0.5);

      return Positioned(
        left: particle.position.dx + dx - size / 2,
        top: particle.position.dy + dy - size / 2,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: particle.color,
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                  color: particle.color.withValues(alpha: 0.3),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// 쿠키 조각 데이터
class _CookieShard {
  final int index;
  final double startAngle;
  final double endAngle;
  final Offset center;
  final Offset velocity;
  final double rotation;
  final double rotationSpeed;
  final double delay;
  final double scale;

  _CookieShard({
    required this.index,
    required this.startAngle,
    required this.endAngle,
    required this.center,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.delay,
    required this.scale,
  });
}

/// 파티클 데이터
class _Particle {
  final Offset position;
  final Offset velocity;
  final double size;
  final Color color;
  final double lifespan;
  final double gravity;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifespan,
    required this.gravity,
  });
}

/// 조각 클리퍼 - 파이 모양으로 이미지 자르기
class _ShardClipper extends CustomClipper<Path> {
  final double startAngle;
  final double endAngle;
  final Offset center;
  final double size;

  _ShardClipper({
    required this.startAngle,
    required this.endAngle,
    required this.center,
    required this.size,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = this.size / 2;

    // 중심에서 시작
    path.moveTo(center.dx, center.dy);

    // 호를 그림
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
    );

    // 중심으로 돌아옴
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_ShardClipper oldClipper) {
    return oldClipper.startAngle != startAngle ||
        oldClipper.endAngle != endAngle;
  }
}

/// 간단한 흔들림 효과 위젯 (분해 전)
class CookieShakeWidget extends StatelessWidget {
  final Widget child;
  final bool isShaking;

  const CookieShakeWidget({
    super.key,
    required this.child,
    this.isShaking = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isShaking) return child;

    return child
        .animate(onPlay: (c) => c.repeat())
        .shakeX(
          duration: 100.ms,
          hz: 10,
          amount: 5,
        );
  }
}
