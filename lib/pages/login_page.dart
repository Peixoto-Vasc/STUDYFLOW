// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  // ⭐ USUÁRIO FIXO PARA TESTE (hardcoded)
  final String _fixedEmail = 'admin@studyflow.com';
  final String _fixedPassword = '123456';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // ⭐ VERIFICA PRIMEIRO O USUÁRIO FIXO
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email == _fixedEmail && password == _fixedPassword) {
        // ⭐ LOGIN COM USUÁRIO FIXO
        final fixedUser = User(
          id: 999,
          name: 'Administrador',
          email: _fixedEmail,
          passwordHash: '',
          createdAt: DateTime.now(),
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/home',
            arguments: fixedUser,
          );
        }
        return;
      }

      // ⭐ SE NÃO FOR O USUÁRIO FIXO, TENTA LOGIN NORMAL
      final result = await _authService.login(email, password);

      if (!mounted) return;

      if (result.success && result.user != null) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: result.user,
        );
      } else {
        _showError(result.error ?? 'Erro ao fazer login');
      }
    } catch (e) {
      _showError('Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ⭐ LOGO
                  Container(
                    height: 85,
                    width: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    "StudyFlow",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Organize seus estudos diariamente",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 40),

                  // ⭐ INFORMAÇÕES DO USUÁRIO FIXO (apenas para teste)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Usuário fixo: admin@studyflow.com / 123456',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⭐ CAMPO EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF2563EB),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe seu e-mail';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'E-mail inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ⭐ CAMPO SENHA
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF2563EB),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe sua senha';
                      }
                      if (value.length < 6) {
                        return 'Mínimo de 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // ⭐ ESQUECEU SENHA
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showError('Entre em contato com o suporte');
                      },
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⭐ BOTÃO ENTRAR
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _login,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Entrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ⭐ CRIAR CONTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Não tem uma conta?",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Criar conta",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}