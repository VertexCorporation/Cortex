// lib/login/view/register.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../shake.dart';

/// A "dumb" widget responsible only for displaying the registration form UI.
class RegisterForm extends StatefulWidget {
  // --- Callbacks to the Orchestrator ---
  final Future<void> Function(String username, String email, String password) onSubmit;
  final VoidCallback onInputChanged;

  // --- State from the Orchestrator ---
  final bool isLoading;
  final bool agreeToTerms;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;

  // --- Animation Controllers from the Orchestrator ---
  final AnimationController usernameShakeController;
  final AnimationController emailShakeController;
  final AnimationController passwordShakeController;

  // --- Responsive UI Parameters ---
  final double deviceHeight;
  final double fontScale;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    required this.onInputChanged,
    required this.isLoading,
    required this.agreeToTerms,
    this.usernameError,
    this.emailError,
    this.passwordError,
    required this.usernameShakeController,
    required this.emailShakeController,
    required this.passwordShakeController,
    required this.deviceHeight,
    required this.fontScale,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // --- Local UI State ---
  bool _isPasswordVisible = false;

  // --- Form Data ---
  String _username = '';
  String _email = '';
  String _password = '';

  final RegExp _usernameRegExp = RegExp(r'^[a-z0-9çğıöşü._-]{3,20}$', caseSensitive: false);

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didUpdateWidget(RegisterForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.usernameError != null && widget.usernameError != oldWidget.usernameError) {
      _formKey.currentState?.validate();
    }
    if (widget.emailError != null && widget.emailError != oldWidget.emailError) {
      _formKey.currentState?.validate();
    }
    if (widget.passwordError != null && widget.passwordError != oldWidget.passwordError) {
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formKey.currentState?.save();
    widget.onSubmit(_username, _email, _password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final bool isDisabled = widget.isLoading || !widget.agreeToTerms;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Spacing matched to Login
          SizedBox(height: widget.deviceHeight * 0.03),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.createYourAccount,
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
            padding: EdgeInsets.only(top: widget.deviceHeight * 0.005),
            child: Text(
              l10n.registerSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12 * widget.fontScale,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.02),

          // --- Username Field ---
          ShakeWidget(
            controller: widget.usernameShakeController,
            child: TextFormField(
              controller: _usernameController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.username,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
                contentPadding: EdgeInsets.symmetric(vertical: 14 * widget.fontScale, horizontal: 12),
              ),
              maxLength: 20,
              validator: (value) {
                if (widget.usernameError != null) return widget.usernameError;
                if (value == null || value.trim().length < 3) return l10n.usernameTooShort;
                if (value.trim().length > 20) return l10n.usernameTooLong;
                if (!_usernameRegExp.hasMatch(value.trim())) return l10n.invalidUsernameCharacters;
                return null;
              },
              onSaved: (value) => _username = value!.trim().toLowerCase(),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.02),

          // --- Email Field ---
          ShakeWidget(
            controller: widget.emailShakeController,
            child: TextFormField(
              controller: _emailController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.email,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.email, color: Theme.of(context).iconTheme.color),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
                contentPadding: EdgeInsets.symmetric(vertical: 14 * widget.fontScale, horizontal: 12),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (widget.emailError != null) return widget.emailError;
                if (value == null || !EmailValidator.validate(value.trim())) return l10n.invalidEmail;
                return null;
              },
              onSaved: (value) => _email = value!.trim(),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.02),

          // --- Password Field ---
          ShakeWidget(
            controller: widget.passwordShakeController,
            child: TextFormField(
              controller: _passwordController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.password,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),

                suffixIcon: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      key: ValueKey(_isPasswordVisible ? 'icon1' : 'icon2'),
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),

                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
                contentPadding: EdgeInsets.symmetric(vertical: 14 * widget.fontScale, horizontal: 12),
              ),
              obscureText: !_isPasswordVisible,
              maxLength: 64,
              validator: (value) {
                if (widget.passwordError != null) return widget.passwordError;
                if (value == null || value.length < 6) return l10n.invalidPassword;
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.02),

          // --- Submit Button ---
          AnimatedOpacity(
            opacity: isDisabled ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isDisabled,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.primaryColor.inverted,

                    disabledBackgroundColor: AppColors.background,
                    disabledForegroundColor: AppColors.primaryColor.inverted,

                    padding: EdgeInsets.symmetric(vertical: widget.deviceHeight * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    side: BorderSide(color: AppColors.quinaryColor.withValues(alpha:0.3)),
                  ),

                  onPressed: _submitForm,
                  child: Text(
                      l10n.signUp,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}