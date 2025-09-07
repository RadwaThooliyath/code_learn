class PaymentConstants {
  // Razorpay Configuration
  // TODO: Replace these with your actual Razorpay keys
  
  // Test Keys (for development)
  static const String razorpayTestKeyId = 'rzp_test_ONh383HzmXB5Wf';
  
  // Live Keys (for production)
  static const String razorpayLiveKeyId = 'rzp_live_RDTmTSlS55i5Zi';
  
  // Environment flag - set to false for production
  static const bool isTestMode = true;
  
  // Get the appropriate key based on environment
  static String get razorpayKeyId {
    return isTestMode ? razorpayTestKeyId : razorpayLiveKeyId;
  }
  
  // Payment configuration
  static const String companyName = 'CodeLearn LMS';
  static const String companyLogo = 'https://your-domain.com/logo.png'; // Optional
  static const String themeColor = '#3399cc';
  
  // Currency configuration
  static const String currency = 'INR';
  
  // Timeout configuration (in seconds)
  static const int paymentTimeout = 300; // 5 minutes
  
  // Retry configuration
  static const bool enableRetry = true;
  static const int maxRetryCount = 1;
  
  // Supported payment methods
  static const List<String> supportedWallets = [
    'paytm',
    'phonepe',
    'googlepay',
    'amazonpay',
  ];
  
  // External wallet configuration
  static Map<String, List<String>> get externalWallets => {
    'wallets': supportedWallets,
  };
  
  // Validation methods
  static bool get isKeyConfigured {
    final key = razorpayKeyId;
    return key.isNotEmpty && 
           !key.contains('YOUR_TEST_KEY_HERE') && 
           !key.contains('YOUR_LIVE_KEY_HERE') &&
           (key.startsWith('rzp_test_') || key.startsWith('rzp_live_'));
  }
  
  static bool get isValidTestKey {
    return razorpayTestKeyId.startsWith('rzp_test_') && 
           !razorpayTestKeyId.contains('YOUR_TEST_KEY_HERE');
  }
  
  static bool get isValidLiveKey {
    return razorpayLiveKeyId.startsWith('rzp_live_') && 
           !razorpayLiveKeyId.contains('YOUR_LIVE_KEY_HERE');
  }
  
  static String get keyStatus {
    if (!isKeyConfigured) {
      return 'Razorpay keys not configured. Please update PaymentConstants.';
    }
    
    if (isTestMode && !isValidTestKey) {
      return 'Invalid test key. Please check your Razorpay test key.';
    }
    
    if (!isTestMode && !isValidLiveKey) {
      return 'Invalid live key. Please check your Razorpay live key.';
    }
    
    return isTestMode ? 'Test mode - Using test key' : 'Live mode - Using live key';
  }
}

/*
SETUP INSTRUCTIONS:

1. GET YOUR RAZORPAY KEYS:
   - Sign up at https://razorpay.com/
   - Go to Account & Settings > API Keys
   - Generate Test Keys for development
   - Generate Live Keys for production (only after KYC verification)

2. REPLACE THE PLACEHOLDER KEYS:
   - Replace 'rzp_test_YOUR_TEST_KEY_HERE' with your actual test key
   - Replace 'rzp_live_YOUR_LIVE_KEY_HERE' with your actual live key
   - Example: 'rzp_test_1DP5mmOlF5G5ag'

3. ENVIRONMENT CONFIGURATION:
   - Keep isTestMode = true during development
   - Set isTestMode = false for production builds
   - Consider using build flavors for this

4. SECURITY NOTES:
   - Never commit live keys to version control
   - Use environment variables in CI/CD
   - Consider using Flutter's build configurations
   - Add this file to .gitignore if it contains real keys

5. WEBHOOK CONFIGURATION:
   - Configure webhooks in Razorpay dashboard
   - Set webhook URL to your backend endpoint
   - Verify webhook signatures for security

TEST CARDS FOR DEVELOPMENT:
- Success: 4111 1111 1111 1111
- Failure: 4111 1111 1111 1112
- Any future date for expiry
- Any CVV
*/