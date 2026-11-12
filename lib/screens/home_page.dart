import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/auth_provider.dart';
import '../providers/donation_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/donation_card.dart';
import 'detail_page.dart';
import 'donations_list_page.dart';
import 'favorites_page.dart';
import 'impact_page.dart';
import 'my_donations_page.dart';
import 'profile_page.dart';
import 'publish_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';

  @override
  void initState() {
    super.initState();
    context.read<DonationProvider>().load();
  }

  Future<void> openDonation(Donation donation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          donationId: donation.id,
        ),
      ),
    );
  }

  Future<void> openPublish() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PublishPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<DonationProvider>();
    final profile = auth.profile!;

    final available = provider.donations.where((donation) {
      if (donation.status != 'Disponível') return false;
      final search = query.trim().toLowerCase();
      if (search.isEmpty) return true;
      return donation.foodName.toLowerCase().contains(search) ||
          donation.establishmentName.toLowerCase().contains(search);
    }).take(4).toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 36),
            SizedBox(width: 10),
            Text(
              'Prato Circular',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Impacto',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ImpactPage(),
              ),
            ),
            icon: const Icon(Icons.insights_outlined),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Perfil',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilePage(
                  firstRegistration: false,
                ),
              ),
            ),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: profile.isSupplier
          ? FloatingActionButton.extended(
              onPressed: openPublish,
              icon: const Icon(Icons.add),
              label: const Text('Nova doação'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 1180
                ? 1180.0
                : constraints.maxWidth;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              children: [
                Center(
                  child: SizedBox(
                    width: maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroSection(
                          name: profile.name,
                          isSupplier: profile.isSupplier,
                          onPrimaryAction: profile.isSupplier
                              ? openPublish
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DonationsListPage(),
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 28),
                        const _SectionTitle(
                          title: 'Visão geral',
                          subtitle: 'Acompanhe o impacto da rede em tempo real.',
                        ),
                        const SizedBox(height: 14),
                        LayoutBuilder(
                          builder: (context, innerConstraints) {
                            final isWide = innerConstraints.maxWidth >= 760;
                            final cards = [
                              _MetricCard(
                                value: provider.totalCount.toString(),
                                label: 'Doações cadastradas',
                                icon: Icons.inventory_2_outlined,
                                accent: const Color(0xFF1F7A4D),
                              ),
                              _MetricCard(
                                value: provider.availableCount.toString(),
                                label: 'Disponíveis agora',
                                icon: Icons.restaurant_menu_outlined,
                                accent: const Color(0xFF2E8B57),
                              ),
                              _MetricCard(
                                value: provider.reservedCount.toString(),
                                label: 'Reservadas',
                                icon: Icons.bookmark_border,
                                accent: const Color(0xFFD28A29),
                              ),
                              _MetricCard(
                                value:
                                    '${provider.reusedKg.toStringAsFixed(1)} kg',
                                label: 'Alimentos reaproveitados',
                                icon: Icons.eco_outlined,
                                accent: const Color(0xFF4D7C5E),
                              ),
                            ];

                            if (isWide) {
                              return Row(
                                children: [
                                  for (var i = 0; i < cards.length; i++) ...[
                                    Expanded(child: cards[i]),
                                    if (i < cards.length - 1)
                                      const SizedBox(width: 12),
                                  ],
                                ],
                              );
                            }

                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.45,
                              children: cards,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const _OdsBanner(),
                        const SizedBox(height: 28),
                        _QuickActions(
                          isSupplier: profile.isSupplier,
                          onAll: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DonationsListPage(),
                            ),
                          ),
                          onCreate: openPublish,
                          onMine: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyDonationsPage(),
                            ),
                          ),
                          onFavorites: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoritesPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            const Expanded(
                              child: _SectionTitle(
                                title: 'Doações disponíveis',
                                subtitle:
                                    'Encontre alimentos prontos para retirada.',
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DonationsListPage(),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Ver todas'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar alimento ou fornecedor',
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(36),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (provider.error != null)
                          _ErrorCard(
                            message: provider.error!,
                            onRetry: provider.load,
                          )
                        else if (available.isEmpty)
                          const _EmptyCard()
                        else
                          ...available.map(
                            (donation) => DonationCard(
                              donation: donation,
                              onTap: () => openDonation(donation),
                              onFavorite: profile.isSupplier
                                  ? null
                                  : () => provider.toggleFavorite(donation),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String name;
  final bool isSupplier;
  final VoidCallback onPrimaryAction;

  const _HeroSection({
    required this.name,
    required this.isSupplier,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E3A2A),
            Color(0xFF1F6E49),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0E3A2A),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 720;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Olá, $name',
                  style: const TextStyle(
                    color: Color(0xFFE7F4EC),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isSupplier
                    ? 'Transforme excedentes em impacto positivo.'
                    : 'Alimentos disponíveis. Conexões que fazem diferença.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSupplier
                    ? 'Publique alimentos, acompanhe reservas e reduza o desperdício de forma simples.'
                    : 'Encontre doações próximas, reserve alimentos e fortaleça sua comunidade.',
                style: const TextStyle(
                  color: Color(0xFFD9E8DF),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onPrimaryAction,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF174B35),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                icon: Icon(
                  isSupplier ? Icons.add_circle_outline : Icons.search,
                ),
                label: Text(
                  isSupplier ? 'Cadastrar doação' : 'Explorar doações',
                ),
              ),
            ],
          );

          if (!wide) return content;

          return Row(
            children: [
              Expanded(flex: 3, child: content),
              const SizedBox(width: 28),
              Expanded(
                flex: 2,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.volunteer_activism_outlined,
                      size: 104,
                      color: Color(0xFFD7EFE0),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF173126),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF718078),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF173126),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6E7D74),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OdsBanner extends StatelessWidget {
  const _OdsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF1DCA8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.public,
            color: Color(0xFF1F7A4D),
            size: 28,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impacto alinhado aos ODS',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4B3A16),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ODS 2 — Fome Zero e Agricultura Sustentável\nODS 12 — Consumo e Produção Responsáveis',
                  style: TextStyle(
                    color: Color(0xFF6D5725),
                    height: 1.5,
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

class _QuickActions extends StatelessWidget {
  final bool isSupplier;
  final VoidCallback onAll;
  final VoidCallback onCreate;
  final VoidCallback onMine;
  final VoidCallback onFavorites;

  const _QuickActions({
    required this.isSupplier,
    required this.onAll,
    required this.onCreate,
    required this.onMine,
    required this.onFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: onAll,
          icon: const Icon(Icons.grid_view_rounded),
          label: const Text('Ver todas'),
        ),
        if (isSupplier)
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Cadastrar doação'),
          ),
        if (isSupplier)
          OutlinedButton.icon(
            onPressed: onMine,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Minhas doações'),
          ),
        if (!isSupplier)
          OutlinedButton.icon(
            onPressed: onFavorites,
            icon: const Icon(Icons.favorite_border),
            label: const Text('Favoritos'),
          ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFB54A4A),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 44,
              color: Color(0xFF839188),
            ),
            SizedBox(height: 12),
            Text(
              'Nenhuma doação disponível no momento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
