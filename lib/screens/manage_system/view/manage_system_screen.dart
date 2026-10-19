// lib/screens/manage_system/view/manage_system_screen.dart
//
// Hosts every management screen behind a sidebar.
//  • width >= 1000  → full sidebar (icons + labels, grouped)
//  • 700 – 999      → compact sidebar (icons only, with tooltips)
//  • < 700 (phones) → horizontally scrollable section chips on top
//
// Each section creates its own provider the first time it is opened and is
// then kept alive (search text, scroll position and loaded data survive
// switching sections). Sections are built lazily, so opening this screen
// does NOT fire nine network requests at once.

import 'package:emergency_room/screens/manage_system/repo/approval_authority_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/complaint_type_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/important_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/neighborhood_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/repaire_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/risk_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/sector_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/users_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── Handasah ─────────────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_handasah_screen.dart';
// ── Sectors ──────────────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/sector_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_sectors_screen.dart';
// ── Neighborhoods ────────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/neighborhood_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_neighborhoods_screen.dart';
// ── Approval authorities ─────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/approval_authority_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_approval_authorities_screen.dart';
// ── Important status ─────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/important_status_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_important_status_screen.dart';
// ── Repaire status ───────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/repaire_status_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_repaire_status_screen.dart';
// ── Risk status ──────────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/risk_status_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_risk_status_screen.dart';
// ── Complaint types ──────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/complaint_type_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_complaint_types_screen.dart';
// ── Users ────────────────────────────────────────────────────────────────
import 'package:emergency_room/screens/manage_system/control/users_provider.dart';
import 'package:emergency_room/screens/manage_system/view/manage_users_screen.dart';

// ======================================================================
// Sections
// ======================================================================

class _Section {
  const _Section({
    required this.title,
    required this.icon,
    required this.group,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final String group;

  /// Creates the section's provider + screen. Called once, on first visit.
  final Widget Function() builder;
}

final List<_Section> _sections = [
  // ── البيانات الأساسية
  _Section(
    title: 'الهندسات',
    icon: Icons.engineering_rounded,
    group: 'البيانات الأساسية',
    builder: () => ChangeNotifierProvider(
      create: (_) => HandasahProvider(HandasahRepo()),
      child: const ManageHandasahScreen(),
    ),
  ),
  _Section(
    title: 'القطاعات',
    icon: Icons.domain_rounded,
    group: 'البيانات الأساسية',
    builder: () => ChangeNotifierProvider(
      create: (_) => SectorProvider(SectorRepo()),
      child: const ManageSectorsScreen(),
    ),
  ),
  _Section(
    title: 'الأحياء',
    icon: Icons.location_city_rounded,
    group: 'البيانات الأساسية',
    builder: () => ChangeNotifierProvider(
      create: (_) => NeighborhoodProvider(NeighborhoodRepo()),
      child: const ManageNeighborhoodsScreen(),
    ),
  ),

  // ── الحالات والأنواع
  _Section(
    title: 'جهات الاعتماد',
    icon: Icons.verified_user_rounded,
    group: 'الحالات والأنواع',
    builder: () => ChangeNotifierProvider(
      create: (_) => ApprovalAuthorityProvider(ApprovalAuthorityRepo()),
      child: const ManageApprovalAuthoritiesScreen(),
    ),
  ),
  _Section(
    title: 'الحالات المهمة',
    icon: Icons.priority_high_rounded,
    group: 'الحالات والأنواع',
    builder: () => ChangeNotifierProvider(
      create: (_) => ImportantStatusProvider(ImportantStatusRepo()),
      child: const ManageImportantStatusScreen(),
    ),
  ),
  _Section(
    title: 'حالات الإصلاح',
    icon: Icons.build_circle_rounded,
    group: 'الحالات والأنواع',
    builder: () => ChangeNotifierProvider(
      create: (_) => RepaireStatusProvider(RepaireStatusRepo()),
      child: const ManageRepaireStatusScreen(),
    ),
  ),
  _Section(
    title: 'حالات الخطورة',
    icon: Icons.warning_amber_rounded,
    group: 'الحالات والأنواع',
    builder: () => ChangeNotifierProvider(
      create: (_) => RiskStatusProvider(RiskStatusRepo()),
      child: const ManageRiskStatusScreen(),
    ),
  ),
  _Section(
    title: 'أنواع الشكاوى',
    icon: Icons.report_problem_rounded,
    group: 'الحالات والأنواع',
    builder: () => ChangeNotifierProvider(
      create: (_) => ComplaintTypeProvider(ComplaintTypeRepo()),
      child: const ManageComplaintTypesScreen(),
    ),
  ),

  // ── الحسابات
  _Section(
    title: 'المستخدمون',
    icon: Icons.people_alt_rounded,
    group: 'الحسابات',
    builder: () => ChangeNotifierProvider(
      create: (_) => UsersProvider(UsersRepo()),
      child: const ManageUsersScreen(),
    ),
  ),
];

// ======================================================================
// Screen
// ======================================================================

class ManageSystemScreen extends StatefulWidget {
  const ManageSystemScreen({
    super.key,
    this.initialIndex = 0,
    this.sidebarHeader,
  });

  /// Which section is open first (index into the sidebar order).
  final int initialIndex;

  /// Optional widget shown at the top of the sidebar (logo, app name, ...).
  /// Falls back to a default "إدارة النظام" header when null.
  final Widget? sidebarHeader;

  @override
  State<ManageSystemScreen> createState() => _ManageSystemScreenState();
}

class _ManageSystemScreenState extends State<ManageSystemScreen> {
  late int _index = widget.initialIndex.clamp(0, _sections.length - 1).toInt();
  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _visited.add(_index);
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() {
      _index = i;
      _visited.add(i);
    });
  }

