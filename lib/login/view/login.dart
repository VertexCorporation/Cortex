// lib/login/view/login.dart

import 'package:cortex/app.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../../shake.dart';

/// A "dumb" widget responsible only for displaying the login form UI.
///
/// This widget holds no business logic. It receives all its data and callbacks
/// from a parent "orchestrator" widget. Its responsibilities are:
///   1. To render the TextFormFields, Buttons, and other UI elements for logging in.
///   2. To manage purely local UI state, such as password visibility.
///   3. To report user actions (e.g., form submission) back to the parent.
///   4. To display loading states and error messages provided by the parent.
class LoginForm extends StatefulWidget {
  // --- Callbacks to the Orchestrator ---
  final Future<void> Function(String email, String password, bool rememberMe) onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onInputChanged;

  // --- State from the Orchestrator ---
  final bool isLoading;
  final String? emailError;
  final String? passwordError;

  // --- Animation Controllers from the Orchestrator ---
  final AnimationController emailShakeController;
  final AnimationController passwordShakeController;

  // --- Responsive UI Parameters ---
  final double deviceHeight;
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
    required this.deviceHeight,
    required this.fontScale,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  // --- Local UI State ---
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  // --- Form Data ---
  String _email = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  /// This lifecycle method is crucial for displaying server-side errors.
  /// When the parent widget rebuilds with a new error, this method detects
  /// the change and forces the form to re-validate, thus showing the error message.
  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.emailError != null && widget.emailError != oldWidget.emailError) {
      _formKey.currentState?.validate();
    }
    if (widget.passwordError != null && widget.passwordError != oldWidget.passwordError) {
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

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: widget.deviceHeight * 0.04),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              l10n.loginToYourAccount,
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
              l10n.loginSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10 * widget.fontScale,
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.04),

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
              maxLength: 42,
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
              maxLength: 64,
              validator: (value) {
                if (widget.passwordError != null) return widget.passwordError;
                if (value == null || value.length < 6) return l10n.invalidPassword;
                return null;
              },
              onSaved: (value) => _password = value!.trim(),
            ),
          ),

          // --- Remember Me & Forgot Password ---
          Padding(
            padding: EdgeInsets.only(top: widget.deviceHeight * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      checkColor: AppColors.primaryColor,
                      activeColor: AppColors.primaryColor.inverted,
                    ),
                    Text(l10n.rememberMe, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ],
                ),
                TextButton(
                  onPressed: widget.onForgotPassword,
                  child: Text(l10n.forgotPassword, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.deviceHeight * 0.03),

          // --- Submit Button ---
          AnimatedOpacity(
            opacity: widget.isLoading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor.inverted,
                  padding: EdgeInsets.symmetric(vertical: widget.deviceHeight * 0.02),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.isLoading ? null : _submitForm,
                child: Text(
                  l10n.logIn,
                  style: TextStyle(fontSize: 18, color: AppColors.primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}