// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Cerrar Sesión elimina el nombre de usuario y navega a LoginForm',
      (WidgetTester tester) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombreDeUsuario', 'usuarioPrueba');

    await tester.pumpWidget(MaterialApp(
      home: InfoMascotaUsuarioScreen(
        usuario: Usuario(nombreUsuario: 'usuarioPrueba'),
        mascota:
            Mascota(nombre: 'NombreDeMascota', raza: 'RazaEjemplo', peso: 10.5),
      ),
    ));

    expect(find.text('Usuario: usuarioPrueba'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();

    expect(prefs.getString('nombreDeUsuario'), isNull);
  });
}
