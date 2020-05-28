import 'package:flutter/material.dart';

import '../screens/product/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imgUrl;
  final Function deleteItem;

  UserProductItem({
    @required this.id,
    @required this.title,
    @required this.imgUrl,
    @required this.deleteItem,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(backgroundImage: NetworkImage(imgUrl)),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () => Navigator.of(context).pushNamed(
                EditProductScreen.ROUTE_NAME,
                arguments: id,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                try {
                  await deleteItem(id);
                } catch (error) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text(
                      'Deleting failes!',
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
