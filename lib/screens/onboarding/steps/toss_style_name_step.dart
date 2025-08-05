import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class TossStyleNameStep extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final VoidCallback onNext;
  
  const TossStyleNameStep({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
  });

  @override
  State<TossStyleNameStep> createState() => _TossStyleNameStepState();
}

class _TossStyleNameStepState extends State<TossStyleNameStep> {
  late TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _isValid = _nameController.text.isNotEmpty;
    
    _nameController.addListener(() {
      setState(() {
        _isValid = _nameController.text.trim().isNotEmpty;
      });
      widget.onNameChanged(_nameController.text.trim());
    });
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    
                    // Question text
                    Text(
                      '이름이 뭐예요?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Input field with underline only
                    TextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '이름',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue[600]!,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        // Limit length to prevent extremely long names
                        LengthLimitingTextInputFormatter(50),
                      ],
                    ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                  ],
                ),
              ),
            ),
            
            // Bottom button area
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValid ? widget.onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid ? Colors.blue[600] : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}