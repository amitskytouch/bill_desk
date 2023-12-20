import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/FirebaseServices/login_service.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/custom_Button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AppLocalizations? language = AppLocalizations.of(context);
    var height = MediaQuery.of(context).viewPadding.top;
    var bottomHeight = MediaQuery.of(context).viewPadding.bottom;
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: purpleColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height - height - bottomHeight,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      "assets/images/Vector Smart Object-1.png",
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding:
                          const EdgeInsets.only(left: 30, right: 30, top: 50),
                      decoration: const BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              hint: "${language?.email}",
                              controller: emailController,
                              keyBoardType: TextInputType.emailAddress,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${language?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              hint: "${language?.password}",
                              controller: passwordController,
                              validator: (String? value) {
                                if (value!.isEmpty || value == "") {
                                  return "${language?.validator}";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(height: 80),
                            CustomButton(
                              text: "${language?.logIn}",
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  LoginService.loginUser(
                                    context,
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
