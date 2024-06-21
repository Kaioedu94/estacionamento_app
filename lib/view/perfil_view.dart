// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final _formKey = GlobalKey<FormState>();
  final txtNome = TextEditingController();
  final txtEmail = TextEditingController();
  final txtPagamento = TextEditingController();

  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carregar dados do usuário
  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      setState(() {
        _userData = userDoc.data() as Map<String, dynamic>?;
        txtNome.text = _userData?['nome'] ?? '';
        txtEmail.text = _userData?['email'] ?? '';
        txtPagamento.text = _userData?['pagamento'] ?? '';
      });
    }
  }

  // Salvar alterações
  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      if (_currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
          'nome': txtNome.text,
          'email': txtEmail.text,
          'pagamento': txtPagamento.text,
        });
        // Atualizar email e nome no Firebase Auth
        await _currentUser!.verifyBeforeUpdateEmail(txtEmail.text);
        await _currentUser!.updateDisplayName(txtNome.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Informações atualizadas com sucesso!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações Pessoais'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: txtNome,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: txtEmail,
                decoration: InputDecoration(labelText: 'E-mail'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: txtPagamento,
                decoration: InputDecoration(labelText: 'Informações de Pagamento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira suas informações de pagamento';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
