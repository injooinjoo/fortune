import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../constants/fortune_constants.dart';

class GenderStep extends StatefulWidget {
  final Function(Gender) onGenderChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const GenderStep({
    super.key,
    required this.onGenderChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  Gender? _selectedGender;

  void _selectGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderChanged(gender);
    
    // Auto-advance after selection
    Future.delayed(Duration(milliseconds: 300), () {
      widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
            ),
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '성별을 선택해주세요',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms).shimmer(
                  duration: 1200.ms,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '음양의 조화를 살펴볼게요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                const SizedBox(height: 60),
                
                // Gender buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGenderButton(
                      gender: Gender.female,
                      label: '여자',
                      isSelected: _selectedGender == Gender.female,
                    ).animate(delay: 500.ms).fadeIn(duration: 600.ms).scale(
                      begin: Offset(0.8, 0.8),
                      end: Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                    const SizedBox(width: 20),
                    _buildGenderButton(
                      gender: Gender.male,
                      label: '남자',
                      isSelected: _selectedGender == Gender.male,
                    ).animate(delay: 600.ms).fadeIn(duration: 600.ms).scale(
                      begin: Offset(0.8, 0.8),
                      end: Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required Gender gender,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _selectGender(gender),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              gender == Gender.female ? Icons.female : Icons.male,
              size: 48,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}