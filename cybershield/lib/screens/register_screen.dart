import 'package:cybershield/core/theme/app_colors.dart';
import 'package:cybershield/core/theme/app_typography.dart';
import 'package:cybershield/core/utils/validators.dart';
import 'package:cybershield/providers/auth_provider.dart';
import 'package:cybershield/widgets/tactile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _residenceController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedGender = 'male';
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _residenceController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ الميلاد')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).register({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'gender': _selectedGender,
      'date_of_birth': _selectedDateOfBirth!.toIso8601String().split('T').first,
      'residence': _residenceController.text.trim(),
      'password': _passwordController.text,
    });
    if (!mounted) return;
    setState(() => _isLoading = false);
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (authState.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.error!)));
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceContainer,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateOfBirth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundBlobs(),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    border: Border(
                      bottom: BorderSide(color: AppColors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/auth'),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CyberShield',
                        style: AppTypography.headlineLg.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                bottom: BorderSide(
                                  color: AppColors.onPrimary,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add,
                              color: AppColors.primary,
                              size: 32,
                              fill: 1.0,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 24),
                          Text(
                            'إنشاء حساب جديد',
                            style: AppTypography.headlineXl.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                          const SizedBox(height: 8),
                          Text(
                            'انضم إلى CyberShield لحماية عالمك الرقمي',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(
                                top: BorderSide(
                                  color: AppColors.outlineVariant,
                                ),
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _LabeledField(
                                          label: 'الاسم الأول',
                                          child: TextFormField(
                                            controller: _firstNameController,
                                            validator: (v) =>
                                                Validators.required(
                                                  v,
                                                  'الاسم الأول',
                                                ),
                                            style: AppTypography.bodyMd
                                                .copyWith(
                                                  color: AppColors.onSurface,
                                                ),
                                            decoration: const InputDecoration(
                                              hintText: 'أحمد',
                                              prefixIcon: Icon(
                                                Icons.person,
                                                color: AppColors.outline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _LabeledField(
                                          label: 'الاسم الأخير',
                                          child: TextFormField(
                                            controller: _lastNameController,
                                            validator: (v) =>
                                                Validators.required(
                                                  v,
                                                  'الاسم الأخير',
                                                ),
                                            style: AppTypography.bodyMd
                                                .copyWith(
                                                  color: AppColors.onSurface,
                                                ),
                                            decoration: const InputDecoration(
                                              hintText: 'محمد',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'اسم المستخدم',
                                    child: TextFormField(
                                      controller: _usernameController,
                                      validator: (v) => Validators.required(
                                        v,
                                        'اسم المستخدم',
                                      ),
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'ahmed_m',
                                        prefixIcon: Icon(
                                          Icons.alternate_email,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'البريد الإلكتروني',
                                    child: TextFormField(
                                      controller: _emailController,
                                      validator: Validators.email,
                                      keyboardType: TextInputType.emailAddress,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'name@company.com',
                                        prefixIcon: Icon(
                                          Icons.mail,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'رقم الهاتف',
                                    child: TextFormField(
                                      controller: _phoneController,
                                      validator: (v) =>
                                          Validators.required(v, 'رقم الهاتف'),
                                      keyboardType: TextInputType.phone,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: '+966 5XX XXX XXXX',
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'الجنس',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () => _selectedGender = 'male',
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _selectedGender == 'male'
                                                    ? AppColors.primaryContainer
                                                    : AppColors
                                                          .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      _selectedGender == 'male'
                                                      ? AppColors.primary
                                                      : AppColors
                                                            .outlineVariant,
                                                ),
                                              ),
                                              child: Text(
                                                'ذكر',
                                                textAlign: TextAlign.center,
                                                style: AppTypography.labelMd
                                                    .copyWith(
                                                      color:
                                                          _selectedGender ==
                                                              'male'
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () => _selectedGender = 'female',
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    _selectedGender == 'female'
                                                    ? AppColors.primaryContainer
                                                    : AppColors
                                                          .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      _selectedGender ==
                                                          'female'
                                                      ? AppColors.primary
                                                      : AppColors
                                                            .outlineVariant,
                                                ),
                                              ),
                                              child: Text(
                                                'أنثى',
                                                textAlign: TextAlign.center,
                                                style: AppTypography.labelMd
                                                    .copyWith(
                                                      color:
                                                          _selectedGender ==
                                                              'female'
                                                          ? AppColors.primary
                                                          : AppColors
                                                                .onSurfaceVariant,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'تاريخ الميلاد',
                                    child: GestureDetector(
                                      onTap: _pickDateOfBirth,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.outlineVariant,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: AppColors.outline,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _selectedDateOfBirth != null
                                                  ? '${_selectedDateOfBirth!.year}-${_selectedDateOfBirth!.month.toString().padLeft(2, '0')}-${_selectedDateOfBirth!.day.toString().padLeft(2, '0')}'
                                                  : 'اختر تاريخ الميلاد',
                                              style: AppTypography.bodyMd
                                                  .copyWith(
                                                    color:
                                                        _selectedDateOfBirth !=
                                                            null
                                                        ? AppColors.onSurface
                                                        : AppColors.outline,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'مكان الإقامة',
                                    child: TextFormField(
                                      controller: _residenceController,
                                      validator: (v) => Validators.required(
                                        v,
                                        'مكان الإقامة',
                                      ),
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'الرياض، السعودية',
                                        prefixIcon: Icon(
                                          Icons.location_on,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'كلمة المرور',
                                    child: TextFormField(
                                      controller: _passwordController,
                                      validator: Validators.password,
                                      obscureText: _obscurePassword,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: AppColors.outline,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          child: Icon(
                                            _obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _LabeledField(
                                    label: 'تأكيد كلمة المرور',
                                    child: TextFormField(
                                      controller: _confirmPasswordController,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'تأكيد كلمة المرور مطلوب';
                                        }
                                        if (v != _passwordController.text) {
                                          return 'كلمتا المرور غير متطابقتين';
                                        }
                                        return null;
                                      },
                                      obscureText: _obscureConfirmPassword,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '••••••••',
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: AppColors.outline,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () => setState(
                                            () => _obscureConfirmPassword =
                                                !_obscureConfirmPassword,
                                          ),
                                          child: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TactileButton(
                                    label: 'إنشاء حساب',
                                    onPressed: _isLoading
                                        ? () {}
                                        : _handleRegister,
                                    icon: Icons.person_add,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => context.go('/auth'),
                            child: Text.rich(
                              TextSpan(
                                text: 'لديك حساب بالفعل؟ ',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'تسجيل الدخول',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0x4D4C4451))),
                  ),
                  child: Text(
                    'بإنشاء حساب، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا\n© 2024 CYBERSHIELD TECHNOLOGY CO.',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.outline,
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
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
            ),
          ).animate().fadeIn(duration: 1200.ms),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryContainer.withValues(alpha: 0.1),
            ),
          ).animate().fadeIn(duration: 1200.ms, delay: 300.ms),
        ),
      ],
    );
  }
}
