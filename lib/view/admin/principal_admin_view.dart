// principal_admin_view.dart

// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/login_controller.dart';


class PrincipalAdminView extends StatefulWidget {
  const PrincipalAdminView({super.key});

  @override
  State<PrincipalAdminView> createState() => _PrincipalAdminViewState();
}

class _PrincipalAdminViewState extends State<PrincipalAdminView> {
  User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (mounted) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Estacionamento - Admin'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _userData?['nome'] ?? 'Administrador',
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                _currentUser?.email ?? 'email@exemplo.com',
                style: TextStyle(color: Colors.white),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userData?['nome']?.substring(0, 1) ?? 'A',
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Informações Pessoais'),
              onTap: () {
                Navigator.pushNamed(context, 'perfil').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Informações Pessoais: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.monitor),
              title: Text('Monitoramento'),
              onTap: () {
                Navigator.pushNamed(context, 'monitoramento').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Monitoramento: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Gerenciamento de Usuários'),
              onTap: () {
                Navigator.pushNamed(context, 'usersView').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Gerenciamento de Usuários: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online),
              title: Text('Gerenciamento de Reservas'),
              onTap: () {
                Navigator.pushNamed(context, 'reservasView').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Gerenciamento de Reservas: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () {
                LoginController().logout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('vagas').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar vagas.'));
            }

            final vagas = snapshot.data?.docs ?? [];

            return ListView.builder(
              itemCount: vagas.length,
              itemBuilder: (context, index) {
                final vaga = vagas[index];
                final vagaData = vaga.data() as Map<String, dynamic>;

                return Card(
                  child: ListTile(
                    title: Text('Vaga ${vagaData['numero']} ${vagaData['fileira']}'),
                    subtitle: Text(vagaData['disponivel'] ? 'Disponível' : 'Ocupada'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _editarVaga(context, vaga.id, vagaData);
                          },
                          child: Text('Editar'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('vagas').doc(vaga.id).delete();
                            setState(() {});
                          },
                          child: Text('Remover'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          adicionarVaga(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void adicionarVaga(BuildContext context) {
    final txtNumero = TextEditingController();
    String? tipoSelecionado;
    String? fileiraSelecionada;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adicionar Vaga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: txtNumero,
                decoration: InputDecoration(
                  labelText: 'Número',
                ),
              ),
              DropdownButton<String>(
                hint: Text('Tipo'),
                value: tipoSelecionado,
                items: ['coberta', 'descoberta']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    tipoSelecionado = valor;
                  });
                },
              ),
              DropdownButton<String>(
                hint: Text('Fileira'),
                value: fileiraSelecionada,
                items: ['A', 'B', 'C', 'D']
                    .map((fileira) => DropdownMenuItem(value: fileira, child: Text(fileira)))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    fileiraSelecionada = valor;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () {
                if (txtNumero.text.isEmpty || tipoSelecionado == null || fileiraSelecionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
                  return;
                }
                FirebaseFirestore.instance.collection('vagas').add({
                  'numero': txtNumero.text,
                  'disponivel': true,
                  'tipo': tipoSelecionado,
                  'fileira': fileiraSelecionada,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editarVaga(BuildContext context, String vagaId, Map<String, dynamic> vagaData) {
    final txtNumero = TextEditingController(text: vagaData['numero']);
    String? tipoSelecionado = vagaData['tipo'];
    String? fileiraSelecionada = vagaData['fileira'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar Vaga"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: txtNumero,
                decoration: InputDecoration(
                  labelText: 'Número',
                ),
              ),
              DropdownButton<String>(
                hint: Text('Tipo'),
                value: tipoSelecionado,
                items: ['coberta', 'descoberta']
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    tipoSelecionado = valor;
                  });
                },
              ),
              DropdownButton<String>(
                hint: Text('Fileira'),
                value: fileiraSelecionada,
                items: ['A', 'B', 'C', 'D']
                    .map((fileira) => DropdownMenuItem(value: fileira, child: Text(fileira)))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    fileiraSelecionada = valor;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () {
                if (txtNumero.text.isEmpty || tipoSelecionado == null || fileiraSelecionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha todos os campos')));
                  return;
                }
                FirebaseFirestore.instance.collection('vagas').doc(vagaId).update({
                  'numero': txtNumero.text,
                  'tipo': tipoSelecionado,
                  'fileira': fileiraSelecionada,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
