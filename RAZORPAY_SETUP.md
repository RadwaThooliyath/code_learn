# Razorpay Integration Setup Guide

This guide will help you set up Razorpay payment integration for the CodeLearn LMS app.

## 🔑 Getting Your Razorpay Keys

### Step 1: Create a Razorpay Account
1. Visit [https://razorpay.com/](https://razorpay.com/)
2. Sign up for a new account
3. Complete the verification process

### Step 2: Generate API Keys

#### For Development (Test Mode):
1. Log into your Razorpay Dashboard
2. Navigate to **Account & Settings > API Keys**
3. Click on **Generate Test Key**
4. Copy the **Key ID** (starts with `rzp_test_`)
5. Copy the **Key Secret** (keep this secure - never expose in frontend)

#### For Production (Live Mode):
1. Complete KYC verification in Razorpay Dashboard
2. Navigate to **Account & Settings > API Keys**
3. Click on **Generate Live Key**
4. Copy the **Key ID** (starts with `rzp_live_`)
5. Copy the **Key Secret** (keep this secure)

## 🔧 Configuration

### Step 1: Update Payment Constants
Edit `/lib/app_constants/payment_constants.dart`:

```dart
class PaymentConstants {
  // Replace with your actual keys
  static const String razorpayTestKeyId = 'rzp_test_YOUR_ACTUAL_TEST_KEY';
  static const String razorpayLiveKeyId = 'rzp_live_YOUR_ACTUAL_LIVE_KEY';
  
  // Set to false for production
  static const bool isTestMode = true;
  
  // Your company details
  static const String companyName = 'Your Company Name';
  static const String themeColor = '#your_theme_color';
}
```

### Step 2: Environment Configuration
For production builds, you can use build flavors or environment variables:

#### Option 1: Build Flavors (Recommended)
```dart
// In payment_constants.dart
static String get razorpayKeyId {
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  return flavor == 'prod' ? razorpayLiveKeyId : razorpayTestKeyId;
}
```

#### Option 2: Environment Variables
```dart
static String get razorpayKeyId {
  return const String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: razorpayTestKeyId,
  );
}
```

## 🔒 Security Best Practices

### DO ✅
- Store only the **Key ID** in the frontend
- Keep the **Key Secret** on your backend only
- Use environment variables for production keys
- Verify payments on your backend
- Implement webhook verification
- Use HTTPS for all API calls

### DON'T ❌
- Never expose the Key Secret in frontend code
- Never commit live keys to version control
- Don't skip payment verification on backend
- Don't trust frontend-only payment confirmations

## 🧪 Testing

### Test Card Numbers
Use these cards in test mode:

| Purpose | Card Number | Any CVV | Any Future Date |
|---------|-------------|---------|-----------------|
| Success | 4111 1111 1111 1111 | 123 | 12/25 |
| Failure | 4111 1111 1111 1112 | 123 | 12/25 |
| OTP Success | 4000 0000 0000 3220 | 123 | 12/25 |

### Test UPI IDs
- `success@razorpay` - Success
- `failure@razorpay` - Failure

### Test Wallets
All wallet payments will succeed in test mode.

## 🌐 Webhook Configuration

### Step 1: Set Up Webhook URL
1. In Razorpay Dashboard, go to **Settings > Webhooks**
2. Click **Create New Webhook**
3. Enter your webhook URL: `https://your-backend.com/api/webhooks/razorpay`
4. Select events: `payment.captured`, `payment.failed`
5. Copy the **Webhook Secret**

### Step 2: Webhook Verification (Backend)
```python
# Python example for webhook verification
import hashlib
import hmac

def verify_webhook(payload, signature, secret):
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(signature, expected_signature)
```

## 📱 Frontend Integration

The app is already integrated with:
- Payment initialization
- Success/failure handling
- Automatic enrollment after payment
- Error handling and retries

## 🚀 Going Live

### Checklist for Production:
- [ ] KYC completed in Razorpay Dashboard
- [ ] Live API keys generated
- [ ] Update `isTestMode = false` in constants
- [ ] Webhook URL configured and tested
- [ ] Payment flows tested with real bank accounts
- [ ] Backend payment verification implemented
- [ ] SSL certificate installed
- [ ] Error logging and monitoring set up

## 📞 Support

### Razorpay Resources:
- [API Documentation](https://razorpay.com/docs/)
- [Flutter SDK Documentation](https://razorpay.com/docs/payments/payment-gateway/flutter-integration/)
- [Test Cards](https://razorpay.com/docs/payments/payments/test-card-details/)
- [Webhook Guide](https://razorpay.com/docs/webhooks/)

### Common Issues:
1. **Payment not opening**: Check if Razorpay key is correct
2. **Payment succeeds but enrollment fails**: Check backend API integration
3. **Webhooks not working**: Verify webhook secret and URL
4. **Live payments failing**: Ensure KYC is complete

For any issues, contact Razorpay support or check their documentation.