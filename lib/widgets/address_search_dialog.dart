import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddressSearchDialog extends StatefulWidget {
  const AddressSearchDialog({super.key});

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  static const String _kakaoRestApiKey = '2e2424a60986a1ec5d48ac84a3d47474';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final keywordResponse = await http.get(
        Uri.parse(
          'https://dapi.kakao.com/v2/local/search/keyword.json?query=${Uri.encodeComponent(_searchController.text.trim())}&size=10',
        ),
        headers: {'Authorization': 'KakaoAK $_kakaoRestApiKey'},
      );
      final addressResponse = await http.get(
        Uri.parse(
          'https://dapi.kakao.com/v2/local/search/address.json?query=${Uri.encodeComponent(_searchController.text.trim())}&size=10',
        ),
        headers: {'Authorization': 'KakaoAK $_kakaoRestApiKey'},
      );

      final List<Map<String, String>> results = [];

      if (keywordResponse.statusCode == 200) {
        final data = json.decode(keywordResponse.body);
        for (var doc in data['documents'] as List) {
          final road = doc['road_address_name'] as String? ?? '';
          final jibun = doc['address_name'] as String? ?? '';
          final place = doc['place_name'] as String? ?? '';
          if (road.isNotEmpty || jibun.isNotEmpty) {
            results.add({
              'placeName': place,
              'roadAddress': road.isNotEmpty ? road : jibun,
              'address': jibun.isNotEmpty ? jibun : road,
            });
          }
        }
      }

      if (addressResponse.statusCode == 200) {
        final data = json.decode(addressResponse.body);
        for (var doc in data['documents'] as List) {
          final road = doc['road_address'] != null
              ? doc['road_address']['address_name'] as String? ?? ''
              : '';
          final jibun = doc['address_name'] as String? ?? '';
          final dup = results.any(
            (r) => r['roadAddress'] == road || r['address'] == jibun,
          );
          if (!dup && (road.isNotEmpty || jibun.isNotEmpty)) {
            results.add({
              'placeName': '',
              'roadAddress': road.isNotEmpty ? road : jibun,
              'address': jibun,
            });
          }
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
        if (results.isEmpty) {
          _errorMessage = '검색 결과가 없습니다. 다른 검색어를 입력해보세요.';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = '검색 중 오류가 발생했습니다. 네트워크 연결을 확인해주세요.';
        _searchResults = [];
      });
    }
  }

  Future<void> _selectAddress(String address) async {
    final detailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('상세 주소 입력'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '도로명 주소',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(address, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: detailCtrl,
                decoration: const InputDecoration(
                  labelText: '상세 주소 (선택)',
                  hintText: '예: 3층 301호',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '별칭 (선택)',
                  hintText: '예: 집, 회사',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'address': address,
              'detailAddress': detailCtrl.text.trim(),
              'name': nameCtrl.text.trim(),
            }),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (result != null && mounted) Navigator.pop(context, result);
    detailCtrl.dispose();
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '주소 검색',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: '도로명, 지번, 건물명 검색',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => _searchAddress(),
                          textInputAction: TextInputAction.search,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSearching ? null : _searchAddress,
                        child: const Text('검색'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off,
                                    size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  const Text('주소를 검색해주세요'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '도로명, 지번, 건물명으로 검색 가능합니다',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final r = _searchResults[index];
                                return ListTile(
                                  leading: const Icon(Icons.location_on,
                                      color: Colors.grey),
                                  title: Text(
                                    r['placeName']!.isNotEmpty
                                        ? r['placeName']!
                                        : r['roadAddress']!,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (r['placeName']!.isNotEmpty)
                                        Text(
                                          r['roadAddress']!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      if (r['address']!.isNotEmpty &&
                                          r['address'] != r['roadAddress'])
                                        Text(
                                          r['address']!,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                  onTap: () =>
                                      _selectAddress(r['roadAddress']!),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
