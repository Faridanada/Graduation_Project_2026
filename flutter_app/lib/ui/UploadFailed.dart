import 'package:flutter/material.dart';

class UploadFailedPage extends StatefulWidget {
  const UploadFailedPage({Key? key}) : super(key: key);

  @override
  State<UploadFailedPage> createState() => _UploadFailedPageState();
}

class _UploadFailedPageState extends State<UploadFailedPage> {
  String selectedErrorType = 'Upload';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Upload icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3E0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.upload,
                  size: 80,
                  color: Color(0xFF6BA5CF),
                ),
              ),
              const SizedBox(height: 40),
              // Error title
              Text(
                _getErrorTitle(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9F43),
                ),
              ),
              const SizedBox(height: 20),
              // Error message
              Text(
                _getErrorMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 50),
              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Retry upload logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BA5CF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Demo error type switcher
              Text(
                'Switch Error Type (Demo)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildErrorTypeButton('Connection'),
                  const SizedBox(width: 20),
                  _buildErrorTypeButton('Upload'),
                  const SizedBox(width: 20),
                  _buildErrorTypeButton('Session'),
                ],
              ),
              const SizedBox(height: 30),
              // Back button
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.grey[600],
                  size: 20,
                ),
                label: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorTypeButton(String type) {
    final isSelected = selectedErrorType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedErrorType = type;
        });
      },
      child: Text(
        type,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF6BA5CF) : Colors.grey[400],
        ),
      ),
    );
  }

  String _getErrorTitle() {
    switch (selectedErrorType) {
      case 'Connection':
        return 'Connection Failed';
      case 'Upload':
        return 'Upload Failed';
      case 'Session':
        return 'Session Expired';
      default:
        return 'Upload Failed';
    }
  }

  String _getErrorMessage() {
    switch (selectedErrorType) {
      case 'Connection':
        return 'Unable to connect to the server.\nPlease check your internet connection.';
      case 'Upload':
        return 'The wound photo couldn\'t be uploaded.\nPlease try again.';
      case 'Session':
        return 'Your session has expired.\nPlease log in again to continue.';
      default:
        return 'The wound photo couldn\'t be uploaded.\nPlease try again.';
    }
  }
}
