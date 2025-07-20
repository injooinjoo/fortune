# 🛠️ Fortune 앱 구현 예제

## 📚 목차
1. [새로운 운세 타입 추가하기](#새로운-운세-타입-추가하기)
2. [배치 운세 패키지 만들기](#배치-운세-패키지-만들기)
3. [인터랙티브 기능 구현하기](#인터랙티브-기능-구현하기)
4. [커스텀 UI 컴포넌트 만들기](#커스텀-ui-컴포넌트-만들기)
5. [성능 최적화 예제](#성능-최적화-예제)

---

## 🆕 새로운 운세 타입 추가하기

### 예제: "펫 궁합 운세" 추가

펫과 주인의 궁합을 분석하는 새로운 운세 타입을 추가해보겠습니다.

#### 1. 운세 타입 정의

**파일**: `/fortune_flutter/lib/core/constants/fortune_type_names.dart`

```dart
static const Map<String, String> names = {
  // 기존 운세들...
  'pet-compatibility': '펫 궁합',  // 새로 추가
};

static String getCategory(String fortuneType) {
  // 기존 코드...
  if (fortuneType == 'pet-compatibility') {
    return '특별 운세';
  }
  // ...
}
```

#### 2. 데이터 모델 생성

**파일**: `/fortune_flutter/lib/domain/models/pet_compatibility.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_compatibility.freezed.dart';
part 'pet_compatibility.g.dart';

@freezed
class PetCompatibility with _$PetCompatibility {
  const factory PetCompatibility({
    required String petType,
    required String petName,
    required DateTime petBirthDate,
    required String ownerName,
    required DateTime ownerBirthDate,
    required int compatibilityScore,
    required Map<String, int> detailScores,
    required List<String> advice,
    required String summary,
  }) = _PetCompatibility;

  factory PetCompatibility.fromJson(Map<String, dynamic> json) =>
      _$PetCompatibilityFromJson(json);
}
```

#### 3. API 엔드포인트 구현

**파일**: `/supabase/functions/fortune-pet-compatibility/index.ts`

```typescript
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from '@supabase/supabase-js'
import { corsHeaders } from '../_shared/cors.ts'

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')!
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { 
      userId,
      petType,
      petName,
      petBirthDate,
      ownerName,
      ownerBirthDate 
    } = await req.json()

    // 입력 검증
    if (!userId || !petType || !petName || !petBirthDate || !ownerBirthDate) {
      throw new Error('필수 파라미터가 누락되었습니다')
    }

    // Supabase 클라이언트 생성
    const supabase = createClient(supabaseUrl, supabaseKey)

    // 토큰 확인
    const { data: userTokens } = await supabase
      .from('user_tokens')
      .select('balance')
      .eq('user_id', userId)
      .single()

    if (!userTokens || userTokens.balance < 45) {
      throw new Error('토큰이 부족합니다')
    }

    // OpenAI로 운세 생성
    const prompt = `
    펫과 주인의 궁합을 분석해주세요.
    
    주인 정보:
    - 이름: ${ownerName}
    - 생일: ${ownerBirthDate}
    
    펫 정보:
    - 종류: ${petType}
    - 이름: ${petName}
    - 생일: ${petBirthDate}
    
    다음 형식으로 JSON 응답을 생성해주세요:
    {
      "compatibilityScore": 0-100,
      "detailScores": {
        "communication": 0-100,
        "lifestyle": 0-100,
        "emotional": 0-100,
        "health": 0-100
      },
      "summary": "전체적인 궁합 요약",
      "advice": ["조언1", "조언2", "조언3"]
    }
    `

    const openAIResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: '당신은 펫과 주인의 궁합을 분석하는 전문가입니다.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        response_format: { type: "json_object" }
      }),
    })

    const aiData = await openAIResponse.json()
    const fortuneContent = JSON.parse(aiData.choices[0].message.content)

    // 결과 저장
    const { data: fortune, error: saveError } = await supabase
      .from('fortunes')
      .insert({
        user_id: userId,
        type: 'pet-compatibility',
        content: {
          ...fortuneContent,
          petType,
          petName,
          petBirthDate,
          ownerName,
          ownerBirthDate
        },
        tokens_used: 45
      })
      .select()
      .single()

    if (saveError) throw saveError

    // 토큰 차감
    await supabase
      .from('user_tokens')
      .update({ balance: userTokens.balance - 45 })
      .eq('user_id', userId)

    return new Response(
      JSON.stringify({ 
        success: true, 
        data: fortune 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

#### 4. Flutter 서비스 레이어

**파일**: `/fortune_flutter/lib/services/pet_compatibility_service.dart`

```dart
import 'package:fortune_app/core/error/exceptions.dart';
import 'package:fortune_app/domain/models/pet_compatibility.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetCompatibilityService {
  final SupabaseClient _supabase;

  PetCompatibilityService(this._supabase);

  Future<PetCompatibility> getPetCompatibility({
    required String petType,
    required String petName,
    required DateTime petBirthDate,
    required String ownerName,
    required DateTime ownerBirthDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw UnauthorizedException();

      final response = await _supabase.functions.invoke(
        'fortune-pet-compatibility',
        body: {
          'userId': userId,
          'petType': petType,
          'petName': petName,
          'petBirthDate': petBirthDate.toIso8601String(),
          'ownerName': ownerName,
          'ownerBirthDate': ownerBirthDate.toIso8601String(),
        },
      );

      if (response.status != 200) {
        throw FortuneException('Error: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      if (!data['success']) {
        throw FortuneException(data['error'] ?? '알 수 없는 오류');
      }

      return PetCompatibility.fromJson(data['data']['content']);
    } catch (e) {
      throw FortuneException('펫 궁합 조회 실패: ${e.toString()}');
    }
  }
}
```

#### 5. UI 구현

**파일**: `/fortune_flutter/lib/features/fortune/presentation/pages/pet_compatibility_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_app/core/theme/app_theme.dart';
import 'package:fortune_app/features/fortune/presentation/widgets/fortune_card.dart';

class PetCompatibilityPage extends ConsumerStatefulWidget {
  const PetCompatibilityPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PetCompatibilityPage> createState() => _PetCompatibilityPageState();
}

class _PetCompatibilityPageState extends ConsumerState<PetCompatibilityPage> {
  final _formKey = GlobalKey<FormState>();
  
  String _petType = '강아지';
  String _petName = '';
  DateTime? _petBirthDate;
  String _ownerName = '';
  DateTime? _ownerBirthDate;

  @override
  Widget build(BuildContext context) {
    final fortuneAsync = ref.watch(petCompatibilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('펫 궁합'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 설명 카드
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '반려동물과의 궁합을 확인해보세요!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '생년월일을 기반으로 펫과의 정서적, 생활적 궁합을 분석합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // 입력 폼
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // 펫 종류 선택
                  DropdownButtonFormField<String>(
                    value: _petType,
                    decoration: InputDecoration(
                      labelText: '반려동물 종류',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                    items: ['강아지', '고양이', '토끼', '햄스터', '새', '기타']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _petType = value!;
                      });
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // 펫 이름
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '반려동물 이름',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _petName = value!;
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // 펫 생일
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '반려동물 생일',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _petBirthDate != null
                            ? '${_petBirthDate!.year}년 ${_petBirthDate!.month}월 ${_petBirthDate!.day}일'
                            : '선택해주세요',
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Divider(),
                  
                  SizedBox(height: 24),
                  
                  // 주인 이름
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '주인 이름',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _ownerName = value!;
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // 주인 생일
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: '주인 생일',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _ownerBirthDate != null
                            ? '${_ownerBirthDate!.year}년 ${_ownerBirthDate!.month}월 ${_ownerBirthDate!.day}일'
                            : '선택해주세요',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // 운세 보기 버튼
            ElevatedButton(
              onPressed: _getCompatibility,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Text(
                    '궁합 보기 (45 토큰)',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // 결과 표시
            fortuneAsync.when(
              data: (compatibility) {
                if (compatibility == null) return SizedBox.shrink();
                
                return Column(
                  children: [
                    // 종합 점수 카드
                    Card(
                      elevation: 8,
                      color: AppTheme.primaryColor,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              '${_petName}와 ${_ownerName}님의 궁합',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: compatibility.compatibilityScore / 100,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white30,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${compatibility.compatibilityScore}점',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _getScoreMessage(compatibility.compatibilityScore),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // 상세 점수
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '상세 궁합 분석',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 16),
                            _buildDetailScore(
                              '의사소통',
                              compatibility.detailScores['communication']!,
                              Icons.chat,
                            ),
                            _buildDetailScore(
                              '라이프스타일',
                              compatibility.detailScores['lifestyle']!,
                              Icons.home,
                            ),
                            _buildDetailScore(
                              '정서적 교감',
                              compatibility.detailScores['emotional']!,
                              Icons.favorite,
                            ),
                            _buildDetailScore(
                              '건강 관리',
                              compatibility.detailScores['health']!,
                              Icons.health_and_safety,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // 요약
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '종합 분석',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            Text(
                              compatibility.summary,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // 조언
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '더 나은 관계를 위한 조언',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: 8),
                            ...compatibility.advice.map((advice) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 20,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      advice,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('궁합을 분석하고 있습니다...'),
                  ],
                ),
              ),
              error: (error, stack) => Card(
                color: Colors.red[50],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '오류: ${error.toString()}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailScore(String label, int score, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '$score점',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreMessage(int score) {
    if (score >= 90) return '천생연분! 완벽한 궁합입니다';
    if (score >= 80) return '아주 좋은 궁합입니다';
    if (score >= 70) return '좋은 궁합입니다';
    if (score >= 60) return '노력하면 좋은 관계가 될 수 있습니다';
    return '서로를 이해하는 노력이 필요합니다';
  }

  Future<void> _selectDate(BuildContext context, bool isPet) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: Locale('ko', 'KR'),
    );
    
    if (picked != null) {
      setState(() {
        if (isPet) {
          _petBirthDate = picked;
        } else {
          _ownerBirthDate = picked;
        }
      });
    }
  }

  void _getCompatibility() {
    if (_formKey.currentState!.validate() &&
        _petBirthDate != null &&
        _ownerBirthDate != null) {
      _formKey.currentState!.save();
      
      ref.read(petCompatibilityProvider.notifier).getCompatibility(
        petType: _petType,
        petName: _petName,
        petBirthDate: _petBirthDate!,
        ownerName: _ownerName,
        ownerBirthDate: _ownerBirthDate!,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('모든 정보를 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

#### 6. Provider 구현

**파일**: `/fortune_flutter/lib/features/fortune/presentation/providers/pet_compatibility_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_app/domain/models/pet_compatibility.dart';
import 'package:fortune_app/services/pet_compatibility_service.dart';

final petCompatibilityServiceProvider = Provider((ref) {
  return PetCompatibilityService(ref.watch(supabaseProvider));
});

final petCompatibilityProvider = 
    StateNotifierProvider<PetCompatibilityNotifier, AsyncValue<PetCompatibility?>>((ref) {
  return PetCompatibilityNotifier(ref.watch(petCompatibilityServiceProvider));
});

class PetCompatibilityNotifier extends StateNotifier<AsyncValue<PetCompatibility?>> {
  final PetCompatibilityService _service;

  PetCompatibilityNotifier(this._service) : super(AsyncValue.data(null));

  Future<void> getCompatibility({
    required String petType,
    required String petName,
    required DateTime petBirthDate,
    required String ownerName,
    required DateTime ownerBirthDate,
  }) async {
    state = AsyncValue.loading();
    
    try {
      final compatibility = await _service.getPetCompatibility(
        petType: petType,
        petName: petName,
        petBirthDate: petBirthDate,
        ownerName: ownerName,
        ownerBirthDate: ownerBirthDate,
      );
      
      state = AsyncValue.data(compatibility);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
```

---

## 📦 배치 운세 패키지 만들기

### 예제: "연애 종합 패키지"

여러 연애 관련 운세를 한 번에 볼 수 있는 패키지를 만들어보겠습니다.

#### 1. 패키지 정의

**파일**: `/fortune_flutter/lib/core/constants/fortune_packages.dart`

```dart
class FortunePackages {
  static const lovePackage = FortunePackage(
    id: 'love-comprehensive',
    name: '연애 종합 패키지',
    description: '연애의 모든 것을 한 번에!',
    fortuneTypes: [
      'love',
      'marriage',
      'compatibility',
      'chemistry',
      'celebrity-match',
    ],
    originalPrice: 230,  // 개별 구매 시 총 토큰
    packagePrice: 149,   // 패키지 가격 (35% 할인)
    iconAsset: 'assets/icons/love_package.png',
  );
  
  static const List<FortunePackage> allPackages = [
    lovePackage,
    // 다른 패키지들...
  ];
}

class FortunePackage {
  final String id;
  final String name;
  final String description;
  final List<String> fortuneTypes;
  final int originalPrice;
  final int packagePrice;
  final String iconAsset;
  
  const FortunePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.fortuneTypes,
    required this.originalPrice,
    required this.packagePrice,
    required this.iconAsset,
  });
  
  double get discountRate => 
      ((originalPrice - packagePrice) / originalPrice * 100).roundToDouble();
}
```

#### 2. 배치 API 구현

**파일**: `/supabase/functions/fortune-batch/index.ts`

```typescript
interface BatchFortuneRequest {
  userId: string;
  packageId: string;
  fortuneTypes: string[];
  userInfo: {
    birthDate: string;
    gender?: string;
    name?: string;
  };
  additionalInfo?: Record<string, any>;
}

serve(async (req) => {
  try {
    const request: BatchFortuneRequest = await req.json();
    const { userId, packageId, fortuneTypes, userInfo } = request;

    // 패키지 검증
    const packageCost = calculatePackageCost(packageId, fortuneTypes);
    
    // 토큰 확인
    const userTokens = await checkUserTokens(userId, packageCost);
    
    // 병렬로 모든 운세 생성
    const fortunePromises = fortuneTypes.map(async (type) => {
      try {
        const fortune = await generateFortune({
          type,
          userInfo,
          isPackage: true,
        });
        
        return {
          type,
          success: true,
          data: fortune,
          error: null,
        };
      } catch (error) {
        return {
          type,
          success: false,
          data: null,
          error: error.message,
        };
      }
    });

    const results = await Promise.all(fortunePromises);
    
    // 결과 저장
    const batch = await saveBatchFortune({
      userId,
      packageId,
      results,
      tokensUsed: packageCost,
    });
    
    // 토큰 차감
    await deductTokens(userId, packageCost);
    
    return new Response(
      JSON.stringify({
        success: true,
        batchId: batch.id,
        results,
        tokensUsed: packageCost,
        savedAmount: calculateSavedAmount(fortuneTypes, packageCost),
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
    
  } catch (error) {
    return handleError(error);
  }
});
```

#### 3. 패키지 UI

**파일**: `/fortune_flutter/lib/features/fortune/presentation/pages/package_detail_page.dart`

```dart
class PackageDetailPage extends ConsumerWidget {
  final FortunePackage package;
  
  const PackageDetailPage({
    Key? key,
    required this.package,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batchResults = ref.watch(batchFortuneProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(package.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 패키지 헤더
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    package.iconAsset,
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    package.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    package.description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${package.discountRate.toStringAsFixed(0)}% 할인',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 포함된 운세 목록
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '포함된 운세',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  ...package.fortuneTypes.map((type) {
                    final name = FortuneTypeNames.getName(type);
                    final cost = TOKEN_COSTS[type] ?? 50;
                    
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          _getFortuneIcon(type),
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(name),
                        trailing: Text(
                          '$cost 토큰',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            
            // 가격 정보
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('정상가'),
                      Text(
                        '${package.originalPrice} 토큰',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '패키지 가격',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${package.packagePrice} 토큰',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '절약 금액',
                        style: TextStyle(color: Colors.green),
                      ),
                      Text(
                        '${package.originalPrice - package.packagePrice} 토큰',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 구매 버튼
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchasePackage(context, ref),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(
                    '패키지 구매하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            // 결과 표시 (구매 후)
            if (batchResults != null) ...[
              Divider(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '운세 결과',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    ...batchResults.results.map((result) {
                      final name = FortuneTypeNames.getName(result.type);
                      
                      return Card(
                        child: ExpansionTile(
                          leading: Icon(
                            result.success
                                ? Icons.check_circle
                                : Icons.error,
                            color: result.success
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(name),
                          children: [
                            if (result.success)
                              FortuneResultWidget(
                                fortune: result.data!,
                              )
                            else
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '오류: ${result.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _purchasePackage(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('패키지 구매'),
        content: Text(
          '${package.packagePrice} 토큰을 사용하여\n${package.name}을 구매하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(batchFortuneProvider.notifier).purchasePackage(package);
            },
            child: Text('구매'),
          ),
        ],
      ),
    );
  }
  
  IconData _getFortuneIcon(String type) {
    final iconMap = {
      'love': Icons.favorite,
      'marriage': Icons.cake,
      'compatibility': Icons.people,
      'chemistry': Icons.science,
      'celebrity-match': Icons.star,
    };
    
    return iconMap[type] ?? Icons.auto_awesome;
  }
}
```

---

## 🎮 인터랙티브 기능 구현하기

### 예제: "타로 카드 운세"

사용자가 직접 카드를 선택하는 인터랙티브 타로 운세를 구현해보겠습니다.

#### 1. 타로 카드 모델

**파일**: `/fortune_flutter/lib/domain/models/tarot_card.dart`

```dart
@freezed
class TarotCard with _$TarotCard {
  const factory TarotCard({
    required int id,
    required String name,
    required String nameKr,
    required String imageUrl,
    required String meaning,
    required String reversedMeaning,
    required TarotSuit suit,
  }) = _TarotCard;
}

enum TarotSuit {
  majorArcana,
  wands,
  cups,
  swords,
  pentacles,
}

@freezed
class TarotReading with _$TarotReading {
  const factory TarotReading({
    required List<TarotCard> selectedCards,
    required TarotSpread spreadType,
    required Map<String, String> interpretation,
    required String overallMessage,
    required DateTime readingDate,
  }) = _TarotReading;
}

enum TarotSpread {
  single,      // 1장
  pastPresentFuture,  // 3장
  celticCross,  // 10장
}
```

#### 2. 인터랙티브 UI 구현

**파일**: `/fortune_flutter/lib/features/fortune/presentation/pages/tarot_fortune_page.dart`

```dart
class TarotFortunePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<TarotFortunePage> createState() => _TarotFortunePageState();
}

class _TarotFortunePageState extends ConsumerState<TarotFortunePage>
    with TickerProviderStateMixin {
  
  TarotSpread _selectedSpread = TarotSpread.pastPresentFuture;
  List<int> _selectedCardIndices = [];
  late AnimationController _shuffleController;
  late List<Animation<double>> _cardAnimations;
  
  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _initializeAnimations();
  }
  
  void _initializeAnimations() {
    _cardAnimations = List.generate(
      78,  // 타로 카드 총 개수
      (index) => Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: _shuffleController,
          curve: Interval(
            index / 78,
            (index + 1) / 78,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final tarotState = ref.watch(tarotFortuneProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('타로 운세'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 스프레드 선택
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '스프레드 선택',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),
                        SegmentedButton<TarotSpread>(
                          segments: [
                            ButtonSegment(
                              value: TarotSpread.single,
                              label: Text('원 카드'),
                              icon: Icon(Icons.looks_one),
                            ),
                            ButtonSegment(
                              value: TarotSpread.pastPresentFuture,
                              label: Text('과거-현재-미래'),
                              icon: Icon(Icons.looks_3),
                            ),
                            ButtonSegment(
                              value: TarotSpread.celticCross,
                              label: Text('켈틱 크로스'),
                              icon: Icon(Icons.apps),
                            ),
                          ],
                          selected: {_selectedSpread},
                          onSelectionChanged: (Set<TarotSpread> selected) {
                            setState(() {
                              _selectedSpread = selected.first;
                              _selectedCardIndices.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // 카드 선택 영역
                Card(
                  color: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '카드를 선택하세요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_selectedCardIndices.length} / ${_getRequiredCards()} 장 선택됨',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // 카드 덱
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: List.generate(
                              78,
                              (index) => _buildCard(index),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        
                        // 셔플 버튼
                        ElevatedButton.icon(
                          onPressed: _shuffleCards,
                          icon: Icon(Icons.shuffle),
                          label: Text('카드 섞기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // 선택된 카드 표시
                if (_selectedCardIndices.isNotEmpty) ...[
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '선택된 카드',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _selectedCardIndices.map((index) {
                              return _buildSelectedCard(index);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                ],
                
                // 리딩 시작 버튼
                if (_selectedCardIndices.length == _getRequiredCards())
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startReading,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        '타로 리딩 시작 (40 토큰)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: 24),
                
                // 리딩 결과
                tarotState.when(
                  data: (reading) {
                    if (reading == null) return SizedBox.shrink();
                    
                    return TarotReadingResult(
                      reading: reading,
                      spread: _selectedSpread,
                    );
                  },
                  loading: () => Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '타로 카드를 해석하고 있습니다...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  error: (error, stack) => Card(
                    color: Colors.red.withOpacity(0.9),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '오류: ${error.toString()}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCard(int index) {
    final isSelected = _selectedCardIndices.contains(index);
    final canSelect = _selectedCardIndices.length < _getRequiredCards();
    
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, child) {
        final angle = _cardAnimations[index].value * pi * 2;
        final offset = Offset(
          cos(angle) * 50,
          sin(angle) * 20,
        );
        
        return Positioned(
          left: 100 + offset.dx + index * 2,
          top: 50 + offset.dy,
          child: GestureDetector(
            onTap: () {
              if (!isSelected && canSelect) {
                setState(() {
                  _selectedCardIndices.add(index);
                });
                
                // 선택 애니메이션
                HapticFeedback.mediumImpact();
              }
            },
            child: Transform.rotate(
              angle: angle * 0.1,
              child: Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.amber : Colors.white,
                    width: isSelected ? 3 : 1,
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/tarot/card_back.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? Colors.amber.withOpacity(0.5)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: isSelected ? 10 : 5,
                      spreadRadius: isSelected ? 2 : 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSelectedCard(int index) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber,
          width: 2,
        ),
        image: DecorationImage(
          image: AssetImage('assets/tarot/card_back.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Text(
          '${_selectedCardIndices.indexOf(index) + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  int _getRequiredCards() {
    switch (_selectedSpread) {
      case TarotSpread.single:
        return 1;
      case TarotSpread.pastPresentFuture:
        return 3;
      case TarotSpread.celticCross:
        return 10;
    }
  }
  
  void _shuffleCards() {
    setState(() {
      _selectedCardIndices.clear();
    });
    _shuffleController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }
  
  void _startReading() {
    ref.read(tarotFortuneProvider.notifier).getReading(
      selectedCards: _selectedCardIndices,
      spread: _selectedSpread,
    );
  }
  
  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }
}
```

---

## 🎨 커스텀 UI 컴포넌트 만들기

### 예제: 애니메이션 운세 점수 카드

운세 점수를 시각적으로 표현하는 커스텀 위젯을 만들어보겠습니다.

**파일**: `/fortune_flutter/lib/features/fortune/presentation/widgets/animated_score_card.dart`

```dart
class AnimatedScoreCard extends StatefulWidget {
  final int score;
  final String label;
  final Color? color;
  final IconData? icon;
  final Duration animationDuration;
  
  const AnimatedScoreCard({
    Key? key,
    required this.score,
    required this.label,
    this.color,
    this.icon,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);
  
  @override
  State<AnimatedScoreCard> createState() => _AnimatedScoreCardState();
}

class _AnimatedScoreCardState extends State<AnimatedScoreCard>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.3),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: oldWidget.score.toDouble(),
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? _getScoreColor(widget.score);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원
                CustomPaint(
                  size: Size(120, 120),
                  painter: CircularProgressPainter(
                    progress: _scoreAnimation.value / 100,
                    color: color,
                    strokeWidth: 12,
                  ),
                ),
                
                // 중앙 콘텐츠
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: color,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                    ],
                    Text(
                      '${_scoreAnimation.value.toInt()}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                // 파티클 효과 (높은 점수일 때)
                if (widget.score >= 80)
                  ...List.generate(5, (index) {
                    return AnimatedParticle(
                      delay: Duration(milliseconds: index * 200),
                      color: color,
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 원형 프로그레스 페인터
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  
  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;
    
    // 배경 원
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // 진행 원
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final progressAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );
  }
  
  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

// 파티클 애니메이션
class AnimatedParticle extends StatefulWidget {
  final Duration delay;
  final Color color;
  
  const AnimatedParticle({
    Key? key,
    required this.delay,
    required this.color,
  }) : super(key: key);
  
  @override
  State<AnimatedParticle> createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<AnimatedParticle>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;
  late double _angle;
  
  @override
  void initState() {
    super.initState();
    
    _angle = Random().nextDouble() * 2 * pi;
    
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _positionAnimation = Tween<double>(
      begin: 0,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.7, 1.0, curve: Curves.easeOut),
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final x = cos(_angle) * _positionAnimation.value;
        final y = sin(_angle) * _positionAnimation.value;
        
        return Positioned(
          left: 75 + x - 4,
          top: 75 + y - 4,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## ⚡ 성능 최적화 예제

### 예제: 운세 리스트 최적화

대량의 운세 목록을 효율적으로 표시하는 최적화된 리스트 구현입니다.

**파일**: `/fortune_flutter/lib/features/fortune/presentation/widgets/optimized_fortune_list.dart`

```dart
class OptimizedFortuneList extends StatefulWidget {
  final List<Fortune> fortunes;
  final Function(Fortune)? onTap;
  
  const OptimizedFortuneList({
    Key? key,
    required this.fortunes,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<OptimizedFortuneList> createState() => _OptimizedFortuneListState();
}

class _OptimizedFortuneListState extends State<OptimizedFortuneList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  late List<Fortune> _visibleFortunes;
  int _visibleItemCount = 20;
  
  @override
  void initState() {
    super.initState();
    _updateVisibleFortunes();
    _scrollController.addListener(_onScroll);
  }
  
  void _updateVisibleFortunes() {
    _visibleFortunes = widget.fortunes.take(_visibleItemCount).toList();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.8) {
      setState(() {
        _visibleItemCount = min(
          _visibleItemCount + 10,
          widget.fortunes.length,
        );
        _updateVisibleFortunes();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '총 ${widget.fortunes.length}개의 운세',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        
        // 리스트
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= _visibleFortunes.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final fortune = _visibleFortunes[index];
              _itemKeys[index] ??= GlobalKey();
              
              return OptimizedFortuneListItem(
                key: _itemKeys[index],
                fortune: fortune,
                index: index,
                onTap: () => widget.onTap?.call(fortune),
              );
            },
            childCount: _visibleItemCount + (_visibleItemCount < widget.fortunes.length ? 1 : 0),
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class OptimizedFortuneListItem extends StatefulWidget {
  final Fortune fortune;
  final int index;
  final VoidCallback? onTap;
  
  const OptimizedFortuneListItem({
    Key? key,
    required this.fortune,
    required this.index,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<OptimizedFortuneListItem> createState() => _OptimizedFortuneListItemState();
}

class _OptimizedFortuneListItemState extends State<OptimizedFortuneListItem>
    with AutomaticKeepAliveClientMixin {
  
  bool _isExpanded = false;
  
  @override
  bool get wantKeepAlive => _isExpanded;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          widget.onTap?.call();
        },
        child: AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    // 아이콘 (메모이제이션)
                    _FortuneIcon(
                      fortuneType: widget.fortune.type,
                    ),
                    SizedBox(width: 12),
                    
                    // 제목
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FortuneTypeNames.getName(widget.fortune.type),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy.MM.dd HH:mm').format(
                              widget.fortune.createdAt,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 점수
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(widget.fortune.score),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.fortune.score}점',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 8),
                    
                    // 확장 아이콘
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(Icons.expand_more),
                    ),
                  ],
                ),
                
                // 상세 내용 (확장 시에만 표시)
                if (_isExpanded) ...[
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  
                  // 내용 (지연 로딩)
                  FutureBuilder<String>(
                    future: _loadFortuneContent(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      return Text(
                        snapshot.data ?? '',
                        style: TextStyle(fontSize: 14),
                      );
                    },
                  ),
                  
                  SizedBox(height: 16),
                  
                  // 액션 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _shareForune(),
                        icon: Icon(Icons.share),
                        label: Text('공유'),
                      ),
                      SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _saveAsFavorite(),
                        icon: Icon(Icons.star_border),
                        label: Text('즐겨찾기'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<String> _loadFortuneContent() async {
    // 시뮬레이션: 실제로는 DB나 캐시에서 로드
    await Future.delayed(Duration(milliseconds: 500));
    return widget.fortune.content;
  }
  
  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
  
  void _shareForune() {
    // 공유 로직
  }
  
  void _saveAsFavorite() {
    // 즐겨찾기 로직
  }
}

// 메모이제이션된 아이콘 위젯
class _FortuneIcon extends StatelessWidget {
  final String fortuneType;
  
  const _FortuneIcon({
    Key? key,
    required this.fortuneType,
  }) : super(key: key);
  
  static final Map<String, IconData> _iconCache = {};
  
  @override
  Widget build(BuildContext context) {
    final icon = _iconCache.putIfAbsent(
      fortuneType,
      () => _getIconForType(fortuneType),
    );
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    final iconMap = {
      'daily': Icons.today,
      'love': Icons.favorite,
      'career': Icons.work,
      'wealth': Icons.attach_money,
      'health': Icons.health_and_safety,
      // ... 더 많은 매핑
    };
    
    return iconMap[type] ?? Icons.auto_awesome;
  }
}
```

---

## 🎯 정리

이 구현 예제들은 Fortune 앱에서 실제로 사용할 수 있는 패턴들을 보여줍니다:

1. **새로운 운세 타입 추가**: 전체 아키텍처를 따라 체계적으로 구현
2. **배치 패키지**: 여러 운세를 효율적으로 처리
3. **인터랙티브 기능**: 사용자 참여를 높이는 UI
4. **커스텀 컴포넌트**: 재사용 가능한 애니메이션 위젯
5. **성능 최적화**: 대량 데이터 처리 최적화

각 예제는 실제 프로덕션 환경에서 바로 사용할 수 있도록 
에러 처리, 로딩 상태, 애니메이션 등을 모두 포함하고 있습니다.

---

*Happy Coding! 🚀*