import 'package:agri_shopping/Screens/loadingScreen.dart';
import 'package:agri_shopping/Screens/singleProductScreen.dart';
import 'package:agri_shopping/Widgets/backgroundContainer.dart';
import 'package:agri_shopping/Widgets/mainTopBar.dart';
import 'package:agri_shopping/Widgets/pageTitle.dart';
import 'package:agri_shopping/Widgets/roundedImageContainer.dart';
import 'package:agri_shopping/constants.dart';
import 'package:agri_shopping/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({this.title, this.productQuerySnapshot, this.isTempCollection});
  final bool isTempCollection;
  final String title;
  final QuerySnapshot productQuerySnapshot;
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;

    return BackgroundContainer(
      child: Scaffold(
          appBar: mainTopBar(context, automaticallyImplyLeading: true),
          backgroundColor: transparentColor,
          body: Column(
            children: <Widget>[
              PageTitle(
                title: capitalizeFirstLetters(widget.title),
              ),
              SizedBox(height: _height * .02),
              Expanded(
                child: Container(
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: widget.isTempCollection
                          ? List.generate(
                              widget.productQuerySnapshot.documents.length,
                              (index) {
                              final DocumentReference productDocRef = widget
                                  .productQuerySnapshot
                                  .documents[index]
                                  .data['document_reference'];

                              return FutureBuilder(
                                  future: DatabaseService()
                                      .toDocumentSnapshot(productDocRef),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.connectionState ==
                                            ConnectionState.done) {
                                      final DocumentSnapshot productData =
                                          snapshot.data;
                                      return GestureDetector(
                                        onTap: () {
                                          print(productData.reference.path);
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SingleProduct(
                                                        path: productData
                                                            .reference.path,
                                                        itemData: productData,
                                                      )));
                                        },
                                        child: RoundedImageContainer(
                                          image: productData.data['photo_url'],
                                          itemName: productData.documentID,
                                          imageHeight: .2,
                                          itemPrice: productData.data['mrp'],
                                          itemQuantity:
                                              productData.data['quantity'],
                                        ),
                                      );
                                    } else {
                                      return Loading();
                                    }
                                  });
                            })
                          : List.generate(
                              widget.productQuerySnapshot.documents.length,
                              (index) {
                              var item =
                                  widget.productQuerySnapshot.documents[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SingleProduct(
                                            path:
                                                '${widget.title}/${item.documentID}',
                                            itemData: item,
                                          )));
                                },
                                child: RoundedImageContainer(
                                  image: widget.productQuerySnapshot
                                      .documents[index].data['photo_url'],
                                  itemName: item.documentID,
                                  imageHeight: .19,
                                  itemPrice: item.data['mrp'],
                                  itemQuantity: 'kg',
                                  isNetworkImage: true,
                                ),
                              );
                            })),
                ),
              )
            ],
          )),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;

  CategoryCard(this.name);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 70,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
        ),
      ),
    );
  }
}
