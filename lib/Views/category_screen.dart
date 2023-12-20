import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Providers/category_provider.dart';
import 'package:bill_desk/Utils/global_handler.dart';
import 'package:bill_desk/Views/category_detail_screen.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _openBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.97),
      isScrollControlled: true,
      useSafeArea: true,
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      context: ctx,
      builder: (context) {
        return Consumer<CategoryProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.7,
                  maxChildSize: 0.9,
                  builder: (_, scrollController) {
                    return GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Container(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 30),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            shrinkWrap: true,
                            controller: scrollController,
                            children: [
                              const SizedBox(height: 10),
                              CustomTextField(
                                hint: "${appLocale?.category}",
                                controller: categoryController,
                                validator: (String? value) {
                                  if (value!.isEmpty || value == "") {
                                    return "${appLocale?.validator}";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(height: 60),
                              ThemeButton(
                                image: "assets/images/searchsvg.svg",
                                text: "${appLocale?.addCategory}",
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    provider.addCategory(
                                      ctx: context,
                                      category: categoryController.text.trim(),
                                    );
                                    Navigator.pop(context);
                                  }
                                  categoryController.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${appLocale?.category}"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: purpleColor,
        elevation: 0,
        onPressed: () => _openBottomSheet(context),
        child: SvgPicture.asset(
          "assets/images/noun-add-5852019 1.svg",
          width: 33,
          height: 33,
        ),
      ),
      body: Consumer<CategoryProvider>(builder: (context, provider, _) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("category")
                .orderBy("category", descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.data!.docs.isEmpty) {
                return Center(
                    child: Text(
                  "No Data Found...",
                  style: customTextStyle(
                      size: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ));
              } else {
                QuerySnapshot data = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    CategoryModel category = CategoryModel.fromMap(
                        data.docs[index].data() as Map<String, dynamic>);

                    return Card(
                      margin: const EdgeInsets.only(top: 10),
                      elevation: 1,
                      shape: OutlineInputBorder(
                        borderSide: const BorderSide(color: purpleColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset(
                            "assets/images/search.png",
                            width: 40,
                            height: 40,
                          ),
                        ),
                        title: Text(
                          "${category.category}",
                          overflow: TextOverflow.ellipsis,
                          style: customTextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder(
                                future: provider.getCategoryviseProduct(
                                    category.category.toString()),
                                builder: (context, snap) {
                                  if (snap.hasData) {
                                    return Text(
                                      "Products : ${snap.data}",
                                      style: customTextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: purpleColor,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () {
                          navigatorPush(
                              context,
                              CategoryDetailScreen(
                                category: category,
                              ));
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      }),
    );
  }
}
