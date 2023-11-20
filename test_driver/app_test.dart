import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Prueba de Despliegue', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Verificar Inicio de Sesión Exitoso', () async {
      await driver.tap(find.byType('TextField'));

      await driver.tap(find.byType('ElevatedButton'));

      await driver.waitFor(find.text('Información de Mascota:'));
      await driver.waitFor(find.text('Nombre: NombreDeMascota'));
      await driver.waitFor(find.text('Raza: RazaEjemplo'));
      await driver.waitFor(find.text('Peso: 10.5 kg'));
      await driver.waitFor(find.text('Usuario: usuario_prueba'));
    });
  });
}
