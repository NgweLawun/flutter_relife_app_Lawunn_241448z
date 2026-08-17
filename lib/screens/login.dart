import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/login_controller.dart';
import '../model/userdata.dart';


class LoginPage extends StatelessWidget {
  final VoidCallback onCreateAccount;

  const LoginPage({super.key, required this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    return  ChangeNotifierProvider(

      create: (context) => LoginController(),
      child: _LoginView(onCreateAccount: onCreateAccount),
    );
  }
}

class _LoginView extends StatelessWidget {
  final VoidCallback onCreateAccount;

  const _LoginView({required this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 14),
              Text(
                'ReLife',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                     color: Color.fromARGB(255, 0, 65, 15),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a new account',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Consumer<LoginController>(
                  builder: (context, controller, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.emailController, 
                          decoration: const InputDecoration(
                            hintText: 'example@gmail.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: controller.pwdController, 
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (controller.hasError) 
                          Text(
                            controller.errorText, 
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                        onPressed: controller.isLoading
        ? null
        : () async {
            final userData = context.read<UserData>();
     
            await controller.handlelogin(userData);
          },
    child: controller.isLoading // NEW
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
  ),)
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an Account? '),
                  TextButton(
                    onPressed: onCreateAccount,
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 114, 42),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}