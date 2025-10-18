import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  // final TextEditingController controller;
  final String label;
  final String? selectedCountryCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String?>? onCountryCodeChanged;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;
  final IconData? prefixIcon;
  final bool isWhatsApp;

  const PhoneInputField({
    super.key,
    // required this.controller,
    required this.label,
    this.selectedCountryCode,
    required this.countryCodes,
    this.onCountryCodeChanged,
    this.validator,
    this.onSaved,
    this.prefixIcon,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Country code dropdown
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    items: countryCodes.map((code) {
                      return DropdownMenuItem<String>(
                        value: code['code'],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              code['flag'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              code['code'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onCountryCodeChanged,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    isDense: true,
                  ),
                ),
              ),

              // Phone number input
              Expanded(
                child: TextFormField(
                  // controller: controller,
                  keyboardType: TextInputType.phone,
                  validator: validator,
                  onSaved: onSaved,
                  decoration: InputDecoration(
                    // hintText: isWhatsApp
                    //     ? AppLocalizations.of(context)!
                    //     .whatsappNumberPlaceholder
                    //     : AppLocalizations.of(context)!.phoneNumberPlaceholder,
                    prefixIcon: prefixIcon != null
                        ? Icon(prefixIcon,
                        color: isWhatsApp ? Colors.green[600] : null)
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class PhoneInputField2 extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? selectedCountryCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String?>? onCountryCodeChanged;
  final String? Function(String?)? validator;
  // final String? Function(String?)? onSaved;
  final IconData? prefixIcon;
  final bool isWhatsApp;

  const PhoneInputField2({
    super.key,
    required this.controller,
    required this.label,
    this.selectedCountryCode,
    required this.countryCodes,
    this.onCountryCodeChanged,
    this.validator,
    // this.onSaved,
    this.prefixIcon,
    this.isWhatsApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Country code dropdown
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCountryCode,
                    items: countryCodes.map((code) {
                      return DropdownMenuItem<String>(
                        value: code['code'],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              code['flag'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              code['code'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onCountryCodeChanged,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    isDense: true,
                  ),
                ),
              ),

              // Phone number input
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  validator: validator,
                  // onSaved: onSaved,
                  decoration: InputDecoration(
                    // hintText: isWhatsApp
                    //     ? AppLocalizations.of(context)!
                    //     .whatsappNumberPlaceholder
                    //     : AppLocalizations.of(context)!.phoneNumberPlaceholder,
                    prefixIcon: prefixIcon != null
                        ? Icon(prefixIcon,
                        color: isWhatsApp ? Colors.green[600] : null)
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

