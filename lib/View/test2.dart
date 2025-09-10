import 'package:deespora/View/service.dart';
import 'package:flutter/material.dart';


class OtpVerifyScreen extends StatefulWidget {
  final String uid;
  final String verificationId;

  const OtpVerifyScreen({
    Key? key,
    required this.uid,
    required this.verificationId,
  }) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;



Future<void> _verifyOtp() async {
  final code = _otpController.text.trim();
  if (code.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter OTP code")),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    await verifyOtp(
      verificationId: widget.verificationId,
      smsCode: code,
      uid: widget.uid,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Phone verified ✅")),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error verifying OTP: $e")),
    );
  } finally {
    setState(() => _loading = false);
  }
}




  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text("Verify OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}

