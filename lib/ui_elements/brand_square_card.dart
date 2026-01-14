import 'package:flutter/material.dart';

import '../custom/box_decorations.dart';
import '../my_theme.dart';
import '../screens/brand_products.dart';

class BrandSquareCard extends StatefulWidget {
  final int? id;
  final String slug;
  final String? image;
  final String? name;

  const BrandSquareCard({
    super.key,
    this.id,
    this.image,
    required this.slug,
    this.name,
  });

  @override
  State<BrandSquareCard> createState() => _BrandSquareCardState();
}

class _BrandSquareCardState extends State<BrandSquareCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BrandProducts(slug: widget.slug);
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecorations.buildBoxDecoration_1(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 1,
              //height: 60,
              //width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                  bottom: Radius.zero,
                ),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.png',
                  image: widget.image!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  widget.name!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
