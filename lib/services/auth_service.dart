// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _sessionKey = 'session';

  // ⭐ USUÁRIO FIXO (hardcoded)
  final User _fixedUser = User(
    id: 999,
    name: 'Usuário Fixo',
    email: 'admin@studyflow.com',
    passwordHash: _hashPasswordStatic('123456'),
    createdAt: DateTime.now(),
  );

  // ⭐ MÉTODO ESTÁTICO PARA HASH (usado no usuário fixo)
  static String _hashPasswordStatic(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ⭐ LOG COM PRINT
  void _log(String message) {
    print('🔍 $message');
  }

  // ==================== USUÁRIOS ====================

  Future<List<User>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? usersJson = prefs.getString(_usersKey);
      
      _log('📦 Users JSON: $usersJson');
      
      List<User> users = [];
      
      if (usersJson != null) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        users = decoded.map((e) => User.fromJson(e)).toList();
      }
      
      // ⭐ ADICIONA O USUÁRIO FIXO NA LISTA (se não existir)
      final exists = users.any((u) => u.email == _fixedUser.email);
      if (!exists) {
        users.add(_fixedUser);
        await _saveUsers(users);
        _log('✅ Usuário fixo adicionado: ${_fixedUser.email}');
      }
      
      return users;
    } catch (e) {
      _log('❌ Erro ao buscar usuários: $e');
      // ⭐ EM CASO DE ERRO, RETORNA APENAS O USUÁRIO FIXO
      return [_fixedUser];
    }
  }

  Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = jsonEncode(users.map((u) => u.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
      _log('💾 Usuários salvos: $usersJson');
    } catch (e) {
      _log('❌ Erro ao salvar usuários: $e');
    }
  }

  // ==================== REGISTRO ====================

  Future<AuthResult> register(String name, String email, String password) async {
    try {
      _log('📝 Tentando registrar: $email');

      if (name.trim().isEmpty) {
        return AuthResult.error('Nome é obrigatório');
      }
      
      if (email.trim().isEmpty) {
        return AuthResult.error('E-mail é obrigatório');
      }
      
      if (!_isValidEmail(email)) {
        return AuthResult.error('E-mail inválido');
      }
      
      if (password.length < 6) {
        return AuthResult.error('Senha deve ter pelo menos 6 caracteres');
      }

      final users = await _getUsers();
      
      // ⭐ NÃO DEIXA CADASTRAR COM O EMAIL DO USUÁRIO FIXO
      if (email.toLowerCase() == _fixedUser.email.toLowerCase()) {
        return AuthResult.error('Este e-mail é reservado para administrador');
      }
      
      if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
        return AuthResult.error('Este e-mail já está cadastrado');
      }

      final newUser = User(
        id: users.isEmpty ? 1 : users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      _log('✅ Novo usuário criado: ${newUser.email}');

      users.add(newUser);
      await _saveUsers(users);

      return AuthResult.success(newUser);
    } catch (e) {
      _log('❌ Erro no registro: $e');
      return AuthResult.error('Erro ao criar conta');
    }
  }

  // ==================== LOGIN ====================

  Future<AuthResult> login(String email, String password) async {
    try {
      _log('🔐 Tentando login: $email');
      
      if (email.trim().isEmpty) {
        return AuthResult.error('E-mail é obrigatório');
      }
      
      if (password.trim().isEmpty) {
        return AuthResult.error('Senha é obrigatória');
      }

      final users = await _getUsers();
      
      _log('👥 Usuários no login: ${users.length}');
      for (var u in users) {
        _log('  - ${u.email}');
      }
      
      // ⭐ PRIMEIRO VERIFICA SE É O USUÁRIO FIXO
      if (email.trim().toLowerCase() == _fixedUser.email.toLowerCase()) {
        _log('🔑 Verificando usuário fixo...');
        final hashedPassword = _hashPassword(password);
        if (_fixedUser.passwordHash == hashedPassword) {
          _log('✅ Usuário fixo autenticado!');
          await _createSession(_fixedUser);
          return AuthResult.success(_fixedUser);
        } else {
          _log('❌ Senha do usuário fixo incorreta');
          return AuthResult.error('Senha incorreta');
        }
      }
      
      // ⭐ DEPOIS VERIFICA OS USUÁRIOS DO BANCO
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
        orElse: () => User(id: -1, name: '', email: '', passwordHash: ''),
      );

      if (user.id == -1) {
        _log('❌ Usuário não encontrado: $email');
        return AuthResult.error('Usuário não encontrado');
      }

      _log('✅ Usuário encontrado: ${user.email}');

      final hashedPassword = _hashPassword(password);
      
      if (user.passwordHash != hashedPassword) {
        _log('❌ Senha incorreta');
        return AuthResult.error('Senha incorreta');
      }

      _log('✅ Senha correta!');
      await _createSession(user);

      return AuthResult.success(user);
    } catch (e) {
      _log('❌ Erro no login: $e');
      return AuthResult.error('Erro ao fazer login');
    }
  }

  // ==================== SESSÃO ====================

  Future<void> _createSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
      _log('✅ Sessão criada para: ${user.email}');
    } catch (e) {
      _log('❌ Erro ao criar sessão: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson == null) return null;
      
      final Map<String, dynamic> decoded = jsonDecode(sessionJson);
      return User.fromJson(decoded);
    } catch (e) {
      _log('❌ Erro ao buscar sessão: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_sessionKey);
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      _log('👋 Logout realizado');
    } catch (e) {
      _log('❌ Erro ao fazer logout: $e');
    }
  }

  // ⭐ LIMPAR DADOS (para testes)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _log('🗑️ Todos os dados foram limpos!');
    } catch (e) {
      _log('❌ Erro ao limpar dados: $e');
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult._({this.success = false, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }
}