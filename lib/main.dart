import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const FoodOrderPage(),
    );
  }
}

// Simple Food Item model
class FoodItem {
  final String name;
  final String category;
  final double price;
  final IconData icon;

  const FoodItem({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
  });
}

class FoodOrderPage extends StatefulWidget {
  const FoodOrderPage({super.key});

  @override
  State<FoodOrderPage> createState() => _FoodOrderPageState();
}

class _FoodOrderPageState extends State<FoodOrderPage> {
  // Current tab index (0 = Menu, 1 = Cart)
  int _selectedTabIndex = 0;

  // List of available food items
  final List<FoodItem> _foodList = const [
    FoodItem(
      name: 'Burger',
      category: 'Fast Food',
      price: 5.99,
      icon: Icons.lunch_dining,
    ),
    FoodItem(
      name: 'Pizza',
      category: 'Italian',
      price: 8.99,
      icon: Icons.local_pizza,
    ),
    FoodItem(
      name: 'French Fries',
      category: 'Snacks',
      price: 2.99,
      icon: Icons.fastfood,
    ),
    FoodItem(
      name: 'Cold Drink',
      category: 'Drinks',
      price: 1.49,
      icon: Icons.local_drink,
    ),
    FoodItem(
      name: 'Sandwich',
      category: 'Breakfast',
      price: 4.50,
      icon: Icons.bakery_dining,
    ),
    FoodItem(
      name: 'Ice Cream',
      category: 'Dessert',
      price: 3.00,
      icon: Icons.icecream,
    ),
  ];

  // Cart storage: maps each FoodItem to its quantity
  final Map<FoodItem, int> _cart = {};

  // Add item to cart
  void _addToCart(FoodItem item) {
    setState(() {
      if (_cart.containsKey(item)) {
        _cart[item] = _cart[item]! + 1;
      } else {
        _cart[item] = 1;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Remove or decrease item in cart
  void _removeFromCart(FoodItem item) {
    setState(() {
      if (_cart.containsKey(item)) {
        if (_cart[item]! > 1) {
          _cart[item] = _cart[item]! - 1;
        } else {
          _cart.remove(item);
        }
      }
    });
  }

  // Calculate total price
  double _calculateTotal() {
    double total = 0.0;
    _cart.forEach((item, quantity) {
      total += item.price * quantity;
    });
    return total;
  }

  // Calculate total count of items in cart
  int _getTotalCount() {
    int count = 0;
    _cart.forEach((_, qty) {
      count += qty;
    });
    return count;
  }

  // Place order function
  void _placeOrder() {
    if (_cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Placed Successfully!'),
          content: Text(
            'Thank you for ordering!\nTotal Amount: \$${_calculateTotal().toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _cart.clear();
                  _selectedTabIndex = 0;
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedTabIndex == 0 ? 'Food Menu' : 'My Cart'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _selectedTabIndex == 0 ? _buildMenuTab() : _buildCartTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (int index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: 'Cart (${_getTotalCount()})',
          ),
        ],
      ),
    );
  }

  // Menu tab: displays the list of foods
  Widget _buildMenuTab() {
    return ListView.builder(
      itemCount: _foodList.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final item = _foodList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange.shade100,
              child: Icon(item.icon, color: Colors.deepOrange),
            ),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.category} • \$${item.price.toStringAsFixed(2)}',
            ),
            trailing: ElevatedButton(
              onPressed: () => _addToCart(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ),
        );
      },
    );
  }

  // Cart tab: displays items in cart and total
  Widget _buildCartTab() {
    if (_cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedTabIndex = 0;
                });
              },
              child: const Text('Go to Menu'),
            ),
          ],
        ),
      );
    }

    final items = _cart.keys.toList();

    return Column(
      children: [
        // List of cart items
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final item = items[index];
              final qty = _cart[item]!;
              final itemTotal = item.price * qty;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade100,
                    child: Icon(item.icon, color: Colors.deepOrange),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '\$${item.price.toStringAsFixed(2)} x $qty = \$${itemTotal.toStringAsFixed(2)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeFromCart(item),
                      ),
                      Text(
                        '$qty',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _addToCart(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Cart summary and place order button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepOrange.shade50,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${_calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
