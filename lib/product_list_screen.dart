import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import './product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool _isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Product> products = [];
      for (var item in data) {
        products.add(Product(
          name: item['title'],
          description: item['description'],
          price: item['price'].toDouble(),
        ));
      }

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  void _filterProducts(String query) {
    List<Product> filteredList = _products.where((product) {
      final nameLower = product.name.toLowerCase();
      final queryLower = query.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();

    setState(() {
      _filteredProducts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                labelText: 'Search',
              ),
            ),
          ),
          _isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (ctx, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: _filteredProducts[index],
                                ),
                              ),
                            );
                          },
                          title: Text(_filteredProducts[index].name),
                          subtitle: Text(
                              'Price: \$${_filteredProducts[index].price.toStringAsFixed(2)}'),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
