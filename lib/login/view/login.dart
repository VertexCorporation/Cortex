// lib/login/view/login.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shake.dart';

class LoginForm extends StatefulWidget {
  final Future<void> Function(String email, String password, bool rememberMe)
      onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onInputChanged;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final AnimationController emailShakeController;
  final AnimationController passwordShakeController;
  final double fontScale;
  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onInputChanged,
    required this.isLoading,
    this.emailError,
    this.passwordError,
    required this.emailShakeController,
    required this.passwordShakeController,
    required this.fontScale,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emailError != null &&
        widget.emailError != oldWidget.emailError) {
      _formKey.currentState?.validate();
    }
    if (widget.passwordError != null &&
        widget.passwordError != oldWidget.passwordError) {
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.save();
    widget.onSubmit(_email, _password, _rememberMe);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double spacer = 16 * widget.fontScale;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: spacer),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.loginToYourAccount,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38 * widget.fontScale,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4 * widget.fontScale),
            child: Text(
              l10n.loginSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10 * widget.fontScale,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.2,
              ),
            ),
          ),

          SizedBox(height: spacer),

          // --- Email Field ---
          ShakeWidget(
            controller: widget.emailShakeController,
            child: TextFormField(
              controller: _emailController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14 * widget.fontScale),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.email,
                labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14 * widget.fontScale),
                prefixIcon: Icon(Icons.email,
                    color: Theme.of(context).iconTheme.color,
                    size: 24 * widget.fontScale),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * widget.fontScale),
                    borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
                errorStyle: TextStyle(fontSize: 12 * widget.fontScale),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 14 * widget.fontScale,
                    horizontal: 12 * widget.fontScale),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 42,
              validator: (value) {
                if (widget.emailError != null) return widget.emailError;
                if (value == null || !EmailValidator.validate(value.trim())) {
                  return l10n.invalidEmail;
                }
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
          ),

          SizedBox(height: spacer),

          // --- Password Field ---
          ShakeWidget(
            controller: widget.passwordShakeController,
            child: TextFormField(
              controller: _passwordController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 14 * widget.fontScale),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.password,
                labelStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14 * widget.fontScale),
                prefixIcon: Icon(Icons.lock_outline,
                    color: Theme.of(context).iconTheme.color,
                    size: 24 * widget.fontScale),
                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      key: ValueKey(_isPasswordVisible ? 'icon1' : 'icon2'),
                      color: Theme.of(context).iconTheme.color,
                      size: 24 * widget.fontScale,
                    ),
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10 * widget.fontScale),
                    borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
                errorStyle: TextStyle(fontSize: 12 * widget.fontScale),
                contentPadding: EdgeInsets.symmetric(
                    vertical: 14 * widget.fontScale,
                    horizontal: 12 * widget.fontScale),
              ),
              obscureText: !_isPasswordVisible,
              maxLength: 64,
              validator: (value) {
                if (widget.passwordError != null) return widget.passwordError;
                if (value == null || value.length < 6) {
                  return l10n.invalidPassword;
                }
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),

          // --- Remember Me & Forgot Password ---
          SizedBox(
            height: 60 * widget.fontScale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24 * widget.fontScale,
                      width: 24 * widget.fontScale,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) =>
                            setState(() => _rememberMe = value ?? false),
                        checkColor: AppColors.primaryColor,
                        activeColor: AppColors.primaryColor.inverted,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    SizedBox(width: 8 * widget.fontScale),
                    Text(l10n.rememberMe,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14 * widget.fontScale)),
                  ],
                ),
                TextButton(
                  onPressed: widget.onForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.forgotPassword,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * widget.fontScale,
                      )),
                ),
              ],
            ),
          ),

          SizedBox(height: spacer * 0.5),

          // --- Submit Button ---
          AnimatedOpacity(
            opacity: widget.isLoading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.primaryColor.inverted,
                  padding:
                      EdgeInsets.symmetric(vertical: 14 * widget.fontScale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * widget.fontScale),
                  ),
                  elevation: 0,
                  side: BorderSide(
                      color: AppColors.quinaryColor.withValues(alpha: 0.3)),
                ),
                onPressed: widget.isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _submitForm();
                      },
                child: Text(
                  l10n.logIn,
                  style: TextStyle(
                      fontSize: 16 * widget.fontScale,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
