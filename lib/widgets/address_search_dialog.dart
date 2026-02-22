import 'package:flutter/material.dart';

class AddressSearchDialog extends StatefulWidget {
  const AddressSearchDialog({super.key});

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() => _isSearching = true);

    // ⚠️ 현재는 데모용 샘플 데이터를 사용합니다
    // 실제 배포 시에는 카카오 주소 검색 API를 연동해야 합니다
    // 
    // 실제 API 연동 방법:
    // 1. 카카오 개발자 센터에서 REST API 키 발급
    // 2. pubspec.yaml에 http 패키지 추가 (이미 추가됨)
    // 3. 아래 코드의 주석을 해제하고 YOUR_API_KEY를 실제 키로 교체
    //
    // import 'package:http/http.dart' as http;
    // import 'dart:convert';
    //
    // final response = await http.get(
    //   Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=${_searchController.text}'),
    //   headers: {'Authorization': 'KakaoAK YOUR_REST_API_KEY'},
    // );
    // 
    // if (response.statusCode == 200) {
    //   final data = json.decode(response.body);
    //   final documents = data['documents'] as List;
    //   _searchResults = documents.map((doc) => {
    //     'address': doc['address_name'] as String,
    //     'roadAddress': doc['road_address_name'] as String? ?? doc['address_name'] as String,
    //     'placeName': doc['place_name'] as String? ?? '',
    //   }).toList();
    // }

    // ⚠️ 데모용 샘플 데이터 (실제 검색 결과 아님)
    await Future.delayed(const Duration(milliseconds: 500));
    
    final query = _searchController.text.trim();
    final List<Map<String, String>> demoResults = [
      {
        'address': '서울특별시 광진구 광장동 (샘플 주소)',
        'roadAddress': '서울특별시 광진구 강변역로 (샘플 주소)',
        'placeName': '검색어: $query (데모 데이터)'
      },
      {
        'address': '서울특별시 강남구 역삼동 837',
        'roadAddress': '서울특별시 강남구 테헤란로 212',
        'placeName': '강남 지역 (샘플)'
      },
      {
        'address': '서울특별시 서초구 서초대로 396',
        'roadAddress': '서울특별시 서초구 서초대로 396',
        'placeName': '서초 지역 (샘플)'
      },
      {
        'address': '서울특별시 송파구 올림픽로 300',
        'roadAddress': '서울특별시 송파구 올림픽로 300',
        'placeName': '송파 지역 (샘플)'
      },
      {
        'address': '경기도 성남시 분당구 판교역로 166',
        'roadAddress': '경기도 성남시 분당구 판교역로 166',
        'placeName': '판교 지역 (샘플)'
      },
    ];

    setState(() {
      _searchResults = demoResults;
      _isSearching = false;
    });
  }

  Future<void> _selectAddress(String address) async {
    final detailController = TextEditingController();
    final nameController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상세 주소 입력'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '도로명 주소',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: '상세 주소 (선택)',
                  hintText: '예: 3층 301호',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
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
            onPressed: () {
              Navigator.pop(context, {
                'address': address,
                'detailAddress': detailController.text.trim(),
                'name': nameController.text.trim(),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          children: [
            // 검색 헤더
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('검색'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 검색 결과
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '주소를 검색해주세요',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '도로명, 지번, 건물명으로 검색 가능합니다',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length + 1,
                          itemBuilder: (context, index) {
                            // 첫 번째 항목: 데모 데이터 안내
                            if (index == 0) {
                              return Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '⚠️ 현재는 데모 데이터입니다\n실제 배포 시 카카오 주소 API 연동 필요',
                                        style: TextStyle(
                                          color: Colors.amber.shade900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            
                            final result = _searchResults[index - 1];
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.grey.shade700,
                              ),
                              title: Text(result['placeName']!.isNotEmpty 
                                  ? result['placeName']! 
                                  : result['roadAddress']!),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['roadAddress']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (result['address']! != result['roadAddress']!)
                                    Text(
                                      result['address']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () => _selectAddress(result['roadAddress']!),
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
