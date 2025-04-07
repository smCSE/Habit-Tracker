// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Habit {
  String id;
  String title;
  bool isCompleted;

  Habit({required this.id, required this.title, this.isCompleted = false});
}

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits = [];

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<Habit> get habits => _habits;

  void addHabit(String title) {
    _habits.add(Habit(id: DateTime.now().toString(), title: title));
    notifyListeners();
  }

  void toggleHabit(String id) {
    final habit = _habits.firstWhere((h) => h.id == id);
    habit.isCompleted = !habit.isCompleted;
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider(),
      child: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Habit Tracker',
            theme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.green.shade50,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.green,
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  const Text('Login to continue', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 40),
                  _buildTextField(hint: 'Enter your email', icon: Icons.email),
                  const SizedBox(height: 20),
                  _buildTextField(hint: 'Enter your password', icon: Icons.lock, obscure: true),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 140,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, required IconData icon, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const SettingsScreen(),
    const DetailsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Details'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final habits = habitProvider.habits;
        return habits.isEmpty
            ? const Center(child: Text('No habits added yet.'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Checkbox(
                        value: habit.isCompleted,
                        activeColor: Colors.green,
                        onChanged: (_) => habitProvider.toggleHabit(habit.id),
                      ),
                      title: Text(habit.title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => habitProvider.deleteHabit(habit.id),
                      ),
                    ),
                  );
                },
              );
      },
    );
  }
}

class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Habit Title'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Provider.of<HabitProvider>(context, listen: false).addHabit(controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('App Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            value: provider.isDarkMode,
            activeColor: Colors.green,
            onChanged: (_) => provider.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.green),
            title: const Text('Daily Reminders'),
            subtitle: const Text('Set daily reminders for your habits'),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text('Backup Data'),
            subtitle: const Text('Backup your habits to the cloud (coming soon)'),
            trailing: const Icon(Icons.cloud_upload),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: const [
          Text('App Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 20),
          ListTile(leading: Icon(Icons.person, color: Colors.green), title: Text('Developer: Shoriful')),
          ListTile(leading: Icon(Icons.school, color: Colors.green), title: Text('Occupation: Student')),
          ListTile(leading: Icon(Icons.calendar_today, color: Colors.green), title: Text('Year: 2025')),
          ListTile(leading: Icon(Icons.code, color: Colors.green), title: Text('Version: 2025.1')),
          SizedBox(height: 20),
          Text('Features:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Add and manage habits'),
                Text('• Mark habits as completed'),
                Text('• Dashboard to track progress'),
                Text('• Dark/light theme toggle'),
                Text('• Daily reminder and backup options'),
                Text('• Clean, responsive green UI'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
