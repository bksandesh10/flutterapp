import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeWidget(),
    );
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            SizedBox(height: 30),
            Text(
              'Signup Now',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            SizedBox(height: 30),
            UserAuth(),
          ],
        ),
      ),
    );
  }
}

class UserAuth extends StatefulWidget {
  const UserAuth({super.key});

  @override
  _UserAuthState createState() => _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      sendData(
        usernameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }
  }

  Future<void> sendData(String username, String email, String password) async {
    try {
      final url = Uri.parse("http://192.168.56.1:8000/signup/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('data added suxessfully : $data');
      } else {
        final error = jsonDecode(response.body);
        _showError(error.toString());
      }
    } catch (e) {
      _showError("Network Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: "Username"),
            validator: (value) =>
            value == null || value.isEmpty ? "Username required" : null,
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
            value == null || value.isEmpty ? "Email required" : null,
          ),
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) =>
            value == null || value.isEmpty ? "Password required" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: submitForm, child: const Text("Submit")),
        ],
      ),
    );
  }
}

class UserDetail extends StatefulWidget {
  final int userId;
  const UserDetail({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void submitForm() {
    print(widget.userId);
    if (_formKey.currentState!.validate()) {
      sendData(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        dateOfBirthController.text.trim(),
        phoneNumberController.text.trim(),
        _image,
      );
    }
  }

  Future<void> sendData(
      String firstName, String lastName, String dob, String phone, File? image) async {
    print("Sending data:");
    print("User  ID: ${widget.userId}");
    print("First Name: $firstName");
    print("Last Name: $lastName");
    print("Date of Birth: $dob");
    print("Phone: $phone");
    print("Image: ${image?.path}");
    final url = Uri.parse("http://192.168.56.1:8000/users/${widget.userId}/profile/");


    var request = http.MultipartRequest("POST", url);
    request.fields["first_name"] = firstName;
    request.fields["last_name"] = lastName;
    request.fields["DOB"] = dob;
    request.fields["phone"] = phone;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath("profile_pic", image.path));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      print("✅ Profile submitted: $responseData");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile submitted successfully!")),
      );
    } else {
      var errorData = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorData")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Detail"),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Required";
                  if (value.length < 3) return "At least 3 chars";
                  return null;
                },
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Required";
                  if (value.length < 3) return "At least 3 chars";
                  return null;
                },
              ),
              TextFormField(
                controller: dateOfBirthController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date of Birth"),
                onTap: pickDate,
                validator: (value) =>
                value == null || value.trim().isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Required";
                  if (value.length < 10) return "At least 10 digits";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _image != null ? Image.file(_image!, height: 120) : const Text("No image selected"),
              ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: submitForm, child: const Text("Submit")),
            ],
          ),
        ),
      ),
    );
  }
}

