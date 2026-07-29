import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../accounts/accounts_screen.dart';
import '../dashboard/trip_list_screen.dart';
import '../live_map/live_map_screen.dart';
import '../mail_settings/mail_settings_screen.dart';
import '../master_data/master_data_screen.dart';
import '../profile/my_profile_screen.dart';
import '../reports/report_screen.dart';

class _ShellDestination {
  const _ShellDestination({required this.label, required this.icon, required this.content});

  final String label;
  final IconData icon;
  final Widget content;
}

/// admin_web'in ana kabugu: solda kalici bir NavigationRail, sagda secili
/// bolumun icerigi. Her bolum kendi Scaffold/AppBar'ini korur (sadece
/// baslik), ust duzey sayfa gecisleri artik Navigator.push yerine buradan
/// (IndexedStack ile, sayfa durumu korunarak) yapilir.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _seciliIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isManagerOrAdmin = ref.watch(isManagerOrAdminProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isOperator = ref.watch(isOperatorProvider);

    final destinations = <_ShellDestination>[
      const _ShellDestination(
        label: 'Seferler',
        icon: Icons.list_alt_outlined,
        content: TripListScreen(),
      ),
      if (isManagerOrAdmin)
        const _ShellDestination(
          label: 'Kullanıcılar',
          icon: Icons.people_outline,
          content: AccountsScreen(),
        ),
      if (isAdmin)
        const _ShellDestination(
          label: 'Master Veri',
          icon: Icons.storage_outlined,
          content: MasterDataScreen(),
        ),
      if (isAdmin)
        const _ShellDestination(
          label: 'Mail Ayarları',
          icon: Icons.mail_outline,
          content: MailSettingsScreen(),
        ),
      if (isManagerOrAdmin || isOperator)
        const _ShellDestination(
          label: 'Sefer Raporu',
          icon: Icons.description_outlined,
          content: ReportScreen(),
        ),
      if (isManagerOrAdmin)
        const _ShellDestination(
          label: 'Canlı Konum',
          icon: Icons.map_outlined,
          content: LiveMapScreen(),
        ),
      const _ShellDestination(
        label: 'Profilim',
        icon: Icons.person_outline,
        content: MyProfileScreen(),
      ),
    ];

    final index = _seciliIndex >= destinations.length ? 0 : _seciliIndex;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 210,
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => _seciliIndex = i),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(DedemBrand.faviconAssetPath, package: 'core', height: 28),
                  const SizedBox(width: 10),
                  const Text('Şoför Takip', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => ref.read(authRepositoryProvider).signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Çıkış Yap'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            destinations: destinations
                .map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: index,
              children: destinations.map((d) => d.content).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
