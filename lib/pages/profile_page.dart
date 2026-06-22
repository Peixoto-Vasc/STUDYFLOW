import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';  // ⭐ VERIFIQUE ESTA LINHA

class ProfilePage extends StatefulWidget {
  final List<String> subjects;
  final Function(String) onSubjectAdded;
  final Function(String) onSubjectRemoved;
  final User user;

  const ProfilePage({
    super.key,
    required this.subjects,
    required this.onSubjectAdded,
    required this.onSubjectRemoved,
    required this.user,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _subjectController = TextEditingController();
  final AuthService _authService = AuthService(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Perfil",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // ⭐ AVATAR
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 65,
                backgroundColor: Color(0xFF2563EB),
                child: Text(
                  "🎓",
                  style: TextStyle(fontSize: 70),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // ⭐ NOME DO USUÁRIO
            Text(
              widget.user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            
            // ⭐ EMAIL DO USUÁRIO
            Text(
              widget.user.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // ⭐ MATÉRIAS CADASTRADAS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Matérias Cadastradas",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.subjects.length,
                itemBuilder: (context, index) {
                  final subject = widget.subjects[index];
                  if (subject == "Todos") return const SizedBox.shrink();

                  return ListTile(
                    leading: const Icon(
                      Icons.book_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    title: Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Remover matéria?"),
                            content: Text(
                              "Deseja remover '$subject'?\n"
                              "As tarefas dessa matéria também serão excluídas.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onSubjectRemoved(subject);
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Matéria '$subject' removida com sucesso",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Remover",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // ⭐ ADICIONAR NOVA MATÉRIA
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Adicionar Nova Matéria",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      hintText: "Ex: Biologia, Geografia...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (_subjectController.text.trim().isNotEmpty) {
                      widget.onSubjectAdded(_subjectController.text.trim());
                      _subjectController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Matéria adicionada com sucesso!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Adicionar"),
                ),
              ],
            ),
            
            const SizedBox(height: 30),

            // ⭐ BOTÃO DE LOGOUT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  // Fazer logout
                  await _authService.logout();
                  
                  // Voltar para login
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Desconectado com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Sair da Conta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }
}