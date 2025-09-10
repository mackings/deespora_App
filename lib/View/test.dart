import 'package:deespora/View/service.dart';
import 'package:deespora/View/test2.dart';
import 'package:flutter/material.dart';



class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({Key? key}) : super(key: key);

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  String? _verificationId;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter phone number")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Request OTP from Firebase
      final verificationId = await requestOtp(phone);
      setState(() => _verificationId = verificationId);

      // Navigate to OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            uid: phone, // pass phone as uid placeholder or use backend uid if available
            verificationId: verificationId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending OTP: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendOtp,
                    child: const Text("Send OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}