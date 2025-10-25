// lib/login/view/register.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../shake.dart';

/// A "dumb" widget responsible only for displaying the registration form UI.
///
/// This widget holds no business logic. It receives all its data and callbacks
/// from a parent "orchestrator" widget. Its responsibilities are:
///   1. To render the TextFormFields and Buttons for creating an account.
///   2. To manage purely local UI state, such as password visibility.
///   3. To report user actions (e.g., form submission) back to the parent.
///   4. To display loading states and error messages provided by the parent.
class RegisterForm extends StatefulWidget {
  // --- Callbacks to the Orchestrator ---
  final Future<void> Function(String username, String email, String password) onSubmit;
  final VoidCallback onInputChanged;

  // --- State from the Orchestrator ---
  final bool isLoading;
  final bool agreeToTerms; // The state of the checkbox is controlled by the parent.
  final String? usernameError;
  final String? emailError;
  final String? passwordError;

  // --- Animation Controllers from the Orchestrator ---
  final AnimationController usernameShakeController;
  final AnimationController emailShakeController;
  final AnimationController passwordShakeController;
  final AnimationController confirmPasswordShakeController;

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
    required this.confirmPasswordShakeController,
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
  late final TextEditingController _confirmPasswordController;

  // --- Local UI State ---
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
    _confirmPasswordController = TextEditingController();
  }

  /// This lifecycle method is crucial for displaying server-side errors.
  /// When the parent widget rebuilds with a new error, this method detects
  /// the change and forces the form to re-validate, thus showing the error message.
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
    _confirmPasswordController.dispose();
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: widget.deviceHeight * 0.04),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.createYourAccount,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42 * widget.fontScale,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: widget.deviceHeight * 0.001),
            child: Text(
              l10n.registerSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10 * widget.fontScale,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.04),

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
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).iconTheme.color),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (widget.passwordError != null) return widget.passwordError;
                if (value == null || value.length < 6) return l10n.weakPassword;
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.02),

          // --- Confirm Password Field ---
          ShakeWidget(
            controller: widget.confirmPasswordShakeController,
            child: TextFormField(
              controller: _confirmPasswordController,
              onChanged: (_) => widget.onInputChanged(),
              cursorColor: AppColors.primaryColor.inverted,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryColor,
                labelText: l10n.confirmPassword,
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).iconTheme.color),
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Theme.of(context).iconTheme.color),
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                counterText: '',
                errorMaxLines: 3,
              ),
              obscureText: !_isConfirmPasswordVisible,
              validator: (value) {
                if (value?.trim() != _passwordController.text.trim()) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.03),

          // --- Submit Button ---
          AnimatedOpacity(
            opacity: widget.isLoading || !widget.agreeToTerms ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.inverted,
                  padding: EdgeInsets.symmetric(vertical: widget.deviceHeight * 0.02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (widget.isLoading || !widget.agreeToTerms) ? null : _submitForm,
                child: Text(l10n.signUp, style: TextStyle(fontSize: 18, color: AppColors.primaryColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}