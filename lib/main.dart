import 'package:flutter/material.dart';
import '../models/transaction.dart';

void main() {
  runApp(MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store transactions
  List<Transaction> _transactions = [];

  // Form controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // State for transaction type
  bool _isExpense = true;

  // Method to add a new transaction
  void _addTransaction() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0) return;

    final newTransaction = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      isExpense: _isExpense,
    );

    setState(() {
      _transactions.add(newTransaction);
      _titleController.clear();
      _amountController.clear();
      _isExpense = true;
    });
  }

  //Calculator
  double get _totalBalance {
    return _transactions.fold(0.0, (sum, transaction) {
      return transaction.isExpense
          ? sum - transaction.amount
          : sum + transaction.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Money Tracker')),
      body: Column(
        children: [
          // Balance Display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Balance: \$${_totalBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _totalBalance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),

          // Transaction Input Form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Transaction Type Selector
                Row(
                  children: [
                    Text('Transaction Type:'),
                    Radio<bool>(
                      value: true,
                      groupValue: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value!;
                        });
                      },
                    ),
                    Text('Expense'),
                    Radio<bool>(
                      value: false,
                      groupValue: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value!;
                        });
                      },
                    ),
                    Text('Income'),
                  ],
                ),

                // Title TextField
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),

                // Amount TextField
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),

                // Add Transaction Button
                ElevatedButton(
                  onPressed: _addTransaction,
                  child: Text('Add Transaction'),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(transaction.isExpense ? 'Expense' : 'Income'),
                  trailing: Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isExpense ? Colors.red : Colors.green,
                    ),
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
