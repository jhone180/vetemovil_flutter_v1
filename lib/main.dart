import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.orangeAccent,
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

class Mascota {
  String nombre;
  String raza;
  String peso;

  Mascota({required this.nombre, required this.raza, required this.peso});
}

class Usuario {
  String nombreUsuario;

  Usuario({required this.nombreUsuario});
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _usuarioController = TextEditingController();
  TextEditingController _contrasenaController = TextEditingController();
  bool _isLoading = false;
  String usuarioAPI = "";

  Future<bool> _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    final response = await http.get(Uri.parse(
        'https://vetemovil.000webhostapp.com/usuario/consultarUsuario/$usuario'));

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String idUsuario = data['id'];
      usuarioAPI = data['nombre'];
      final responseMascota = await http.get(Uri.parse(
          'https://vetemovil.000webhostapp.com/mascotas/consultarMascota/$idUsuario'));
      Map<String, dynamic> dataMascota = json.decode(responseMascota.body);
      String contrasenaHashAPI = data['contrasena'];
      if (usuario == usuarioAPI &&
          BCrypt.checkpw(contrasena, contrasenaHashAPI)) {
        Usuario usuario = Usuario(nombreUsuario: usuarioAPI);
        Mascota mascota = Mascota(
            nombre: dataMascota['nombre'],
            raza: dataMascota['raza'],
            peso: dataMascota['peso']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                InfoMascotaUsuarioScreen(usuario: usuario, mascota: mascota),
          ),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('nombreDeUsuario', usuarioAPI);
        return true;
      } else {
        _mostrarMensajeError(context);

        return false;
      }
      print(data['nombre']);
    } else {
      _mostrarMensajeError(context);

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.orangeAccent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Center(
            child: Text(
              'Vetemovil',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                    _iniciarSesion();
                  },
                  child: Text('Ingresar'),
                ),
                SizedBox(height: 10),
                _isLoading ? CircularProgressIndicator() : Container(),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistroUsuarioScreen()),
                    );
                  },
                  child: Text(
                    'Registrar Usuario',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    bool sesionIniciada = await _obtenerSesionIniciada();

    if (sesionIniciada) {
      String? nombreUsuarioNulo = await _obtenerUsuarioSesionIniciada();
      String nombreUsuario = nombreUsuarioNulo ?? '';
      Usuario usuario = Usuario(nombreUsuario: nombreUsuario);
      Mascota mascota =
          Mascota(nombre: 'NombreDeMascota', raza: 'RazaEjemplo', peso: "10.5");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              InfoMascotaUsuarioScreen(usuario: usuario, mascota: mascota),
        ),
      );
    }
  }

  Future<bool> _obtenerSesionIniciada() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreDeUsuario = prefs.getString('nombreDeUsuario');
    return nombreDeUsuario != null;
  }

  Future<String?> _obtenerUsuarioSesionIniciada() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreDeUsuario = prefs.getString('nombreDeUsuario');
    return nombreDeUsuario;
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

    Map<String, String> datosUsuario = {
      'nombre': usuario,
      'contrasena': hash,
    };

    String jsonData = jsonEncode(datosUsuario);

    final response = await http.post(
      Uri.parse('https://vetemovil.000webhostapp.com/usuario/registrar'),
      headers: {
        'Content-Type': 'application/json',
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error en el registro. Por favor, inténtalo de nuevo.'),
      ));
    }
  }

  @override
  Widget _buildFormularioRegistro(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Nombre de usuario',
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
                  labelText: 'Contraseña',
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
                  _registrarUsuario(context);
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

class InfoMascotaUsuarioScreen extends StatelessWidget {
  final Usuario usuario;
  final Mascota mascota;

  InfoMascotaUsuarioScreen({required this.usuario, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de Mascota y Usuario',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: <Widget>[
          // Positioned.fill(
          //   child: Image(image: AssetImage("assets/negro.jpg")),
          // ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Información de Mascota:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                Text('Nombre: ${mascota.nombre}',
                    style: TextStyle(fontSize: 18, color: Colors.orange)),
                Text('Raza: ${mascota.raza}',
                    style: TextStyle(fontSize: 18, color: Colors.orange)),
                Text('Peso: ${mascota.peso} kg',
                    style: TextStyle(fontSize: 18, color: Colors.orange)),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Usuario: ${usuario.nombreUsuario}',
                  style: TextStyle(fontSize: 18, color: Colors.orange)),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {
                  _cerrarSesion(context);
                },
                tooltip: 'Cerrar Sesión',
                backgroundColor: Colors.orange,
                child: Icon(Icons.logout),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('nombreDeUsuario');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }

  Future<void> cerrarSesionPrueba() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nombreDeUsuario');
  }
}
