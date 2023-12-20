import 'package:bill_desk/Constants/color_const.dart';
import 'package:bill_desk/Constants/textstyle_const.dart';
import 'package:bill_desk/FirebaseServices/product_services.dart';
import 'package:bill_desk/Models/category_model.dart';
import 'package:bill_desk/Providers/image_upload_provider.dart';
import 'package:bill_desk/Widgets/custom_textfield.dart';
import 'package:bill_desk/Widgets/theme_button.dart';
import 'package:bill_desk/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CategoryDetailScreen extends StatefulWidget {
  final CategoryModel category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
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
          return Consumer<ImageUploadProvider>(
              builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.8,
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
                            // DropdownButtonHideUnderline(
                            //   child: DropdownButton2<String>(
                            //     items: provider.categoryList.map((e) {
                            //       return DropdownMenuItem<String>(
                            //         value: e.category,
                            //         child: Text(e.category.toString()),
                            //       );
                            //     }).toList(),
                            //     hint: Text(
                            //       provider.selectedCategory ??
                            //           widget.category.category.toString(),
                            //     ),
                            //     onChanged: (value) {
                            //       provider.changeCategory(value.toString());
                            //       provider.filterCategory();
                            //       log("${provider.selectedCategory}");
                            //     },
                            //     buttonStyleData: ButtonStyleData(
                            //       elevation: 0,
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 10),
                            //       width: MediaQuery.of(context).size.width,
                            //       decoration: BoxDecoration(
                            //         border: Border.all(color: purpleColor),
                            //         borderRadius: BorderRadius.circular(5),
                            //       ),
                            //     ),
                            //     dropdownSearchData: DropdownSearchData(
                            //       searchController: categoryController,
                            //       searchMatchFn: (a, searchValue) {
                            //         return a.value
                            //             .toString()
                            //             .toLowerCase()
                            //             .contains(searchValue);
                            //       },
                            //       searchInnerWidgetHeight: 40,
                            //       searchInnerWidget: Padding(
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: TextFormField(
                            //           controller: categoryController,
                            //           decoration: const InputDecoration(
                            //               hintText: "Search here..."),
                            //         ),
                            //       ),
                            //     ),
                            //     onMenuStateChange: (isOpen) {
                            //       if (!isOpen) {
                            //         categoryController.clear();
                            //       }
                            //     },
                            //   ),
                            // ),

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
                              image:
                                  "assets/images/noun-add-product-2675922 1.svg",
                              text: "${appLocale?.save}",
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  provider.editCategory(
                                    docId: widget.category.id.toString(),
                                    oldCategory:
                                        widget.category.category.toString(),
                                    newCategory: categoryController.text,
                                    ctx: context,
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          });
        });
  }

  openDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
              "${appLocale?.areYouSure}",
              style: customTextStyle(
                  size: 18, color: purpleColor, fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ProductServices().deleteCategory(
                    docId: widget.category.id.toString(),
                    category: widget.category.category.toString(),
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "${appLocale?.yes}",
                  style: customTextStyle(
                      size: 18, color: blackColor, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "${appLocale?.no}",
                  style: customTextStyle(
                      size: 18, color: blackColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        });
  }

  @override
  void initState() {
    categoryController.text = "${widget.category.category}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("${appLocale?.categoryDetail}"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "button1",
            backgroundColor: purpleColor,
            elevation: 0,
            onPressed: () => _openBottomSheet(context),
            child: SvgPicture.asset(
              "assets/images/noun-edit-4528904 1.svg",
              width: 25,
              height: 25,
            ),
          ),
          FloatingActionButton(
            heroTag: "button2",
            backgroundColor: purpleColor,
            elevation: 0,
            onPressed: () {
              openDeleteDialog(context);
            },
            child: SvgPicture.asset(
              "assets/images/noun-delete-4778235 1.svg",
              width: 25,
              height: 25,
            ),
          ),
        ],
      ),
      body: Consumer<ImageUploadProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  "assets/images/search.png",
                  width: 100,
                  height: 100,
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: purpleColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${appLocale?.categoryName} : ",
                        style: customTextStyle(
                          size: 17,
                          fontWeight: FontWeight.w600,
                          color: purpleColor,
                        ),
                      ),
                      TextSpan(
                        text: categoryController.text,
                        style: customTextStyle(
                          size: 17,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
