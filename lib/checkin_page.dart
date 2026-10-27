import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  String? _ingressoNome;
  String? _ingressoEmail;

  bool _lendo = false;
  bool _jaLeu = false;

  String? _resultado;
  String _resultadoNome = '';
  IconData _resultadoIcone = Icons.check_circle;
  Color _resultadoCor = Colors.green;

  final List<String> _presentes = [];

  void _gerarIngresso() {
    setState(() {
      _ingressoNome = _nomeController.text.trim();
      _ingressoEmail = _emailController.text.trim();
    });
  }

  void _lerIngresso() {
    setState(() {
      _jaLeu = false;
      _lendo = true;
    });
  }

  void _cancelarLeitura() {
    setState(() {
      _lendo = false;
    });
  }

  void _validar(String codigo) {
    final partes = codigo.split('|');
    final ingressoValido = partes.length == 3 && partes[0] == 'CHECKIN';

    setState(() {
      _lendo = false;

      if (!ingressoValido) {
        _resultado = 'QR inválido';
        _resultadoNome = '';
        _resultadoIcone = Icons.cancel;
        _resultadoCor = Colors.red;
      } else if (_presentes.contains(partes[1])) {
        _resultado = 'Já fez check-in';
        _resultadoNome = partes[1];
        _resultadoIcone = Icons.warning;
        _resultadoCor = Colors.orange;
      } else {
        _presentes.add(partes[1]);
        _resultado = 'Check-in confirmado';
        _resultadoNome = partes[1];
        _resultadoIcone = Icons.check_circle;
        _resultadoCor = Colors.green;
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viagem da Computação 2027')),
      body: _lendo ? _camera() : _pagina(),
    );
  }

  Widget _camera() {

    return Stack(
      children: [
        MobileScanner(
          onDetect: (BarcodeCapture capture) {
            if (_jaLeu) return;
            final codigo = capture.barcodes.first.rawValue;
            if (codigo == null) return;
            _jaLeu = true;
            _validar(codigo);
          },
        ),
        const Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Text(
            'Aponte para o QR do ingresso',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        Positioned(
          bottom: 32,
          left: 32,
          right: 32,
          child: FilledButton(
            onPressed: _cancelarLeitura,
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  Widget _pagina() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome do participante'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _nomeController.text.trim().isEmpty ? null : _gerarIngresso,
            child: const Text('Gerar ingresso'),
          ),
          const SizedBox(height: 16),

          if (_ingressoNome != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            'https://picsum.photos/seed/evento/400/200',
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.event, size: 80),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _ingressoNome!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(_ingressoEmail!),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    QrImageView(
                      data: 'CHECKIN|$_ingressoNome|$_ingressoEmail',
                      size: 120,
                    ),
                  ],
                ),
              ),
            ),

          const Divider(height: 32),
          Text('Check-in', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _lerIngresso,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ler ingresso'),
          ),
          const SizedBox(height: 16),

          if (_resultado != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _resultadoCor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(_resultadoIcone, color: _resultadoCor, size: 32),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resultado!,
                        style: TextStyle(
                          color: _resultadoCor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (_resultadoNome.isNotEmpty) Text(_resultadoNome),
                    ],
                  ),
                ],
              ),
            ),

          const Divider(height: 32),

          Text(
            'Presentes (${_presentes.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final nome in _presentes) Text('✔  $nome'),
        ],
      ),
    );
  }
}
