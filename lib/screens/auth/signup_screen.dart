import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleSignup() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      
      final values = _formKey.currentState!.value;
      final email = values['email'] as String;
      final password = values['password'] as String;
      final name = values['name'] as String;
      
      try {
        final supabase = Supabase.instance.client;
        
        // 회원가입
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'name': name},
        );
        
        if (!mounted) return;
        
        if (response.user != null) {
          // 프로필 생성
          await supabase.from('user_profiles').insert({
            'id': response.user!.id,
            'name': name,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다!'),
              backgroundColor: AppColors.success,
            ),
          );
          
          context.go('/onboarding');
        }
      } on AuthException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: AppColors.error,
          ),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingAll24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '회원가입',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: AppSpacing.spacing2),
              Text(
                'Fortune과 함께 운명을 만나보세요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              SizedBox(height: AppSpacing.spacing8),
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: '이름',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: '이름을 입력해주세요',
                        ),
                        FormBuilderValidators.minLength(
                          2,
                          errorText: '이름은 2자 이상이어야 합니다',
                        ),
                      ]),
                    ),
                    SizedBox(height: AppSpacing.spacing4),
                    FormBuilderTextField(
                      name: 'email',
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: '이메일을 입력해주세요',
                        ),
                        FormBuilderValidators.email(
                          errorText: '올바른 이메일 형식이 아닙니다',
                        ),
                      ]),
                    ),
                    SizedBox(height: AppSpacing.spacing4),
                    FormBuilderTextField(
                      name: 'password',
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(
                          errorText: '비밀번호를 입력해주세요',
                        ),
                        FormBuilderValidators.minLength(
                          6,
                          errorText: '비밀번호는 6자 이상이어야 합니다',
                        ),
                      ]),
                    ),
                    SizedBox(height: AppSpacing.spacing4),
                    FormBuilderTextField(
                      name: 'confirmPassword',
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 다시 입력해주세요';
                        }
                        if (value != _formKey.currentState?.fields['password']?.value) {
                          return '비밀번호가 일치하지 않습니다';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.spacing6),
                    SizedBox(
                      height: AppDimensions.buttonHeightMedium,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textPrimaryDark,
                                  ),
                                ),
                              )
                            : const Text('회원가입'),
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacing4),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: const Text('이미 계정이 있으신가요? 처음으로'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}