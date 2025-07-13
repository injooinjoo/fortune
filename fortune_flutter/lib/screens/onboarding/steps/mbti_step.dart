import 'package:flutter/material.dart';
import '../widgets/bottom_sheet_mbti_picker.dart';

class MbtiStep extends StatefulWidget {
  final Function(String) onMbtiChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final bool isLoading;
  
  const MbtiStep({
    super.key,
    required this.onMbtiChanged,
    required this.onComplete,
    required this.onBack,
    required this.isLoading,
  });

  @override
  State<MbtiStep> createState() => _MbtiStepState();
}

class _MbtiStepState extends State<MbtiStep> {
  String? _e_i;
  String? _n_s;
  String? _t_f;
  String? _j_p;
  
  int _currentDimension = 0;
  
  final List<Map<String, String>> dimensions = [
    {'title': '에너지 방향', 'option1': 'E', 'option2': 'I'},
    {'title': '인식 기능', 'option1': 'N', 'option2': 'S'},
    {'title': '판단 기능', 'option1': 'T', 'option2': 'F'},
    {'title': '생활 양식', 'option1': 'J', 'option2': 'P'},
  ];

  @override
  void initState() {
    super.initState();
  }

  void _showMbtiPicker() async {
    if (_currentDimension >= dimensions.length) return;
    
    final dimension = dimensions[_currentDimension];
    final selected = await BottomSheetMbtiPicker.show(
      context,
      dimension: dimension['title']!,
      option1: dimension['option1']!,
      option2: dimension['option2']!,
      selectedOption: _getSelectedOption(_currentDimension),
    );
    
    if (selected != null) {
      setState(() {
        switch (_currentDimension) {
          case 0:
            _e_i = selected;
            break;
          case 1:
            _n_s = selected;
            break;
          case 2:
            _t_f = selected;
            break;
          case 3:
            _j_p = selected;
            break;
        }
        _currentDimension++;
      });
      
      // Update MBTI if all dimensions are selected
      if (_e_i != null && _n_s != null && _t_f != null && _j_p != null) {
        final mbti = '$_e_i$_n_s$_t_f$_j_p';
        widget.onMbtiChanged(mbti);
      }
      
      // Show next picker or complete
      if (_currentDimension < dimensions.length) {
        Future.delayed(Duration(milliseconds: 300), () {
          _showMbtiPicker();
        });
      }
    }
  }
  
  String? _getSelectedOption(int dimension) {
    switch (dimension) {
      case 0:
        return _e_i;
      case 1:
        return _n_s;
      case 2:
        return _t_f;
      case 3:
        return _j_p;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _e_i != null && _n_s != null && _t_f != null && _j_p != null;
    final mbti = isComplete ? '$_e_i$_n_s$_t_f$_j_p' : '';
    
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
                  'MBTI를 선택해주세요',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // MBTI display or start button
                if (_currentDimension == 0 && _e_i == null)
                  // Show start button
                  ElevatedButton(
                    onPressed: _showMbtiPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'MBTI 선택 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  // Show MBTI progress
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMbtiLetter(_e_i),
                        const SizedBox(width: 8),
                        _buildMbtiLetter(_n_s),
                        const SizedBox(width: 8),
                        _buildMbtiLetter(_t_f),
                        const SizedBox(width: 8),
                        _buildMbtiLetter(_j_p),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                if (!isComplete)
                  Text(
                    '${_currentDimension}/4 단계',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                
                if (isComplete)
                  Column(
                    children: [
                      Text(
                        mbti,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentDimension = 0;
                            _e_i = null;
                            _n_s = null;
                            _t_f = null;
                            _j_p = null;
                          });
                          _showMbtiPicker();
                        },
                        child: Text('다시 선택하기'),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 80),
                
                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isComplete && !widget.isLoading ? widget.onComplete : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: widget.isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMbtiLetter(String? letter) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: letter != null ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: letter != null ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          letter ?? '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: letter != null ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}