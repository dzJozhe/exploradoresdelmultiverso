import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final TextEditingController _numerPhoneController = TextEditingController();

  @override
  void dispose() {
    _numerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.topCenter,
            end: AlignmentGeometry.bottomCenter,
            colors: [Color(0xFF0b132b), Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Icon(Icons.rocket, color: Colors.lightGreen, size: 50),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Exploradores del',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Multiverso',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Ingresa tu numero de celular para abrir tu espacio de trabajo',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Text(
                'Numero de celular',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                children: [
                  Text('+52', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _numerPhoneController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        hint: Text(
                          '7773523584',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  'Te enviaremos un codigo de verificacion de 6 digitos',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.lightGreen,
                ),
                onPressed: _onContinue,
                child: Text(
                  'Continuar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();

    final response = await ref
        .read(authViewModelProvider.notifier)
        .enviarTelefono(_numerPhoneController.text);

    final ok = response['code'] != null ? true : false;

    // Después de un `await`, hay que comprobar que la pantalla siga viva.
    if (ok && mounted) {
      context.go(
        '/verify',
        extra: (phone: response['phone'], code: response['code']),
      );
    }
  }
}
