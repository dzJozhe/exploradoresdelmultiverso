import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rickandmorty/core/providers.dart';

class VerificationView extends ConsumerStatefulWidget {
  final String? phoneNumer;
  String? verificationCode;

  VerificationView({super.key, this.phoneNumer, this.verificationCode});

  @override
  ConsumerState<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends ConsumerState<VerificationView> {
  final codeNumber1 = TextEditingController();
  final codeNumber2 = TextEditingController();
  final codeNumber3 = TextEditingController();
  final codeNumber4 = TextEditingController();
  final codeNumber5 = TextEditingController();
  final codeNumber6 = TextEditingController();

  final textControllerCode = TextEditingController();

  List<TextEditingController> listControllers = [];

  void initListControllersCode() {
    listControllers = [
      codeNumber1,
      codeNumber2,
      codeNumber3,
      codeNumber4,
      codeNumber5,
      codeNumber6,
    ];
  }

  @override
  void initState() {
    super.initState();
    initListControllersCode();
    viewCode(widget.verificationCode);
  }

  @override
  void dispose() {
    disposeTextControllers();
    super.dispose();
  }

  void disposeTextControllers() {
    for (int i = 0; i < 6; i++) {
      listControllers[i].dispose();
    }
  }

  void viewCode(String? verificationCode) {
    final code = verificationCode ?? '';
    final caracteresCode = code.split('');
    if (caracteresCode.isNotEmpty) {
      for (int i = 0; i < 6; i++) {
        listControllers[i].text = '';
        listControllers[i].text = caracteresCode[i];
      }
    }
  }

  Future<void> _newCode() async {
    final phone = widget.phoneNumer ?? '';
    final newCode = await ref
        .read(authViewModelProvider.notifier)
        .enviarTelefono(phone);

    widget.verificationCode = newCode['code'];
    viewCode(newCode['code']);
  }

  Future<void> _verificationCode() async {
    final isValidCode = await ref
        .read(authViewModelProvider.notifier)
        .verifyCode(
          widget.verificationCode!,
          textControllerCode.text,
          widget.phoneNumer!,
        );

    print(widget.verificationCode);
    print(textControllerCode.text);
    //if(isValidCode){
    print(isValidCode);
    // }

    if (isValidCode && mounted) {
      context.go('/characters');
    }
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
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: IconButton(
                    onPressed: () {
                      if (widget.verificationCode == null) {
                        widget.verificationCode == '';
                        print(widget.verificationCode);
                      } else {
                        print(widget.verificationCode);
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                textAlign: TextAlign.left,
                'Verifica tu numero ',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                textAlign: TextAlign.left,
                'Escribe el codigo de 6 dgitos enviado a +52 ${widget.phoneNumer!}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Text(
                textAlign: TextAlign.left,
                'Codigo',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber1,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber2,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber3,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber4,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber5,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: codeNumber6,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        fillColor: Color.fromARGB(103, 6, 6, 6),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        //label: Text('7773523584'),
                        //labelStyle: TextStyle(color: Colors.grey),
                        //hint: Text('0', style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextFormField(
                controller: textControllerCode,
                focusNode: FocusNode(),
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
                  hint: Text('536486', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.lightGreen,
                ),
                onPressed: _verificationCode,
                child: Text(
                  'Verificar y entrar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 45),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: GestureDetector(
                onTap: _newCode,
                child: Text(
                  'Reenviar codigo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
