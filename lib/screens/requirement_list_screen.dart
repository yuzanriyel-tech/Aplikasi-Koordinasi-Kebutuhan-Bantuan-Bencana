import 'package:flutter/material.dart';

import '../data/item_repository.dart';
import '../models/item.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../utils/view_status.dart';
import '../widgets/need_card.dart';
import '../widgets/posko_app_bar.dart';
import '../widgets/posko_bottom_nav.dart';
import '../widgets/posko_widgets.dart';
import '../widgets/state_view.dart';

enum _NeedFilter {
  all('Semua'),
  highUrgency('Urgensi tinggi'),
  pending('Pending');

  const _NeedFilter(this.label);
  final String label;
}

/// Daftar kebutuhan: filter, kartu kebutuhan, dan tombol tambah.
class RequirementListScreen extends StatefulWidget {
  const RequirementListScreen({super.key});

  @override
  State<RequirementListScreen> createState() => _RequirementListScreenState();
}

class _RequirementListScreenState extends State<RequirementListScreen> {
  final _repository = ItemRepository();
  ViewStatus _status = ViewStatus.loading;
  String _errorMessage = '';
  final bool _simulateError = false; // ubah ke true untuk menguji error state
  _NeedFilter _filter = _NeedFilter.all;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_status != ViewStatus.loading) {
      setState(() => _status = ViewStatus.loading);
    }
    try {
      await _repository.fetchItems(simulateError: _simulateError);
      if (!mounted) return;
      setState(() => _status = ViewStatus.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _status = ViewStatus.error;
      });
    }
  }

  List<Item> _filtered() {
    final all = _repository.items;
    return switch (_filter) {
      _NeedFilter.all => all,
      _NeedFilter.highUrgency =>
        all.where((item) => item.urgency == Urgency.tinggi).toList(),
      _NeedFilter.pending => all.where((item) => item.isPending).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PoskoAppBar(
        title: 'Daftar kebutuhan',
        actions: [ConnectionStatus()],
      ),
      body: SafeArea(child: _buildContent()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.requirementInput),
        backgroundColor: const Color.fromARGB(255, 223, 35, 113),
        foregroundColor: AppColors.surface,
        shape: const CircleBorder(),
        tooltip: 'Tambah kebutuhan',
        child: const Icon(Icons.add, size: 34),
      ),
      bottomNavigationBar: const PoskoBottomNav(currentIndex: 0),
    );
  }

  Widget _buildContent() {
    return switch (_status) {
      ViewStatus.loading => const LoadingView(),
      ViewStatus.error => ErrorView(message: _errorMessage, onRetry: _loadItems),
      ViewStatus.success => _buildList(),
    };
  }

  Widget _buildList() {
    return Column(
      children: [
        SizedBox(
          height: AppDimens.filterHeight + 28,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            itemCount: _NeedFilter.values.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = _NeedFilter.values[index];
              return _FilterPill(
                label: option.label,
                selected: option == _filter,
                onTap: () => setState(() => _filter = option),
              );
            },
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: _repository,
            builder: (context, _) {
              final items = _filtered();
              if (items.isEmpty) {
                return const EmptyView(message: 'Belum ada data kebutuhan.');
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                itemCount: items.length,
                separatorBuilder: (context, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return NeedCard(
                    item: item,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.detail,
                      arguments: item,
                    ),
                    onEdit: () => Navigator.pushNamed(
                      context,
                      AppRoutes.requirementEdit,
                      arguments: item,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppDimens.filterHeight,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color.fromARGB(255, 235, 66, 207) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: selected ? null : Border.all(color: AppColors.borderStrong),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.surface : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
