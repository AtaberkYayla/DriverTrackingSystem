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
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.content,
  });

  final String label;
  final IconData icon;
  final Widget content;
}

/// Sidebar'daki tek bir satir: secili oldugunda ikon + yazi birlikte
/// (tum satir boyunca) vurgulanir, sadece ikonun etrafinda kucuk bir
/// "hap" yerine.
class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
          SizedBox(
            width: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        DedemBrand.faviconAssetPath,
                        package: 'core',
                        height: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Şoför Takip Sistemi',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        _SidebarItem(
                          icon: destinations[i].icon,
                          label: destinations[i].label,
                          selected: i == index,
                          onTap: () => setState(() => _seciliIndex = i),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            ref.read(authRepositoryProvider).signOut(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Çıkış Yap'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
