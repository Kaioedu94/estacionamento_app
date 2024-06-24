// lib/view/admin/principal_admin_view.dart

// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrincipalAdminView extends StatefulWidget {
  const PrincipalAdminView({super.key});

  @override
  State<PrincipalAdminView> createState() => _PrincipalAdminViewState();
}

class _PrincipalAdminViewState extends State<PrincipalAdminView> {
  String? tipoFiltro;
  String? fileiraFiltro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administração de Vagas'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _construirConsulta().snapshots(),
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
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editarVaga(context, vaga.id, vagaData);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removerVaga(vaga.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _adicionarVaga(context);
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

  void _adicionarVaga(BuildContext context) {
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
    String tipoSelecionado = vagaData['tipo'];
    String fileiraSelecionada = vagaData['fileira'];

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
                    tipoSelecionado = valor!;
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
                    fileiraSelecionada = valor!;
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

  void _removerVaga(String vagaId) {
    FirebaseFirestore.instance.collection('vagas').doc(vagaId).delete();
  }
}
