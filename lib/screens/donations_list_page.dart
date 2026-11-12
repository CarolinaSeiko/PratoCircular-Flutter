import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/auth_provider.dart';
import '../providers/donation_provider.dart';
import '../widgets/donation_card.dart';
import 'detail_page.dart';
import 'publish_page.dart';

class DonationsListPage extends StatefulWidget {
  const DonationsListPage({super.key});

  @override
  State<DonationsListPage> createState() => _DonationsListPageState();
}

class _DonationsListPageState extends State<DonationsListPage> {
  String query = '';

  Future<void> openDetail(Donation donation) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPage(
          donationId: donation.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonationProvider>();
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile!;

    final filtered = provider.donations.where((donation) {
      final search = query.trim().toLowerCase();
      if (search.isEmpty) return true;
      return donation.foodName.toLowerCase().contains(search) ||
          donation.establishmentName.toLowerCase().contains(search) ||
          donation.status.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todas as doações',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButton: profile.isSupplier
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PublishPage(),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nova doação'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 900
                ? 900.0
                : constraints.maxWidth;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              children: [
                Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explore as doações',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173126),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Busque por alimento, estabelecimento ou status.',
                          style: TextStyle(
                            color: Color(0xFF718078),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Buscar doações',
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (provider.loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(36),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (provider.error != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFB54A4A),
                                    size: 34,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(provider.error!),
                                  const SizedBox(height: 14),
                                  OutlinedButton(
                                    onPressed: provider.load,
                                    child: const Text('Tentar novamente'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (filtered.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_outlined,
                                    size: 42,
                                    color: Color(0xFF839188),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Nenhuma doação encontrada.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (donation) => DonationCard(
                              donation: donation,
                              onTap: () => openDetail(donation),
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
