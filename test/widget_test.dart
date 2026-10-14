import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_project/main.dart';
import 'package:first_project/routes/app_routes.dart';
import 'package:first_project/utils/validators.dart';

void main() {
  group('Validators', () {
    test('phone menerima nomor Indonesia dan menolak yang salah', () {
      expect(Validators.phone('081234567890'), isNull);
      expect(Validators.phone('+6281234567890'), isNull);
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('12345'), isNotNull);
    });

    test('quantity harus angka lebih dari 0', () {
      expect(Validators.quantity('10'), isNull);
      expect(Validators.quantity('0'), isNotNull);
      expect(Validators.quantity('abc'), isNotNull);
      expect(Validators.quantity(''), isNotNull);
    });

    test('confirmPassword harus sama dengan password', () {
      expect(Validators.confirmPassword('password123', 'password123'), isNull);
      expect(Validators.confirmPassword('beda', 'password123'), isNotNull);
    });
  });

  group('Login', () {
    testWidgets('menampilkan pesan wajib diisi', (tester) async {
      await tester.pumpWidget(const PoskoSyncApp(initialRoute: AppRoutes.login));

      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pump();

      expect(find.text('Nomor telepon wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('menampilkan dialog error saat kredensial salah', (tester) async {
      await tester.pumpWidget(const PoskoSyncApp(initialRoute: AppRoutes.login));

      await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
      await tester.enterText(find.byType(TextFormField).at(1), 'salahsalah');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Nomor telepon atau password salah!'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('masuk ke beranda dengan akun demo', (tester) async {
      await tester.pumpWidget(const PoskoSyncApp(initialRoute: AppRoutes.login));

      await tester.enterText(find.byType(TextFormField).at(0), '081234567890');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pumpAndSettle();

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Antrean'), findsOneWidget);
    });
  });

  group('Daftar kebutuhan', () {
    testWidgets('menampilkan kartu dan indikator status', (tester) async {
      await tester.pumpWidget(
        const PoskoSyncApp(initialRoute: AppRoutes.requirements),
      );
      await tester.pumpAndSettle();

      expect(find.text('Daftar kebutuhan'), findsOneWidget);
      expect(find.text('Beras'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Tinggi'), findsWidgets);
    });

    testWidgets('form tambah menolak isian kosong', (tester) async {
      await tester.pumpWidget(
        const PoskoSyncApp(initialRoute: AppRoutes.requirementInput),
      );

      await tester.ensureVisible(find.text('Simpan di Perangkat'));
      await tester.pump();
      await tester.tap(find.text('Simpan di Perangkat'));
      await tester.pump();

      expect(find.text('Jenis barang wajib diisi'), findsOneWidget);
      expect(find.text('Jumlah wajib diisi'), findsOneWidget);
      expect(find.text('Pilih tingkat urgensi'), findsOneWidget);
    });
  });
}
