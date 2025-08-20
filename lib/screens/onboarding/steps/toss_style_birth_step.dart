import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/toss_number_pad.dart';
import '../../../core/theme/toss_theme.dart';

class TossStyleBirthStep extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(DateTime) onBirthDateChanged;
  final Function(TimeOfDay)? onBirthTimeChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const TossStyleBirthStep({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onBirthDateChanged,
    this.onBirthTimeChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TossStyleBirthStep> createState() => _TossStyleBirthStepState();
}

class _TossStyleBirthStepState extends State<TossStyleBirthStep> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _timeFocusNode = FocusNode();
  
  bool _isDateValid = false;
  bool _isTimeValid = false;
  bool _showTimeInput = false;
  bool _isTimeUnknown = false;
  bool _isDateFieldFocused = false;
  bool _isTimeFieldFocused = false;
  bool _isInputMode = true; // 입력 모드 - 처음부터 true로 설정
  
  @override
  void initState() {
    super.initState();
    
    // Initialize date
    if (widget.initialDate != null) {
      _dateController.text = DateFormat('yyyy.MM.dd').format(widget.initialDate!);
      _isDateValid = true;
      _showTimeInput = true;
    }
    
    // Initialize time
    if (widget.initialTime != null) {
      _timeController.text = '${widget.initialTime!.hour.toString().padLeft(2, '0')}:${widget.initialTime!.minute.toString().padLeft(2, '0')}';
      _isTimeValid = true;
    }
    
    _dateController.addListener(_onDateTextChanged);
    _timeController.addListener(_onTimeTextChanged);
    
    // Add focus listeners with extensive logging
    _dateFocusNode.addListener(() {
      print('[FocusListener] Date focus changed: ${_dateFocusNode.hasFocus} at ${DateTime.now()}');
      setState(() {
        _isDateFieldFocused = _dateFocusNode.hasFocus;
        print('[FocusListener] _isDateFieldFocused set to: $_isDateFieldFocused');
      });
    });
    
    _timeFocusNode.addListener(() {
      print('[FocusListener] Time focus changed: ${_timeFocusNode.hasFocus} at ${DateTime.now()}');
      setState(() {
        _isTimeFieldFocused = _timeFocusNode.hasFocus;
        print('[FocusListener] _isTimeFieldFocused set to: $_isTimeFieldFocused');
      });
    });
    
    // Auto-focus when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[Init] Auto-focusing date field at ${DateTime.now()}');
      _dateFocusNode.requestFocus();
      setState(() {
        _isDateFieldFocused = true;
        _isInputMode = true; // 입력 모드 시작
        print('[Init] Initial state - _isDateFieldFocused: true, _isInputMode: true');
      });
    });
  }
  
  void _onDateTextChanged() {
    // Remove any non-digit characters
    final text = _dateController.text.replaceAll(RegExp(r'[^0-9]'), '');
    print('[DateTextChanged] Raw text: $text, Controller text: ${_dateController.text}');
    
    // Format the text as YYYY년 MM월 DD일
    String formatted = '';
    for (int i = 0; i < text.length && i < 8; i++) {
      formatted += text[i];
      
      // Add labels after specific positions
      if (i == 3 && text.length > 4) {
        formatted += '년 ';
      } else if (i == 5 && text.length > 6) {
        formatted += '월 ';
      } else if (i == 7) {
        formatted += '일';
      }
    }
    
    // Add label even for partial input
    if (text.length == 4) {
      formatted += '년';
    } else if (text.length == 6) {
      formatted += '월';
    }
    
    // Update text if formatting changed
    if (formatted != _dateController.text) {
      _dateController.value = TextEditingValue(
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
          print('[DateValidation] Valid date entered: $date');
          setState(() {
            _isDateValid = true;
            if (!_showTimeInput) {
              _showTimeInput = true;
              print('[DateValidation] Showing time input, switching focus to time field');
              // Auto focus on time field after successful date entry
              Future.delayed(const Duration(milliseconds: 100), () {
                _timeFocusNode.requestFocus();
                setState(() {
                  _isTimeFieldFocused = true;
                  _isDateFieldFocused = false;
                  // 입력 모드는 계속 유지
                  print('[DateValidation] Focus switched to time field, _isInputMode still: $_isInputMode');
                });
              });
            }
          });
          widget.onBirthDateChanged(date);
        } else {
          setState(() {
            _isDateValid = false;
            _showTimeInput = false;
          });
        }
      } catch (e) {
        setState(() {
          _isDateValid = false;
          _showTimeInput = false;
        });
      }
    } else {
      setState(() {
        _isDateValid = false;
        _showTimeInput = false;
      });
    }
  }
  
  void _onTimeTextChanged() {
    // Remove any non-digit characters
    final text = _timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    print('[TimeTextChanged] Raw text: $text, Controller text: ${_timeController.text}');
    
    // Format the text as N시 or NN시 (1시, 2시, 10시, 11시, etc.)
    String formatted = '';
    if (text.isNotEmpty) {
      final hour = int.tryParse(text) ?? 0;
      if (hour >= 0 && hour <= 23) {
        formatted = '$hour시';
        
        // Set time as valid and default to 00 minutes
        final timeOfDay = TimeOfDay(hour: hour, minute: 0);
        print('[TimeValidation] Valid time entered: $hour시');
        setState(() {
          _isTimeValid = true;
          // 시간 입력 완료 시에만 입력 모드 종료 고려
          print('[TimeValidation] Time is valid, _isInputMode: $_isInputMode');
        });
        if (widget.onBirthTimeChanged != null) {
          widget.onBirthTimeChanged!(timeOfDay);
        }
      } else {
        setState(() {
          _isTimeValid = false;
        });
      }
    } else {
      setState(() {
        _isTimeValid = false;
      });
    }
    
    // Update text if formatting changed
    if (formatted != _timeController.text) {
      _timeController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
  
  void _handleNumberInput(String number) {
    print('\n[NumberInput] ========== START ==========');
    print('[NumberInput] Number pressed: $number at ${DateTime.now()}');
    print('[NumberInput] Current state:');
    print('  - _isDateFieldFocused: $_isDateFieldFocused');
    print('  - _isTimeFieldFocused: $_isTimeFieldFocused');
    print('  - _showTimeInput: $_showTimeInput');
    print('  - _isInputMode: $_isInputMode');
    print('  - Date hasFocus: ${_dateFocusNode.hasFocus}');
    print('  - Time hasFocus: ${_timeFocusNode.hasFocus}');
    
    // 어떤 필드에 입력할지 결정
    bool shouldInputToDate = !_showTimeInput || _isDateFieldFocused || 
                            (!_isDateFieldFocused && !_isTimeFieldFocused && !_showTimeInput);
    bool shouldInputToTime = _showTimeInput && (_isTimeFieldFocused || 
                            (!_isDateFieldFocused && !_isTimeFieldFocused && _isDateValid));
    
    print('[NumberInput] Decision: shouldInputToDate=$shouldInputToDate, shouldInputToTime=$shouldInputToTime');
    
    if (shouldInputToDate) {
      print('[NumberInput] Inputting to DATE field');
      // 날짜 필드에 포커스 유지
      if (!_dateFocusNode.hasFocus) {
        print('[NumberInput] Requesting focus for date field');
        _dateFocusNode.requestFocus();
      }
      
      final currentText = _dateController.text.replaceAll(RegExp(r'[^0-9]'), '');
      print('[NumberInput] Current date text (digits only): $currentText');
      
      if (currentText.length < 8) {
        final newText = currentText + number;
        _dateController.text = newText;
        print('[NumberInput] Date text updated to: ${_dateController.text}');
        // 포커스 상태 유지
        setState(() {
          _isDateFieldFocused = true;
          _isTimeFieldFocused = false;
          print('[NumberInput] State updated - date focused');
        });
      } else {
        print('[NumberInput] Date field is full (8 digits)');
      }
    } else if (shouldInputToTime) {
      print('[NumberInput] Inputting to TIME field');
      // 시간 필드에 포커스 유지
      if (!_timeFocusNode.hasFocus) {
        print('[NumberInput] Requesting focus for time field');
        _timeFocusNode.requestFocus();
      }
      
      final currentText = _timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
      print('[NumberInput] Current time text (digits only): $currentText');
      
      if (currentText.length < 2) {  // Max 2 digits for hour (0-23)
        final newText = currentText + number;
        _timeController.text = newText;
        print('[NumberInput] Time text updated to: ${_timeController.text}');
        // 포커스 상태 유지
        setState(() {
          _isTimeFieldFocused = true;
          _isDateFieldFocused = false;
          print('[NumberInput] State updated - time focused');
        });
      } else {
        print('[NumberInput] Time field is full (2 digits)');
      }
    } else {
      print('[NumberInput] WARNING: No field to input to!');
    }
    
    print('[NumberInput] ========== END ==========\n');
  }
  
  void _handleBackspace() {
    if (_isDateFieldFocused) {
      // 포커스 유지
      if (!_dateFocusNode.hasFocus) {
        _dateFocusNode.requestFocus();
      }
      
      final currentText = _dateController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (currentText.isNotEmpty) {
        final newText = currentText.substring(0, currentText.length - 1);
        _dateController.text = newText;
        // 포커스 상태 유지
        setState(() {
          _isDateFieldFocused = true;
          _isTimeFieldFocused = false;
        });
      }
    } else if (_isTimeFieldFocused) {
      // 포커스 유지
      if (!_timeFocusNode.hasFocus) {
        _timeFocusNode.requestFocus();
      }
      
      final currentText = _timeController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (currentText.isNotEmpty) {
        final newText = currentText.substring(0, currentText.length - 1);
        _timeController.text = newText;
        // 포커스 상태 유지
        setState(() {
          _isTimeFieldFocused = true;
          _isDateFieldFocused = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _dateFocusNode.dispose();
    _timeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // 입력 모드일 때는 항상 키패드 표시 (생년월일 입력 시작부터 시간 입력 완료까지)
    final showCustomKeypad = keyboardHeight == 0 && _isInputMode;
    
    print('[Build] ========== BUILD START ==========');
    print('[Build] keyboardHeight: $keyboardHeight');
    print('[Build] _isInputMode: $_isInputMode');
    print('[Build] _isDateFieldFocused: $_isDateFieldFocused');
    print('[Build] _isTimeFieldFocused: $_isTimeFieldFocused');
    print('[Build] _showTimeInput: $_showTimeInput');
    print('[Build] showCustomKeypad: $showCustomKeypad');
    print('[Build] ========== BUILD END ==========');
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer to center content
            const Spacer(),
            
            // Center content - Input fields only
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Birth Date Input - minimal style
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('[DateField] Tapped at ${DateTime.now()}');
                      _dateFocusNode.requestFocus();
                      setState(() {
                        _isDateFieldFocused = true;
                        _isTimeFieldFocused = false;
                        _isInputMode = true; // 입력 모드 활성화
                        print('[DateField] Focus set to date field, _isInputMode: $_isInputMode');
                      });
                    },
                    child: TextField(
                      controller: _dateController,
                      focusNode: _dateFocusNode,
                      readOnly: true,  // Prevent system keyboard
                      showCursor: false,  // Hide cursor
                      enableInteractiveSelection: false,  // Disable text selection
                      style: TossTheme.inputStyle,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '생년월일을 알려주세요',
                        hintStyle: TossTheme.inputStyle.copyWith(
                          color: TossTheme.textGray400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 800),
                  ),
                  
                  // Birth Time Input (show after date is entered)
                  if (_showTimeInput) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        print('[TimeField] Tapped at ${DateTime.now()}');
                        if (!_isTimeUnknown) {
                          _timeFocusNode.requestFocus();
                          setState(() {
                            _isTimeFieldFocused = true;
                            _isDateFieldFocused = false;
                            _isInputMode = true; // 입력 모드 유지
                            print('[TimeField] Focus set to time field, _isInputMode: $_isInputMode');
                          });
                        } else {
                          print('[TimeField] Time is unknown, not focusing');
                        }
                      },
                      child: TextField(
                        controller: _timeController,
                        focusNode: _timeFocusNode,
                        readOnly: true,  // Prevent system keyboard
                        showCursor: false,  // Hide cursor
                        enableInteractiveSelection: false,  // Disable text selection
                        style: TossTheme.inputStyle,
                        textAlign: TextAlign.center,
                        enabled: !_isTimeUnknown,
                        decoration: InputDecoration(
                          hintText: '태어난 시간을 알려주세요',
                          hintStyle: TossTheme.inputStyle.copyWith(
                            color: _isTimeUnknown ? TossTheme.textGray400.withOpacity(0.3) : TossTheme.textGray400,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ).animate().slideY(begin: 0.2, end: 0).fadeIn(
                      duration: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: 12),
                    // Checkbox for "모르겠어요"
                    GestureDetector(
                      onTap: () {
                        print('[TimeUnknown] Checkbox tapped at ${DateTime.now()}');
                        setState(() {
                          _isTimeUnknown = !_isTimeUnknown;
                          print('[TimeUnknown] _isTimeUnknown changed to: $_isTimeUnknown');
                          
                          if (_isTimeUnknown) {
                            _timeController.clear();
                            _isTimeValid = true;  // Allow proceeding when checked
                            _isInputMode = false; // 시간을 모른다고 체크하면 입력 모드 종료
                            print('[TimeUnknown] Time unknown selected, ending input mode');
                            print('[TimeUnknown] _isDateValid: $_isDateValid, _isTimeValid: $_isTimeValid, _isTimeUnknown: $_isTimeUnknown');
                            // Set default time to 12:00 when unknown
                            if (widget.onBirthTimeChanged != null) {
                              widget.onBirthTimeChanged!(const TimeOfDay(hour: 12, minute: 0));
                            }
                          } else {
                            _isTimeValid = false;
                            _isInputMode = true; // 다시 시간 입력하려면 입력 모드 활성화
                            _timeFocusNode.requestFocus();
                            print('[TimeUnknown] Time unknown deselected, reactivating input mode');
                            print('[TimeUnknown] _isDateValid: $_isDateValid, _isTimeValid: $_isTimeValid, _isTimeUnknown: $_isTimeUnknown');
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isTimeUnknown ? TossTheme.primaryBlue : TossTheme.textGray400,
                                width: 2,
                              ),
                              color: _isTimeUnknown ? TossTheme.primaryBlue : Colors.transparent,
                            ),
                            child: _isTimeUnknown
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '모르겠어요',
                            style: TextStyle(
                              fontSize: 14,
                              color: TossTheme.textGray600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    ),
                  ],
                ],
              ),
            ),
            
            const Spacer(),
            
            // Next Button - Show when date and time conditions are met (outside keypad area)
            if (_isDateValid && (_isTimeValid || _isTimeUnknown))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  height: 58,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: TossTheme.primaryButtonStyle(true),
                    child: Text(
                      '다음',
                      style: TossTheme.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            
            // Custom Number Pad - GestureDetector로 감싸서 포커스 유지
            if (showCustomKeypad)
              Column(
                children: [
                  
                  // Number Pad
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // 키패드 영역을 탭해도 포커스 유지
                      if (_isDateFieldFocused && !_dateFocusNode.hasFocus) {
                        _dateFocusNode.requestFocus();
                      } else if (_isTimeFieldFocused && !_timeFocusNode.hasFocus) {
                        _timeFocusNode.requestFocus();
                      }
                    },
                    child: TossNumberPad(
                      onNumberPressed: _handleNumberInput,
                      onBackspacePressed: _handleBackspace,
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.5, end: 0, duration: 300.ms),
            
            // Bottom padding for safe area
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}