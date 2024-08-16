import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = 'pk_test_51Po7xr03iCQ8JLpxiTYvxVfk5jMzwZbL3fIeD2dzBULmrisx0my7NgcynAWErqnvhO8LUQdx0mWjhwe59tCE7Wyb00gwC2eH4z';

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => CartModel(),
        child: ProductPage(),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Product Name",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Product Description",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "\$100.00",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<CartModel>().addToCart(1000);  // amount in cents
                },
                child: Text("Add to Cart"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Step 1: Create Payment Intent on the server
                  String clientSecret = await createPaymentIntent(10000);

                  // Step 2: Initialize payment sheet
                  await initPaymentSheet(clientSecret);

                  // Step 3: Present payment sheet
                  await presentPaymentSheet(context);
                },
                child: Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> createPaymentIntent(int amount) async {
    final url = 'http://192.168.2.102:3000/create-payment-intent'; //you can try localhost or your ip address
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode({'amount': amount}),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    return data['clientSecret'];
  }

  Future<void> initPaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your Company',
          // Optional parameters
          style: ThemeMode.system,
          // testEnv: true,
        ),
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
    }
  }

  Future<void> presentPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful")),
      );
    } catch (e) {
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Canceled: ${e.error.localizedMessage}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed: $e")),
        );
      }
    }
  }
}

class CartModel extends ChangeNotifier {
  int _amount = 0;

  int get amount => _amount;

  void addToCart(int amount) {
    _amount += amount;
    notifyListeners();
  }
}
