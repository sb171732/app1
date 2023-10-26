import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/snackbar.dart';
class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  Future<void> resetPasswordinAccount() async {
  
 

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email ?? 'логин');
    SnackBarService.showSnackBar(context, 'Письмо для сброса пароля отправлено', false);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  } catch (e) {
    print(e);
    SnackBarService.showSnackBar(context, 'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.', true);
  }
}

  Future<void> signOut() async {
    final navigator = Navigator.of(context);

    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Аккаунт"), centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text("Почта"),
          subtitle: Text(user!.email ?? 'Анонимус залогинься'),
          trailing: TextButton(onPressed: (){}, child: Text("Изменить")),
        ),
        ListTile(
          title: Text("Имя"),
          subtitle: Text(FirebaseAuth.instance.currentUser?.displayName ?? 'Гость'),
          trailing: TextButton(onPressed: (){}, child: Text("Изменить")),
        ),
        ListTile(
          title: Text("Пароль"),
          trailing: TextButton(onPressed: (){
            resetPasswordinAccount();
          }, child: Text("Изменить")),
        ),
        SizedBox(height: 20), // Пространство между кнопками и кнопкой "Выход"
        Center(
          child: ElevatedButton(
            onPressed: (){signOut();},
            child: Text("Выйти из аккаунта"),
          ),
        ),
      ],
      ),
    );
  }
}