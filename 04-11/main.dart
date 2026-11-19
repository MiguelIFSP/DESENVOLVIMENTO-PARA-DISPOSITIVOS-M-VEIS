import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AppTwitter(),
  ));
}

class AppTwitter extends StatefulWidget {
  const AppTwitter({super.key});

  @override
  State<AppTwitter> createState() => _AppTwitterState();
}

class _AppTwitterState extends State<AppTwitter> {
  final TextEditingController controller = TextEditingController();

  final List<Map<String, dynamic>> historico = [];

  int indiceAtual = -1;
  int ultimoId = 0;

  bool carregando = false;

  String textoExibido = 'Clique em Próximo para ler';

  final String ip = '10.106.76.20/api';

  void _aplicarItem(int index) {
    final item = historico[index];

    indiceAtual = index;
    ultimoId = int.tryParse(item['id'].toString()) ?? 0;
    textoExibido = item['texto'].toString();
  }

  Future<void> enviar() async {
    final texto = controller.text.trim();

    if (texto.isEmpty || carregando) return;

    setState(() {
      carregando = true;
    });

    try {
      final url = Uri.parse('http://$ip/salva.php').replace(
        queryParameters: {
          'txt': texto,
        },
      );

      final res = await http.get(url);

      if (!mounted) return;

      if (res.statusCode == 200 && res.body.contains('Texto salvo!')) {
        controller.clear();

        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicação enviada com sucesso!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: ${res.body}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> proximo() async {
    if (carregando) return;

    if (indiceAtual < historico.length - 1) {
      setState(() {
        _aplicarItem(indiceAtual + 1);
      });
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final url = Uri.parse('http://$ip/busca.php').replace(
        queryParameters: {
          'id': ultimoId.toString(),
        },
      );

      final res = await http.get(url);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final dados = jsonDecode(res.body);

        if (dados is Map<String, dynamic> &&
            dados.containsKey('id') &&
            dados.containsKey('texto')) {
          setState(() {
            historico.add({
              'id': int.tryParse(dados['id'].toString()) ?? 0,
              'texto': dados['texto'].toString(),
            });

            _aplicarItem(historico.length - 1);
          });
        } else {
          setState(() {
            textoExibido = 'Não há próximo texto disponível.';
          });
        }
      } else {
        setState(() {
          textoExibido = 'Erro ao consultar o banco de dados.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        textoExibido = 'Erro ao buscar texto.';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void voltar() {
    if (indiceAtual > 0) {
      setState(() {
        _aplicarItem(indiceAtual - 1);
      });
    } else if (indiceAtual == 0) {
      setState(() {
        indiceAtual = -1;
        ultimoId = 0;
        textoExibido = 'Clique em Próximo para ler';
      });
    }
  }

  void abrirFotos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FotosPage(ip: ip),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Twitter'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Publicações',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Digite uma publicação',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: carregando ? null : enviar,
                child: const Text('Enviar Publicação'),
              ),
              const Divider(
                height: 40,
                thickness: 2,
              ),
              Text(
                'ID Atual: $ultimoId',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                textoExibido,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: carregando ? null : voltar,
                    child: const Text('Voltar'),
                  ),
                  ElevatedButton(
                    onPressed: carregando ? null : proximo,
                    child: carregando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Próximo'),
                  ),
                ],
              ),
              const Divider(
                height: 40,
                thickness: 2,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: abrirFotos,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Abrir Área de Fotos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FotosPage extends StatefulWidget {
  final String ip;

  const FotosPage({
    super.key,
    required this.ip,
  });

  @override
  State<FotosPage> createState() => _FotosPageState();
}

class _FotosPageState extends State<FotosPage> {
  final TextEditingController descricaoController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  final List<Map<String, dynamic>> fotosSalvas = [];

  XFile? imagem;

  int indiceFoto = 0;

  bool tirandoFoto = false;
  bool enviandoFoto = false;
  bool carregandoFotos = false;

  @override
  void initState() {
    super.initState();
    carregarFotos();
  }

  Future<void> tirarFoto() async {
    if (tirandoFoto) return;

    setState(() {
      tirandoFoto = true;
    });

    try {
      final XFile? foto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (!mounted) return;

      if (foto != null) {
        setState(() {
          imagem = foto;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao tirar foto: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          tirandoFoto = false;
        });
      }
    }
  }

  Future<void> enviarFoto() async {
    if (enviandoFoto) return;

    if (imagem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tire uma foto primeiro!'),
        ),
      );
      return;
    }

    final descricao = descricaoController.text.trim();

    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma descrição para a foto!'),
        ),
      );
      return;
    }

    setState(() {
      enviandoFoto = true;
    });

    try {
      final requisicao = http.MultipartRequest(
        'POST',
        Uri.parse('http://${widget.ip}/salva_foto.php'),
      );

      requisicao.fields['descricao'] = descricao;

      requisicao.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imagem!.path,
        ),
      );

