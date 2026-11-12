import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/auth_provider.dart';
import '../providers/donation_provider.dart';
import '../services/validators.dart';

class PublishPage extends StatefulWidget {
  final int? donationId;

  const PublishPage({
    super.key,
    this.donationId,
  });

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final formKey = GlobalKey<FormState>();
  final foodController = TextEditingController();
  final quantityController = TextEditingController();
  final expirationController = TextEditingController();
  final pickupController = TextEditingController();

  Donation? editingDonation;
  bool saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.donationId != null) {
      editingDonation = context
          .read<DonationProvider>()
          .findById(widget.donationId!);

      if (editingDonation != null) {
        foodController.text = editingDonation!.foodName;
        quantityController.text = editingDonation!.quantityKg.toString();
        expirationController.text = editingDonation!.expiration;
        pickupController.text = editingDonation!.pickupTime;
      }
    }
  }

  @override
  void dispose() {
    foodController.dispose();
    quantityController.dispose();
    expirationController.dispose();
    pickupController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<DonationProvider>();
    final profile = auth.profile!;

    if (!profile.isSupplier) return;

    setState(() {
      saving = true;
    });

    final quantity = double.parse(
      quantityController.text.replaceAll(',', '.'),
    );

    bool success;

    if (editingDonation == null) {
      success = await provider.add(
        foodName: foodController.text.trim(),
        quantityKg: quantity,
        expiration: expirationController.text.trim(),
        pickupTime: pickupController.text.trim(),
        establishmentName: profile.name,
        address: profile.fullAddress,
        ownerEmail: profile.email,
      );
    } else {
      final updated = editingDonation!.copyWith(
        foodName: foodController.text.trim(),
        quantityKg: quantity,
        expiration: expirationController.text.trim(),
        pickupTime: pickupController.text.trim(),
        establishmentName: profile.name,
        address: profile.fullAddress,
        ownerEmail: profile.email,
      );

      success = await provider.updateDonation(updated);
    }

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editingDonation == null
                ? 'Doação cadastrada com sucesso.'
                : 'Doação atualizada com sucesso.',
          ),
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error ?? 'Não foi possível salvar a doação.',
        ),
      ),
    );
  }

  Future<void> selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: now,
    );

    if (selected == null) return;

    final day = selected.day.toString().padLeft(2, '0');
    final month = selected.month.toString().padLeft(2, '0');

    expirationController.text = '$day/$month/${selected.year}';
  }

  Future<void> selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected == null || !mounted) return;

    final start = selected.format(context);
    pickupController.text = start;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile!;
    final editing = editingDonation != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar doação' : 'Cadastrar doação'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth > 820
              ? 820.0
              : constraints.maxWidth;

          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderCard(editing: editing),
                        const SizedBox(height: 20),
                        if (!profile.isSupplier)
                          const _SupplierWarning()
                        else ...[
                          _FormSection(
                            title: 'Informações do alimento',
                            subtitle:
                                'Descreva o excedente que será disponibilizado.',
                            icon: Icons.restaurant_menu_outlined,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: foodController,
                                  validator: Validators.requiredField,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Alimento',
                                    hintText: 'Ex.: arroz, feijão, pães, frutas',
                                    prefixIcon:
                                        Icon(Icons.restaurant_outlined),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: quantityController,
                                  validator: Validators.positiveNumber,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantidade em kg',
                                    hintText: 'Ex.: 15',
                                    prefixIcon: Icon(Icons.scale_outlined),
                                    suffixText: 'kg',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FormSection(
                            title: 'Retirada',
                            subtitle:
                                'Informe a validade e o melhor horário para retirada.',
                            icon: Icons.schedule_outlined,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: expirationController,
                                  validator: Validators.requiredField,
                                  readOnly: true,
                                  onTap: selectDate,
                                  decoration: InputDecoration(
                                    labelText: 'Validade',
                                    hintText: 'Selecione a data',
                                    prefixIcon:
                                        const Icon(Icons.calendar_today_outlined),
                                    suffixIcon: IconButton(
                                      onPressed: selectDate,
                                      icon: const Icon(Icons.expand_more),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: pickupController,
                                  validator: Validators.requiredField,
                                  readOnly: true,
                                  onTap: selectTime,
                                  decoration: InputDecoration(
                                    labelText: 'Horário de retirada',
                                    hintText: 'Selecione o horário',
                                    prefixIcon:
                                        const Icon(Icons.access_time_outlined),
                                    suffixIcon: IconButton(
                                      onPressed: selectTime,
                                      icon: const Icon(Icons.expand_more),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LocationCard(
                            establishmentName: profile.name,
                            address: profile.fullAddress,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: saving
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: FilledButton.icon(
                                  onPressed: saving ? null : save,
                                  icon: saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Icon(
                                          editing
                                              ? Icons.save_outlined
                                              : Icons.add_circle_outline,
                                        ),
                                  label: Text(
                                    saving
                                        ? 'Salvando...'
                                        : editing
                                            ? 'Salvar alterações'
                                            : 'Cadastrar doação',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool editing;

  const _HeaderCard({required this.editing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123F2D),
            Color(0xFF26734E),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editing ? 'Atualizar doação' : 'Nova doação',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  editing
                      ? 'Mantenha os dados corretos para facilitar a retirada.'
                      : 'Cadastre um alimento excedente e conecte-o a quem precisa.',
                  style: const TextStyle(
                    color: Color(0xFFDCEAE1),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4ED),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1F7A4D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF173126),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF718078),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String establishmentName;
  final String address;

  const _LocationCard({
    required this.establishmentName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2DD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFC4771F),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    establishmentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF173126),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Color(0xFF718078),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierWarning extends StatelessWidget {
  const _SupplierWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB7672A),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Somente perfis de Fornecedor podem cadastrar doações.',
            ),
          ),
        ],
      ),
    );
  }
}
