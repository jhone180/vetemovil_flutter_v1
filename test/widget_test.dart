import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Cerrar Sesión elimina el nombre de usuario',
      (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();

    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombreDeUsuario', 'usuarioPrueba');

    var infoMascotaUsuarioScreen = InfoMascotaUsuarioScreen(
      usuario: Usuario(nombreUsuario: 'usuarioPrueba'),
      mascota:
          Mascota(nombre: 'NombreDeMascota', raza: 'RazaEjemplo', peso: "10.5"),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: infoMascotaUsuarioScreen));
    });

    expect(prefs.getString('nombreDeUsuario'), isNull);
  });
}