      final resposta = await requisicao.send();

      final resultado = await http.Response.fromStream(resposta);

      final dados = jsonDecode(resultado.body);

      if (!mounted) return;

      if (resultado.statusCode == 200 &&
          dados is Map &&
          dados['sucesso'] == true) {
        setState(() {
          imagem = null;
          descricaoController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto e descrição enviadas com sucesso!'),
          ),
        );

        await carregarFotos(irParaPrimeira: true);
      } else {
        final mensagem = dados is Map
            ? dados['erro']?.toString() ?? 'Erro no envio'
            : 'Resposta inválida do servidor';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar foto: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviandoFoto = false;
        });
      }
    }
  }

  Future<void> carregarFotos({
    bool irParaPrimeira = false,
  }) async {
    if (carregandoFotos) return;

    setState(() {
      carregandoFotos = true;
    });

    try {
      final url = Uri.parse(
        'http://${widget.ip}/lista_fotos.php',
      );

      final resposta = await http.get(url);

      if (resposta.statusCode != 200) {
        throw Exception('Erro HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! List) {
        throw Exception('Resposta inválida do servidor');
      }

      final novasFotos = <Map<String, dynamic>>[];

      for (final item in dados) {
        if (item is Map) {
          novasFotos.add(
            Map<String, dynamic>.from(item),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        fotosSalvas.clear();
        fotosSalvas.addAll(novasFotos);

        if (irParaPrimeira || fotosSalvas.isEmpty) {
          indiceFoto = 0;
        } else if (indiceFoto >= fotosSalvas.length) {
          indiceFoto = fotosSalvas.length - 1;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar fotos: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregandoFotos = false;
        });
      }
    }
  }

  void fotoAnterior() {
    if (indiceFoto > 0) {
      setState(() {
        indiceFoto--;
      });
    }
  }

  void proximaFoto() {
    if (indiceFoto < fotosSalvas.length - 1) {
      setState(() {
        indiceFoto++;
      });
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fotoAtual = fotosSalvas.isNotEmpty &&
            indiceFoto >= 0 &&
            indiceFoto < fotosSalvas.length
        ? fotosSalvas[indiceFoto]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Área de Fotos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Enviar Foto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: descricaoController,
                maxLength: 1000,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descrição da foto',
                  hintText: 'Escreva sobre a foto',
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: tirandoFoto ? null : tirarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    tirandoFoto ? 'Abrindo câmera...' : 'Tirar Foto',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(13),
                  ),
                ),
              ),
              if (imagem != null) ...[
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagem!.path),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: enviandoFoto ? null : enviarFoto,
                    icon: enviandoFoto
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      enviandoFoto ? 'Enviando...' : 'Enviar Foto para o Site',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(13),
                    ),
                  ),
                ),
              ],
              const Divider(
                height: 50,
                thickness: 2,
              ),
              const Text(
                'Galeria de Fotos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: carregandoFotos ? null : () => carregarFotos(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar Galeria'),
                ),
              ),
              const SizedBox(height: 15),
              if (carregandoFotos) const CircularProgressIndicator(),
              if (!carregandoFotos && fotosSalvas.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Nenhuma foto cadastrada ainda.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (fotoAtual != null) ...[
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Foto ${indiceFoto + 1} de ${fotosSalvas.length}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fotoAtual['url'].toString(),
                            width: double.infinity,
                            height: 260,
                            fit: BoxFit.contain,
                            loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const SizedBox(
                                height: 260,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const SizedBox(
                                height: 260,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          fotoAtual['descricao']?.toString() ?? 'Sem descrição',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ID: ${fotoAtual['id']}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        if (fotoAtual['data_criacao'] != null)
                          Text(
                            'Data: ${fotoAtual['data_criacao']}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: indiceFoto > 0 ? fotoAnterior : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                    ElevatedButton.icon(
                      onPressed: indiceFoto < fotosSalvas.length - 1
                          ? proximaFoto
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Próxima'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
