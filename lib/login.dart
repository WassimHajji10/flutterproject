import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signup.dart';
import'todo.dart';
import 'resetmps.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return 'Veuillez entrer une adresse email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(input)) {
                        return 'Adresse email invalide';
                      }
                      return null;
                    },
                    onSaved: (input) => _email = input!,
                  ),

                  TextFormField(
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                    validator: (input) {
                      if (input == null || input.isEmpty || input.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                    onSaved: (input) => _password = input!,
                  ),

                  _isLoading
                      ? Center(
                    child: CircularProgressIndicator(),
                  )
                      : ElevatedButton(
                    child: Text("Se connecter"),
                    onPressed: _submit,
                  ),
                  TextButton(
                    child: Text("S'inscrire"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    ),

                  ),
                  TextButton(
                    child : Text("Mot de passe oublié"),
                    onPressed: ()=>Navigator.push(
                      context,
                    MaterialPageRoute(builder:(context)=>ResetPasswordPage()),
                  ),
                  ),
                  _errorMessage.isNotEmpty
                      ? Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      setState(() {
        _isLoading = true;
      });
      formState.save();
      try {
        UserCredential user = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        setState(() {
          _isLoading = false;

        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => todo()),
        );
      } on FirebaseAuthException catch (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.message ?? 'Une erreur est survenue';
        });
      } catch (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Une erreur est survenue';
        });
      }
    }
  }
}
