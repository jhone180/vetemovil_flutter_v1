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
    // Crea una instancia de SharedPreferences y guarda un nombre de usuario
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombreDeUsuario', 'usuarioPrueba');

    // Crea una instancia de Key para LoginForm para poder encontrar el widget
    var loginFormKey = Key('loginFormKey');
    // Construye la pantalla de InfoMascotaUsuarioScreen
    await tester.pumpWidget(MaterialApp(
      home: InfoMascotaUsuarioScreen(
        usuario: Usuario(nombreUsuario: 'usuarioPrueba'),
        mascota:
            Mascota(nombre: 'NombreDeMascota', raza: 'RazaEjemplo', peso: 10.5),
      ),
    ));

    // Verifica que el nombre de usuario esté presente en la pantalla
    expect(find.text('Usuario: usuarioPrueba'), findsOneWidget);

    // Act: Toca el botón para cerrar sesión
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Espera a que se completen las animaciones y las tareas asincrónicas
    await tester.pumpAndSettle();

    // Verifica que el nombre de usuario se haya eliminado de las preferencias compartidas
    expect(prefs.getString('nombreDeUsuario'), isNull);

    // Verifica que se haya navegado a LoginForm
    expect(find.byKey(loginFormKey), findsOneWidget);
  });
}
