import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const ROUTE_NAME = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  var _tempProduct = {
    'id': '',
    'title': '',
    'description': '',
    'imageUrl': '',
    'price': 0.0,
    'isFavourite': false,
  };

  @override
  void initState() {
    _imageUrlController.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final product = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId);
        _tempProduct['id'] = product.id;
        _tempProduct['title'] = product.title;
        _tempProduct['price'] = product.price;
        _tempProduct['description'] = product.description;
        _tempProduct['imageUrl'] = product.imageUrl;
        _tempProduct['isFavourite'] = product.isFavourite;
        _imageUrlController.text = _tempProduct['imageUrl'];
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (isValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true;
      });
      if (_tempProduct['id'].toString().isEmpty) {
        var product = ProductProvider(
          id: DateTime.now().toString(),
          title: _tempProduct['title'],
          price: _tempProduct['price'],
          imageUrl: _tempProduct['imageUrl'],
          description: _tempProduct['description'],
          isFavourite: _tempProduct['isFavourite'],
          authToken: Provider.of<ProductsProvider>(context, listen: false).authToken,
          userId: Provider.of<ProductsProvider>(context, listen: false).userId,
        );
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .addProduct(product);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('An error occured!'),
              content: Text('Something went wrong.'),
              actions: [
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ),
          );
        }
      } else {
        var product = ProductProvider(
          id: _tempProduct['id'],
          title: _tempProduct['title'],
          price: _tempProduct['price'],
          description: _tempProduct['description'],
          imageUrl: _tempProduct['imageUrl'],
          isFavourite: _tempProduct['isFavourite'],
          authToken: Provider.of<ProductsProvider>(context, listen: false).authToken,
          userId: Provider.of<ProductsProvider>(context, listen: false).userId,
        );
        try {
          await Provider.of<ProductsProvider>(context, listen: false)
              .updateProduct(product);
        } catch (error) {
          print(error);
        }
      }
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        textInputAction: TextInputAction.next,
                        initialValue: _tempProduct['title'],
                        onFieldSubmitted: (value) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        onSaved: (value) => _tempProduct['title'] = value,
                        validator: (value) {
                          if (value.isNotEmpty) {
                            return null;
                          }
                          return 'You should provide a title';
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        initialValue: _tempProduct['price'].toString(),
                        onFieldSubmitted: (value) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                        onSaved: (value) =>
                            _tempProduct['price'] = double.parse(value),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a price.';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) < 0) {
                            return 'Please enter a number greater or equal 0';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        initialValue: _tempProduct['description'],
                        onSaved: (value) => _tempProduct['description'] = value,
                        validator: (value) {
                          if (value.isNotEmpty) {
                            return null;
                          }
                          return 'You should provide a description';
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocusNode,
                              controller: _imageUrlController,
                              onSaved: (value) =>
                                  _tempProduct['imageUrl'] = value,
                              onFieldSubmitted: (_) => _saveForm,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide a image URL';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid url';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter a valid url to image';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
