import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biorhythm_input_page.dart';

class BiorhythmFortunePage extends ConsumerWidget {
  const BiorhythmFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BiorhythmInputPage();
  }
}