import 'package:flutter/material.dart';
import './models/transaction.dart';

void main() {
  runApp(MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hitung Duit',
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
  List<Transaction> transactions = [];

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  bool isExpenseTransaction = true;

  Transaction? currentEditTransaction;

  //update transaction method
  void saveTransaction() {
    final transactionTitle = titleController.text;
    final transactionAmount = double.tryParse(amountController.text) ?? 0.0;

    if (transactionTitle.isEmpty || transactionAmount <= 0) return;

    if (currentEditTransaction != null) {
      //update transaction yg udh ada
      setState(() {
        transactions[transactions.indexWhere(
          (t) => t.id == currentEditTransaction!.id,
        )] = Transaction(
          id: currentEditTransaction!.id,
          title: transactionTitle,
          amount: transactionAmount,
          date: DateTime.now(),
          isExpense: isExpenseTransaction,
        );

        currentEditTransaction = null;
      });
    } else {
      //Tambah transaksi
      final newTransaction = Transaction(
        id: DateTime.now().toString(),
        title: transactionTitle,
        amount: transactionAmount,
        date: DateTime.now(),
        isExpense: isExpenseTransaction,
      );

      setState(() {
        transactions.add(newTransaction);
      });
    }

    // Reset controller sama state
    titleController.clear();
    amountController.clear();
    isExpenseTransaction = true;
  }

  // Method buat edit transaksi
  void editTransaction(Transaction transaction) {
    setState(() {
      currentEditTransaction = transaction;
      titleController.text = transaction.title;
      amountController.text = transaction.amount.toString();
      isExpenseTransaction = transaction.isExpense;
    });
  }

  //Method delet transaski
  void deleteTransaction(Transaction transaction) {
    setState(() {
      transactions.removeWhere((t) => t.id == transaction.id);
    });
  }

  // Calculator
  double calcTotalBalance() {
    return transactions.fold(0.0, (sum, transaction) {
      return transaction.isExpense
          ? sum - transaction.amount
          : sum + transaction.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hitung Duit')),
      body: Column(
        children: [
          //Balance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Saldo: Rp ${calcTotalBalance()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: calcTotalBalance() >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),

          // Textfield transaski
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Selector
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isExpenseTransaction,
                      onChanged: (value) {
                        setState(() {
                          isExpenseTransaction = value!;
                        });
                      },
                    ),
                    Text('Pengeluaran'),
                    Radio<bool>(
                      value: false,
                      groupValue: isExpenseTransaction,
                      onChanged: (value) {
                        setState(() {
                          isExpenseTransaction = value!;
                        });
                      },
                    ),
                    Text('Pemasukan'),
                  ],
                ),

                // Title TextField
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText:
                        currentEditTransaction != null ? 'Ubah Judul' : 'Judul',
                  ),
                ),

                // Amount TextField
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        currentEditTransaction != null
                            ? 'Ubah Jumlah'
                            : 'Jumlah',
                  ),
                ),

                // Add/Update Transaction Button
                ElevatedButton(
                  onPressed: saveTransaction,
                  child: Text(
                    currentEditTransaction != null
                        ? 'Perbarui Transaksi'
                        : 'Tambah Transaksi',
                  ),
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(
                    transaction.isExpense ? 'Pengeluaran' : 'Pemasukan',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rp ${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color:
                              transaction.isExpense ? Colors.red : Colors.green,
                        ),
                      ),
                      // Edit Button
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => editTransaction(transaction),
                      ),
                      // Delete Button
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTransaction(transaction),
                      ),
                    ],
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
