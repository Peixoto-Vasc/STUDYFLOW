import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  InputDecoration customInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO CIRCULAR
                Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text("StudyFlow", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const Text("Organize seus estudos diariamente", style: TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 35),
                
                TextFormField(
                  controller: emailController,
                  decoration: customInput("E-mail", Icons.email_outlined),
                  validator: (value) => value == null || value.isEmpty ? "Informe o e-mail" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: customInput("Senha", Icons.lock_outline),
                  validator: (value) => value == null || value.length < 6 ? "Senha mínima de 6 caracteres" : null,
                ),
                const SizedBox(height: 28),
                
                // BOTÃO LARGO COM GRADIENTE
                InkWell(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home'); // Recomendo configurar rotas no main.dart
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: const Center(child: Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Não tem conta? Criar conta", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}