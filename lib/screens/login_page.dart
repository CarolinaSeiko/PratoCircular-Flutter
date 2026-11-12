import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/validators.dart';
import '../widgets/app_logo.dart';
import 'profile_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const LoginPage({
    super.key,
    required this.onSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      emailController.text,
      passwordController.text,
    );
    if (!mounted) return;
    if (success) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const AppLogo(size: 104),
                    const SizedBox(height: 18),
                    const Text(
                      'Entre no Prato Circular',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF123526),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Acesse sua conta com e-mail e senha.'),
                    const SizedBox(height: 24),
                    Card(
                      color: const Color(0xFFDDEBD8),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              validator: Validators.email,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              validator: Validators.password,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                              ),
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                auth.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: auth.loading ? null : login,
                                icon: const Icon(Icons.login),
                                label: Text(auth.loading ? 'Entrando...' : 'Entrar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          auth.clearError();
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(
                                firstRegistration: true,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          if (created == true) widget.onSuccess();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Cadastrar-se'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
