import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TossStyleBirthStep extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onBirthDateChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const TossStyleBirthStep({
    super.key,
    this.initialDate,
    required this.onBirthDateChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TossStyleBirthStep> createState() => _TossStyleBirthStepState();
}

class _TossStyleBirthStepState extends State<TossStyleBirthStep> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  DateTime? _selectedDate;
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate;
      _controller.text = DateFormat('yyyy.MM.dd').format(widget.initialDate!);
      _isValid = true;
    }
    
    _controller.addListener(_onTextChanged);
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  void _onTextChanged() {
    final text = _controller.text.replaceAll('.', '');
    
    // Format the text as YYYY.MM.DD
    String formatted = '';
    for (int i = 0; i < text.length && i < 8; i++) {
      if (i == 4 || i == 6) {
        formatted += '.';
      }
      formatted += text[i];
    }
    
    // Update text if formatting changed
    if (formatted != _controller.text) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    // Validate date
    if (text.length == 8) {
      try {
        final year = int.parse(text.substring(0, 4));
        final month = int.parse(text.substring(4, 6));
        final day = int.parse(text.substring(6, 8));
        
        final date = DateTime(year, month, day);
        
        // Check if date is valid and not in the future
        if (date.year == year && 
            date.month == month && 
            date.day == day &&
            date.isBefore(DateTime.now())) {
          setState(() {
            _selectedDate = date;
            _isValid = true;
          });
          widget.onBirthDateChanged(date);
        } else {
          setState(() {
            _isValid = false;
          });
        }
      } catch (e) {
        setState(() {
          _isValid = false;
        });
      }
    } else {
      setState(() {
        _isValid = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    const SizedBox(height: 40),
                    
                    // Back button
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_ios),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Question text
                    Text(
                      '생년월일을 알려주세요',
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
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'YYYY.MM.DD',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
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
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
                    
                    const SizedBox(height: 12),
                    
                    // Helper text
                    Text(
                      '정확한 운세를 위해 필요해요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
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