  /// All visited sections stay alive; unvisited ones are not built at all.
  Widget _content() {
    return IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < _sections.length; i++)
          _visited.contains(i)
              // Own messenger → snackbars appear inside the section, above
              // its own floating button, instead of on the outer scaffold.
              ? ScaffoldMessenger(child: _sections[i].builder())
              : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          if (w < 700) {
            // Phone: chips on top, content below.
            return Scaffold(
              body: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: _SectionStrip(selected: _index, onSelect: _select),
                  ),
                  Expanded(
                    // The strip already consumed the status-bar inset.
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: _content(),
                    ),
                  ),
                ],
              ),
            );
          }

          // Tablet / desktop / web: sidebar + content.
          return Scaffold(
            body: Row(
              children: [
                _Sidebar(
                  extended: w >= 1000,
                  selected: _index,
                  onSelect: _select,
                  header: widget.sidebarHeader,
                ),
                Expanded(child: _content()),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// Sidebar (tablet / desktop / web)
// ======================================================================

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.extended,
    required this.selected,
    required this.onSelect,
    this.header,
  });

  final bool extended;
  final int selected;
  final ValueChanged<int> onSelect;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final children = <Widget>[];
    String? lastGroup;
    for (var i = 0; i < _sections.length; i++) {
      final s = _sections[i];
      if (s.group != lastGroup) {
        children.add(
          extended
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Text(
                    s.group,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                )
              : (lastGroup == null
                  ? const SizedBox(height: 8)
                  : const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(height: 1),
                    )),
        );
        lastGroup = s.group;
      }
      children.add(
        _SidebarItem(
          section: s,
          extended: extended,
          selected: i == selected,
          onTap: () => onSelect(i),
        ),
      );
    }

    return Container(
      width: extended ? 268 : 76,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: BorderDirectional(
          end: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            header ?? _DefaultHeader(extended: extended),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultHeader extends StatelessWidget {
  const _DefaultHeader({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.settings_suggest_rounded, color: cs.onPrimary),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: extended
          ? Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'إدارة النظام',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            )
          : Center(child: icon),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.extended,
    required this.selected,
    required this.onTap,
  });

  final _Section section;
  final bool extended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onPrimaryContainer : cs.onSurfaceVariant;

    final item = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 46,
            padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 0),
            decoration: BoxDecoration(
              color: selected ? cs.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: extended
                ? Row(
                    children: [
                      Icon(section.icon, size: 22, color: fg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          section.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: fg,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(child: Icon(section.icon, size: 24, color: fg)),
          ),
        ),
      ),
    );

    return extended ? item : Tooltip(message: section.title, child: item);
  }
}

// ======================================================================
// Section strip (phones)
// ======================================================================

class _SectionStrip extends StatelessWidget {
  const _SectionStrip({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant)),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          itemCount: _sections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => ChoiceChip(
            showCheckmark: false,
            avatar: Icon(_sections[i].icon, size: 18),
            label: Text(_sections[i].title),
            selected: i == selected,
            onSelected: (_) => onSelect(i),
          ),
        ),
      ),
    );
  }
}
