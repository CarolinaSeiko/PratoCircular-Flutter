import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/cep_service.dart';
import '../services/validators.dart';

class ProfilePage extends StatefulWidget {
  final bool firstRegistration;

  const ProfilePage({
    super.key,
    required this.firstRegistration,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final cepService = CepService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final cepController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  String type = '';
  bool searchingCep = false;
  String? cepMessage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    if (!widget.firstRegistration && profile != null) {
      nameController.text = profile.name;
      emailController.text = profile.email;
      phoneController.text = profile.phone;
      passwordController.text = profile.password;
      confirmController.text = profile.password;
      cepController.text = profile.cep;
      streetController.text = profile.street;
      numberController.text = profile.number;
      neighborhoodController.text = profile.neighborhood;
      cityController.text = profile.city;
      stateController.text = profile.state;
      type = profile.type;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    cepController.dispose();
    streetController.dispose();
    numberController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  Future<void> searchCep() async {
    setState(() {
      searchingCep = true;
      cepMessage = null;
    });
    try {
      final address = await cepService.search(cepController.text);
      streetController.text = address.street;
      neighborhoodController.text = address.neighborhood;
      cityController.text = address.city;
      stateController.text = address.state;
      setState(() {
        cepMessage = 'Endereço encontrado.';
      });
    } catch (error) {
      setState(() {
        cepMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          searchingCep = false;
        });
      }
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (type.isEmpty) {
      setState(() {
        cepMessage = 'Escolha o tipo de conta.';
      });
      return;
    }
    if (passwordController.text != confirmController.text) {
      setState(() {
        cepMessage = 'As senhas não conferem.';
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final current = auth.profile;
    final profile = UserProfile(
      id: current?.id ?? 0,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim(),
      type: type,
      cep: cepController.text.trim(),
      street: streetController.text.trim(),
      number: numberController.text.trim(),
      neighborhood: neighborhoodController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
    );

    final success = widget.firstRegistration
        ? await auth.register(profile)
        : await auth.updateProfile(profile);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.firstRegistration ? 'Criar conta' : 'Meu perfil'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF123526),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.firstRegistration ? 'NOVO PERFIL' : 'MEU PERFIL',
                    style: const TextStyle(
                      color: Color(0xFFDDEBD8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.firstRegistration
                        ? 'Como você participa do Prato Circular?'
                        : nameController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (widget.firstRegistration) ...[
              const Text(
                'Tipo de conta',
                style: TextStyle(
                  color: Color(0xFF123526),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Fornecedor'),
                      selected: type == 'Fornecedor',
                      onSelected: (_) => setState(() => type = 'Fornecedor'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('ONG'),
                      selected: type == 'ONG',
                      onSelected: (_) => setState(() => type = 'ONG'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: nameController,
              validator: Validators.requiredField,
              decoration: InputDecoration(
                labelText: type == 'Fornecedor'
                    ? 'Nome do estabelecimento'
                    : 'Nome da ONG',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              enabled: widget.firstRegistration,
              validator: Validators.email,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: Validators.password,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmController,
              obscureText: true,
              validator: Validators.password,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cepController,
                    validator: Validators.requiredField,
                    decoration: const InputDecoration(labelText: 'CEP'),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: searchingCep ? null : searchCep,
                  child: Text(searchingCep ? 'Buscando...' : 'Buscar CEP'),
                ),
              ],
            ),
            if (cepMessage != null) ...[
              const SizedBox(height: 8),
              Text(cepMessage!),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: streetController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'Rua'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: numberController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'Número'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: neighborhoodController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'Bairro'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cityController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'Cidade'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: stateController,
              validator: Validators.requiredField,
              decoration: const InputDecoration(labelText: 'UF'),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(
                auth.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.loading ? null : save,
              child: Text(
                widget.firstRegistration ? 'Criar conta' : 'Salvar alterações',
              ),
            ),
            if (!widget.firstRegistration) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
