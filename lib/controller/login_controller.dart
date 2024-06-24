// lib/controller/login_controller.dart

// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário
import '../components/util.dart';

class LoginController {
  //
  // CRIAR CONTA
  //
  criarConta(BuildContext context, String nome, String email, String senha) async {
    try {
      UserCredential resultado = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      User? user = resultado.user;
      if (user != null) {
        // Atualiza o displayName no Firebase Auth
        await user.updateDisplayName(nome);

        // Adiciona o usuário ao Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nome': nome,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(), // Adiciona a data de criação
          'isAdmin': false, // Define 'isAdmin' como false por padrão
        });

        sucesso(context, 'Usuário criado com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMsg = 'Ocorreu um erro desconhecido.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = 'O e-mail já está em uso. Tente outro e-mail.';
            break;
          case 'invalid-email':
            errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
            break;
          case 'weak-password':
            errorMsg = 'A senha é muito fraca. Escolha uma senha mais forte.';
            break;
          case 'operation-not-allowed':
            errorMsg = 'Operação não permitida. Contate o suporte.';
            break;
          default:
            errorMsg = 'ERRO: ${e.code.toString()}';
        }
      }
      erro(context, errorMsg);
      if (kDebugMode) {
        print('Erro ao criar conta: ${e.toString()}');
      }
    }
  }

  //
  // LOGIN
  //
  login(BuildContext context, String email, String senha) async {
    try {
      UserCredential resultado = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);
      sucesso(context, 'Usuário autenticado com sucesso!');
      User? user = resultado.user;

      if (user != null) {
        bool isAdmin = await checkIfAdmin(user);

        if (isAdmin) {
          Navigator.pushNamed(context, 'principal_admin');
        } else {
          Navigator.pushNamed(context, 'principal');
        }
      }
    } catch (e) {
      String errorMsg = 'Ocorreu um erro desconhecido.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMsg = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
            break;
          case 'wrong-password':
            errorMsg = 'Senha incorreta. Tente novamente.';
            break;
          case 'invalid-email':
            errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
            break;
          default:
            errorMsg = 'ERRO: ${e.code.toString()}';
        }
      }
      erro(context, errorMsg);
      if (kDebugMode) {
        print('Erro ao fazer login: ${e.toString()}');
      }
    }
  }

  //
  // ESQUECEU A SENHA
  //
  esqueceuSenha(BuildContext context, String email) async {
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        sucesso(context, 'E-mail de recuperação enviado com sucesso!');
      } catch (e) {
        String errorMsg = 'Não foi possível enviar o e-mail.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'invalid-email':
              errorMsg = 'O formato do e-mail é inválido. Verifique e tente novamente.';
              break;
            case 'user-not-found':
              errorMsg = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
              break;
            default:
              errorMsg = 'ERRO: ${e.code.toString()}';
          }
        }
        erro(context, errorMsg);
        if (kDebugMode) {
          print('Erro ao enviar e-mail de recuperação: ${e.toString()}');
        }
      }
    } else {
      erro(context, 'Por favor, insira um e-mail.');
    }
  }

  //
  // LOGOUT
  //
  logout() {
    FirebaseAuth.instance.signOut();
  }

  //
  // ID do Usuário Logado
  //
  String idUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : 'Usuário não logado';
  }

  //
  // Verificar se o usuário é administrador
  //
  Future<bool> checkIfAdmin(User user) async {
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return adminSnapshot.data()?['isAdmin'] ?? false;
  }
}
