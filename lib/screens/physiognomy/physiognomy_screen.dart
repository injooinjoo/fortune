import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import '../../shared/components/app_header.dart';
import '../../shared/glassmorphism/glass_container.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class PhysiognomyScreen extends StatelessWidget {
  const PhysiognomyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: 'AI 관상');
              backgroundColor: theme.colorScheme.surface,
    ))
          ))
          SliverPadding(
            padding: AppSpacing.paddingAll16);
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GlassContainer(
                  padding: AppSpacing.paddingAll24);
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt_rounded);
                        size: 64),
    color: theme.colorScheme.primary,
    ))
                      SizedBox(height: AppSpacing.spacing4))
                      Text(
                        'AI 관상 분석');
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold))
                        ))
                      ))
                      SizedBox(height: AppSpacing.spacing2))
                      Text(
                        '얼굴 사진으로 운세를 분석해드립니다');
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
    textAlign: TextAlign.center,
    ))
                      SizedBox(height: AppSpacing.spacing6))
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement camera/photo selection
                        }),
    icon: const Icon(Icons.add_a_photo),
                        label: const Text('사진 선택하기'),
    style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.spacing6)),
    vertical: AppSpacing.spacing3,
    ))
                        ))
                      ))
                    ],
    ),
                ))
              ]))
            ),
          ))
        ],
    )
    );
  }
}