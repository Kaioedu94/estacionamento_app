// lib/view/principal_view.dart

// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/login_controller.dart';
import '../controller/reserva_controller.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  String? tipoFiltro;
  String? fileiraFiltro;

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
        title: Text('Gerenciamento de Estacionamento'),
        actions: [
          DropdownButton<String>(
            hint: Text('Tipo'),
            value: tipoFiltro,
            items: ['Todos', 'coberta', 'descoberta']
                .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                .toList(),
            onChanged: (valor) {
              setState(() {
                tipoFiltro = valor == 'Todos' ? null : valor;
              });
            },
          ),
          DropdownButton<String>(
            hint: Text('Fileira'),
            value: fileiraFiltro,
            items: ['Todos', 'A', 'B', 'C', 'D']
                .map((fileira) => DropdownMenuItem(value: fileira, child: Text(fileira)))
                .toList(),
            onChanged: (valor) {
              setState(() {
                fileiraFiltro = valor == 'Todos' ? null : valor;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _userData?['nome'] ?? 'Usuário',
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                _userData?['email'] ?? 'email@exemplo.com',
                style: TextStyle(color: Colors.white),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _userData?['nome']?.substring(0, 1) ?? 'U',
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
              leading: Icon(Icons.history),
              title: Text('Histórico de Reservas'),
              onTap: () {
                Navigator.pushNamed(context, 'historico').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Histórico de Reservas: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.car_repair),
              title: Text('Entrada e Saída'),
              onTap: () {
                Navigator.pushNamed(context, 'entradaSaida').then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (kDebugMode) {
                    print('Erro ao navegar para Entrada e Saída: $error');
                  }
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context); // Pode ser removido se não houver ação definida
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
          stream: _construirConsulta().snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                  child: Text("Falha na conexão."),
                );
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao carregar dados: ${snapshot.error}"),
                  );
                }
                final dados = snapshot.requireData;
                if (dados.size > 0) {
                  return ListView.builder(
                    itemCount: dados.size,
                    itemBuilder: (context, index) {
                      String id = dados.docs[index].id;
                      Map<String, dynamic> vaga = dados.docs[index].data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text('Vaga ${vaga['numero']} ${vaga['fileira']}'),
                          subtitle: Text('${vaga['disponivel'] ? 'Disponível' : 'Ocupada'} - ${vaga['tipo']}'),
                          trailing: vaga['disponivel']
                              ? ElevatedButton(
                                  onPressed: () async {
                                    await ReservaController().adicionarReserva(context, id);
                                    setState(() {}); // Força a reconstrução da tela após a reserva
                                  },
                                  child: Text('Reservar'),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text("Nenhuma vaga disponível."),
                  );
                }
            }
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

  Query _construirConsulta() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('vagas');
    if (tipoFiltro != null) {
      query = query.where('tipo', isEqualTo: tipoFiltro);
    }
    if (fileiraFiltro != null) {
      query = query.where('fileira', isEqualTo: fileiraFiltro);
    }
    return query;
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
}
