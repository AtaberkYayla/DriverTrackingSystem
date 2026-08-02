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

/// Sidebar'da nav ogelerini gruplamak icin: operasyonel ekranlar ile
/// yonetimsel (admin/manager) ekranlar arasina bir baslik/bosluk koymak,
/// "Profilim"i de hesap bilgisiyle birlikte alt bolume koymak icin.
enum _NavGroup { operasyon, yonetim, hesap }

const _rolAdlari = {
  AppRole.admin: 'Admin',
  AppRole.manager: 'Yönetici',
  AppRole.operator: 'Operatör',
  AppRole.office: 'Onay Verici',
  AppRole.driver: 'Şoför',
};

String _bashHarfleri(String adSoyad) {
  final parcalar = adSoyad.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parcalar.isEmpty) return '?';
  if (parcalar.length == 1) return parcalar.first.characters.first.toUpperCase();
  return (parcalar.first.characters.first + parcalar.last.characters.first).toUpperCase();
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.content,
    required this.group,
  });

  final String label;
  final IconData icon;
  final Widget content;
  final _NavGroup group;
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
                Icon(icon, color: color, size: 21),
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

/// Sidebar nav listesinde bir grubun ustundeki kucuk kapital baslik
/// ("OPERASYON", "YÖNETİM") - bolumler arasindaki hiyerarsiyi belirginlestirir.
class _GrupBasligi extends StatelessWidget {
  const _GrupBasligi(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Text(
        metin,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
    final profile = ref.watch(currentProfileProvider).value;
    final colorScheme = Theme.of(context).colorScheme;

    final destinations = <_ShellDestination>[
      const _ShellDestination(
        label: 'Seferler',
        icon: Icons.list_alt_outlined,
        content: TripListScreen(),
        group: _NavGroup.operasyon,
      ),
      if (isManagerOrAdmin || isOperator)
        const _ShellDestination(
          label: 'Sefer Raporu',
          icon: Icons.description_outlined,
          content: ReportScreen(),
          group: _NavGroup.operasyon,
        ),
      if (isManagerOrAdmin)
        const _ShellDestination(
          label: 'Canlı Konum',
          icon: Icons.map_outlined,
          content: LiveMapScreen(),
          group: _NavGroup.operasyon,
        ),
      if (isManagerOrAdmin)
        const _ShellDestination(
          label: 'Kullanıcılar',
          icon: Icons.people_outline,
          content: AccountsScreen(),
          group: _NavGroup.yonetim,
        ),
      if (isAdmin)
        const _ShellDestination(
          label: 'Master Veri',
          icon: Icons.storage_outlined,
          content: MasterDataScreen(),
          group: _NavGroup.yonetim,
        ),
      if (isAdmin)
        const _ShellDestination(
          label: 'Mail Ayarları',
          icon: Icons.mail_outline,
          content: MailSettingsScreen(),
          group: _NavGroup.yonetim,
        ),
      const _ShellDestination(
        label: 'Profilim',
        icon: Icons.person_outline,
        content: MyProfileScreen(),
        group: _NavGroup.hesap,
      ),
    ];

    final index = _seciliIndex >= destinations.length ? 0 : _seciliIndex;
    final anaNavIndeksleri = [
      for (var i = 0; i < destinations.length; i++)
        if (destinations[i].group != _NavGroup.hesap) i,
    ];
    final hesapNavIndeksleri = [
      for (var i = 0; i < destinations.length; i++)
        if (destinations[i].group == _NavGroup.hesap) i,
    ];

    Widget sidebarOgesi(int i) => _SidebarItem(
          icon: destinations[i].icon,
          label: destinations[i].label,
          selected: i == index,
          onTap: () => setState(() => _seciliIndex = i),
        );

    final anaNavCocuklari = <Widget>[];
    _NavGroup? oncekiGrup;
    for (final i in anaNavIndeksleri) {
      if (destinations[i].group != oncekiGrup) {
        anaNavCocuklari.add(
          _GrupBasligi(destinations[i].group == _NavGroup.operasyon ? 'OPERASYON' : 'YÖNETİM'),
        );
      }
      anaNavCocuklari.add(sidebarOgesi(i));
      oncekiGrup = destinations[i].group;
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
            color: colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        DedemBrand.faviconAssetPath,
                        package: 'core',
                        height: 28,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Şoför Takip Sistemi',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    children: anaNavCocuklari,
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final i in hesapNavIndeksleri) sidebarOgesi(i),
                    ],
                  ),
                ),
                if (profile != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            _bashHarfleri(profile.fullName),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                profile.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                _rolAdlari[profile.role] ?? profile.role.name,
                                style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
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
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Çıkış Yap'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          'v1.3.0',
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
