import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

class AddressSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final void Function(String address, String postCode, double? lat, double? lng)?
      onAddressSelected;

  const AddressSearchField({
    super.key,
    required this.controller,
    this.label = '주소',
    this.hint = '주소를 검색하세요',
    this.onAddressSelected,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  bool _isLoading = false;

  Future<void> _openAddressSearch() async {
    setState(() => _isLoading = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => KpostalView(
            kakaoKey: '97fce87d04da85fad12e4dc0bf9f0e1b',
            callback: (Kpostal result) {
              widget.controller.text = result.address;
              if (widget.onAddressSelected != null) {
                widget.onAddressSelected!(
                  result.address,
                  result.postCode,
                  result.kakaoLatitude ?? result.latitude,
                  result.kakaoLongitude ?? result.longitude,
                );
              }
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF3A3A3A)),
                tooltip: '주소 검색',
                onPressed: _openAddressSearch,
              ),
      ),
      onTap: _openAddressSearch,
    );
  }
}
