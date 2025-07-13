import 'package:flutter/material.dart';
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
                ),
                const SizedBox(height: 60),
                
                // Gender buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGenderButton(
                      gender: Gender.female,
                      label: '여자',
                      isSelected: _selectedGender == Gender.female,
                    ),
                    const SizedBox(width: 20),
                    _buildGenderButton(
                      gender: Gender.male,
                      label: '남자',
                      isSelected: _selectedGender == Gender.male,
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