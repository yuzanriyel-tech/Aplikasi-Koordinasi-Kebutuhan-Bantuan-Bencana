import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/item_repository.dart';
import '../models/item.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../utils/validators.dart';
import '../widgets/posko_app_bar.dart';
import '../widgets/posko_dialog.dart';
import '../widgets/posko_widgets.dart';

/// Form kebutuhan. Tanpa [item] = Tambah kebutuhan (Requirement Input),
/// dengan [item] = Edit kebutuhan (Requirement Edit).
class RequirementFormScreen extends StatefulWidget {
  const RequirementFormScreen({super.key, this.item});
  final Item? item;

  @override
  State<RequirementFormScreen> createState() => _RequirementFormScreenState();
}

class _RequirementFormScreenState extends State<RequirementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();
  final _repository = ItemRepository();

  Urgency? _urgency;
  bool _urgencyError = false;
  bool _hasPhoto = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _titleController.text = item.title;
      _quantityController.text = '${item.quantity}';
      _unitController.text = item.unit;
      _noteController.text = item.note;
      _urgency = item.urgency;
      _hasPhoto = item.hasPhoto;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _urgencyError = _urgency == null);
    if (!formValid || _urgency == null) return;

    final quantity = int.parse(_quantityController.text.trim());
    final existing = widget.item;
    if (existing == null) {
      final location = AuthRepository.instance.currentLocation;
      _repository.add(
        Item(
          id: _repository.nextId(),
          title: _titleController.text.trim(),
          quantity: quantity,
          unit: _unitController.text.trim(),
          urgency: _urgency!,
          note: _noteController.text.trim(),
          hasPhoto: _hasPhoto,
          latitude: location.latitude,
          longitude: location.longitude,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      _repository.update(
        existing.copyWith(
          title: _titleController.text.trim(),
          quantity: quantity,
          unit: _unitController.text.trim(),
          urgency: _urgency,
          note: _noteController.text.trim(),
          hasPhoto: _hasPhoto,
        ),
      );
    }

    // Saat online, data langsung dikirim otomatis; saat offline masuk antrean.
    final online = AppState.instance.isOnline;
    AppState.instance.syncNow();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          online
              ? 'Tersimpan di perangkat. Data sedang dikirim ke server.'
              : 'Tersimpan di perangkat. Akan dikirim saat online.',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showPoskoDialog(
      context,
      title: 'Pemberitahuan',
      message: 'Kebutuhan ini akan dihapus, Anda yakin?',
      confirmLabel: 'Ya',
      cancelLabel: 'Batal',
    );
    if (confirmed != true || !mounted) return;
    _repository.remove(widget.item!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kebutuhan dihapus.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PoskoAppBar(
        title: _isEdit ? 'Edit kebutuhan' : 'Tambah kebutuhan',
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            20,
            AppDimens.screenPadding,
            24,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PoskoTextField(
                  controller: _titleController,
                  label: 'Jenis barang',
                  hintText: 'cth: Susu bayi',
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.requiredField(value, fieldName: 'Jenis barang'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PoskoTextField(
                        controller: _quantityController,
                        label: 'Jumlah',
                        hintText: 'cth: 10',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: Validators.quantity,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: PoskoTextField(
                        controller: _unitController,
                        label: 'Satuan',
                        hintText: 'cth: kaleng',
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.requiredField(value, fieldName: 'Satuan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const PoskoFieldLabel('Tingkat urgensi'),
                const SizedBox(height: 8),
                _UrgencySelector(
                  selected: _urgency,
                  onChanged: (value) => setState(() {
                    _urgency = value;
                    _urgencyError = false;
                  }),
                ),
                if (_urgencyError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Pilih tingkat urgensi',
                      style: TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                const SizedBox(height: 16),
                PoskoTextField(
                  controller: _noteController,
                  label: 'Keterangan tambahan',
                  optional: true,
                  hintText: 'cth: untuk bayi berusia 6 bulan',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const PoskoFieldLabel('Foto kondisi lapangan', optional: true),
                const SizedBox(height: 8),
                
                _PhotoBox(
                  hasPhoto: _hasPhoto,
                  onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                ),
                const SizedBox(height: 24),
                PoskoPrimaryButton(label: 'Simpan di Perangkat', onPressed: _save),
                const SizedBox(height: 8),
                const Text(
                  'Lokasi posko dicatat otomatis. Data dikirim ke server saat online.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                if (_isEdit) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _delete,
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    child: const Text(
                      'Hapus data ini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgencySelector extends StatelessWidget {
  const _UrgencySelector({required this.selected, required this.onChanged});
  final Urgency? selected;
  final ValueChanged<Urgency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final urgency in Urgency.values) ...[
          Expanded(
            child: _UrgencyBox(
              urgency: urgency,
              selected: urgency == selected,
              onTap: () => onChanged(urgency),
            ),
          ),
          if (urgency != Urgency.values.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _UrgencyBox extends StatelessWidget {
  const _UrgencyBox({required this.urgency, required this.selected, required this.onTap});
  final Urgency urgency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fill, border, text) = switch (urgency) {
      Urgency.tinggi => (
          AppColors.urgencyHighFill,
          AppColors.urgencyHighBorder,
          const Color(0xFFE90C0C),
        ),
      Urgency.sedang => (
          AppColors.urgencyMidFill,
          AppColors.urgencyMidBorder,
          AppColors.urgencyMidFg,
        ),
      Urgency.rendah => (
          AppColors.urgencyLowFill,
          AppColors.urgencyLowBorder,
          AppColors.urgencyLowFg,
        ),
    };
    return Semantics(
      button: true,
      selected: selected,
      label: 'Urgensi ${urgency.label}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppDimens.urgencyBoxHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? fill : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.fieldRadius),
            border: Border.all(
              color: selected ? border : const Color(0xFFD9D9D9),
              width: 2,
            ),
          ),
          child: Text(
            urgency.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? text : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  const _PhotoBox({required this.hasPhoto, required this.onTap});
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ambil foto kondisi lapangan',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: const _DashedBorderPainter(color: AppColors.dashed),
          child: SizedBox(
            height: 100,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(102),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasPhoto ? Icons.check : Icons.photo_camera_outlined,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasPhoto
                      ? 'Foto terlampir (ketuk untuk mengganti)'
                      : 'Ambil foto kondisi lapangan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
