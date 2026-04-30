import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/tactile_wrapper.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _cardNumberCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _dateCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.toastBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'Mastercard';
    if (number.startsWith('3')) return 'Amex';
    return 'Card';
  }

  bool _validDate(String value) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return false;

    final month = int.tryParse(value.substring(0, 2));
    if (month == null) return false;

    return month >= 1 && month <= 12;
  }

  Future<void> _savePayment() async {
    final number = _digitsOnly(_cardNumberCtrl.text);
    final date = _dateCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (number.length < 11) {
      _snack('Card number must contain at least 11 digits');
      return;
    }

    if (!_validDate(date)) {
      _snack('Date must be in MM/YY format');
      return;
    }

    if (name.isEmpty) {
      _snack('Please enter card holder name');
      return;
    }

    final brand = _detectBrand(number);
    final last4 = number.substring(number.length - 4);

    await AppStateProvider.of(
      context,
    ).updatePayment(last4: last4, brand: brand);

    if (!mounted) return;

    Navigator.pop(context);
    _snack('Payment method saved');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                TactileWrapper(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.credit_card,
                    color: AppColors.accentPink,
                    size: 38,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    state.paymentBrand,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '•••• •••• •••• ${state.paymentLast4}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Only brand and last 4 digits are saved for safety.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _input(
              controller: _cardNumberCtrl,
              label: 'Card Number',
              hint: '1234 5678 9012 3456',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                CardNumberFormatter(),
              ],
            ),

            const SizedBox(height: 16),

            _input(
              controller: _dateCtrl,
              label: 'Expiry Date',
              hint: 'MM/YY',
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
                ExpiryDateFormatter(),
              ],
            ),

            const SizedBox(height: 16),

            _input(
              controller: _nameCtrl,
              label: 'Card Holder Name',
              hint: 'AKHMET ZHAKSYBAY',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 28),

            TactileWrapper(
              onTap: _savePayment,
              child: Container(
                width: double.infinity,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Save Payment',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'For security reasons, CVV and full card number are not saved in the database.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(icon, color: AppColors.accentPink),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.accentPink,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      if ((i + 1) % 4 == 0 && i != digits.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String formatted = digits;

    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
