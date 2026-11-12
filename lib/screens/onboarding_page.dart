import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final ValueChanged<bool> onFinish;

  const OnboardingPage({
    super.key,
    required this.onFinish,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int index = 0;
  bool doNotShowAgain = false;

  final pages = const [
    (
      'DOAÇÃO GRATUITA',
      'Alimento sobrando de um lado, necessidade do outro',
      'O Prato Circular conecta fornecedores com excedentes a ONGs que podem transformar esses alimentos em novas refeições.',
      Icons.volunteer_activism,
    ),
    (
      'CONEXÃO DIRETA',
      'Doar ficou mais simples',
      'Fornecedores publicam alimentos disponíveis e ONGs encontram, favoritam e reservam as doações.',
      Icons.favorite,
    ),
    (
      'IMPACTO SOCIAL',
      'Cada retirada conta',
      'Acompanhe quantas doações foram publicadas, reservadas e quantos quilos de alimentos foram reaproveitados.',
      Icons.bar_chart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final page = pages[index];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDEBD8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.$4,
                  size: 60,
                  color: const Color(0xFF123526),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                page.$1,
                style: const TextStyle(
                  color: Color(0xFF2F8A4C),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                page.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF123526),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                page.$3,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              if (index == pages.length - 1)
                CheckboxListTile(
                  value: doNotShowAgain,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Não mostrar novamente'),
                  onChanged: (value) {
                    setState(() {
                      doNotShowAgain = value ?? false;
                    });
                  },
                ),
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => index--),
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (index == pages.length - 1) {
                          widget.onFinish(doNotShowAgain);
                        } else {
                          setState(() => index++);
                        }
                      },
                      child: Text(
                        index == pages.length - 1 ? 'Começar' : 'Próximo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
