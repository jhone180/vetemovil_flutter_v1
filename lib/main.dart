import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa el paquete http
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart'; // Importa el paquete bcrypt
import 'package:crypto/crypto.dart'; // Importa el paquete crypto

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          title: Text('Inicio de Sesión'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LoginForm(),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _usuarioController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    // Realiza la solicitud GET a la API para validar el inicio de sesión
    final response = await http.get(Uri.parse(
        'https://vetemovil.000webhostapp.com/usuario/consultarUsuario/$usuario'));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String usuarioAPI = data['nombre'];
      String contrasenaHashAPI = data['contrasena'];
      if (usuario == usuarioAPI &&
          BCrypt.checkpw(contrasena, contrasenaHashAPI)) {
        return true;
      } else {
        _mostrarMensajeError(context);
        // Las credenciales son incorrectas
        return false;
      }
      print(data['nombre']);
    } else {
      _mostrarMensajeError(context);
      // Si la solicitud no es exitosa, puedes manejar el error según sea necesario
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Inicio Sesión',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _usuarioController,
          decoration: InputDecoration(
            hintText: 'Nombre de usuario',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _contrasenaController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Llama a la función para iniciar sesión cuando se presiona el botón
            _iniciarSesion();
          },
          child: Text('Ingresar'),
        ),
        SizedBox(height: 10),
        _isLoading ? CircularProgressIndicator() : Container(),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Navegar a la pantalla de registro cuando se toca el texto "Registrar Usuario"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistroUsuarioScreen()),
            );
          },
          child: Text(
            'Registrar Usuario',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _mostrarMensajeError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(
              'Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el AlertDialog
              },
            ),
          ],
        );
      },
    );
  }
}

class RegistroUsuarioScreen extends StatefulWidget {
  @override
  _RegistroUsuarioScreenState createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  TextEditingController _usuarioController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();
  bool _registroExitoso = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: Center(
        child: _registroExitoso
            ? _buildAnimacionRegistroExitoso()
            : _buildFormularioRegistro(context),
      ),
    );
  }

  Widget _buildAnimacionRegistroExitoso() {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          SizedBox(height: 20),
          Text(
            'Registro exitoso!',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarUsuario(BuildContext context) async {
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;
    String hash = BCrypt.hashpw(contrasena, BCrypt.gensalt());
    // Prepara los datos del usuario para enviar a la API
    Map<String, String> datosUsuario = {
      'nombre': usuario,
      'contrasena': hash,
    };

    String jsonData = jsonEncode(datosUsuario);

    final response = await http.post(
      Uri.parse('https://vetemovil.000webhostapp.com/usuario/registrar'),
      headers: {
        'Content-Type':
            'application/json', // Indica que el cuerpo de la solicitud es JSON
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      setState(() {
        _registroExitoso = true;
      });

      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registro exitoso'),
      ));
    } else {
      // Fallo en el registro, puedes manejar la respuesta según lo necesario
      // Por ejemplo, mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error en el registro. Por favor, inténtalo de nuevo.'),
      ));
    }
  }

  @override
  Widget _buildFormularioRegistro(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Acción cuando se presiona el botón de registro
                  // Puedes obtener los datos ingresados por el usuario así:

                  _registrarUsuario(context);

                  // Aquí puedes manejar la lógica de registro del usuario
                  // Por ejemplo, enviar los datos a un servidor, guardar en una base de datos, etc.
                },
                child: Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
