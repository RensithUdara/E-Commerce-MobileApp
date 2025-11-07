import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../widget/custom_dialog.dart';

class SignUpViewMVC extends StatefulWidget {
  const SignUpViewMVC({super.key});

  @override
  State<SignUpViewMVC> createState() => _SignUpViewMVCState();
}

class _SignUpViewMVCState extends State<SignUpViewMVC> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nicController = TextEditingController();

  bool isBuyer = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    displayNameController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    nicController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      _showCustomDialog(
        title: 'Error',
        message: 'Passwords do not match!',
        isError: true,
      );
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);

    final success = await authController.signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: isBuyer
          ? usernameController.text.trim()
          : displayNameController.text.trim(),
      phoneNumber: phoneNumberController.text.trim(),
      role: isBuyer ? UserRole.customer : UserRole.seller,
    );

    if (success) {
      if (isBuyer) {
        _showCustomDialog(
          title: 'Success',
          message: 'Account created successfully! You can now sign in.',
          onConfirm: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
        );
      } else {
        _showCustomDialog(
          title: 'Seller Account Created',
          message:
              'Your seller account has been created but is currently disabled. Please send your NIC photo and business registration to:\n\nWhatsApp: +94761155638\nEmail: gemhubmobile@gmail.com\n\nThe Admin will review and enable your account.',
          onConfirm: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
        );
      }
    } else {
      _showCustomDialog(
        title: 'Sign Up Failed',
        message: authController.errorMessage ??
            'Failed to create account. Please try again.',
        isError: true,
      );
      authController.clearError();
    }
  }

  void _showCustomDialog({
    required String title,
    required String message,
    VoidCallback? onConfirm,
    bool isError = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
          isError: isError,
        );
      },
    );
  }

  Widget _roleSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Buyer'),
            value: true,
            groupValue: isBuyer,
            onChanged: (value) => setState(() => isBuyer = value ?? true),
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: const Text('Seller'),
            value: false,
            groupValue: isBuyer,
            onChanged: (value) => setState(() => isBuyer = value ?? true),
          ),
        ),
      ],
    );
  }

  Widget _customTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword
            ? (label == 'Password'
                ? !isPasswordVisible
                : !isConfirmPasswordVisible)
            : false,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (label == 'Password'
                            ? isPasswordVisible
                            : isConfirmPasswordVisible)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() {
                    if (label == 'Password') {
                      isPasswordVisible = !isPasswordVisible;
                    } else {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    }
                  }),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.diamond,
                        size: 40,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Selector
                    _roleSelector(),

                    // Form Fields
                    if (!isBuyer)
                      _customTextField('Name', displayNameController),
                    if (!isBuyer)
                      _customTextField('Address', addressController),
                    if (!isBuyer) _customTextField('NIC Number', nicController),
                    _customTextField('Username', usernameController),
                    _customTextField('Email', emailController,
                        keyboardType: TextInputType.emailAddress),
                    _customTextField('Phone Number', phoneNumberController,
                        keyboardType: TextInputType.phone),
                    _customTextField('Password', passwordController,
                        isPassword: true),
                    _customTextField(
                        'Confirm Password', confirmPasswordController,
                        isPassword: true),

                    const SizedBox(height: 30),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed:
                          authController.isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
