import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Utils/exit_dialog.dart';
import 'package:bill_desk/Views/customer_screen.dart';
import 'package:bill_desk/Views/home_screen.dart';
import 'package:bill_desk/Views/product_screen.dart';
import 'package:bill_desk/Views/report_screen.dart';
import 'package:bill_desk/Views/setting_screen.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int selectedIndex = 0;
  List navBarScreens = [
    HomeScreen(),
    const ReportScreen(),
    ProductScreen(),
    CustomerScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    appLocale = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        await exitDialog(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: Container(
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              border: Border.all(color: purpleColor),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: BottomNavigationBar(
                backgroundColor: whiteColor,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: purpleColor,
                unselectedItemColor: greyColor,
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: SvgPicture.asset(
                        "assets/images/Vector.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 0 ? purpleColor : blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                    label: "${appLocale?.home}",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: SvgPicture.asset(
                        "assets/images/reports.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 1 ? purpleColor : blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                    label: "${appLocale?.reports}",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: SvgPicture.asset(
                        "assets/images/product.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 2 ? purpleColor : blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                    label: "${appLocale?.products}",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: SvgPicture.asset(
                        "assets/images/customer.svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 3 ? purpleColor : blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                    label: "${appLocale?.customer}",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: SvgPicture.asset(
                        "assets/images/Vector (1).svg",
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                            selectedIndex == 4 ? purpleColor : blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                    label: "${appLocale?.setting}",
                  ),
                ],
                currentIndex: selectedIndex,
                onTap: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          ),
          body: navBarScreens.elementAt(selectedIndex),
        ),
      ),
    );
  }
}
