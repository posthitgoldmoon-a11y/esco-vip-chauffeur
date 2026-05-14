content = open('lib/screens/booking_screen.dart', encoding='utf-8').read()

# _selectLocation 함수 앞에 _selectParkingLocation 추가
old = '  void _selectLocation(TextEditingController controller) async {'
new = '''  void _selectParkingLocation(TextEditingController controller) async {
    if (_savedParkingLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장된 주차위치가 없습니다. 마이페이지에서 주차위치를 추가해주세요.')),
      );
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장된 주차위치 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedParkingLocations.length,
            itemBuilder: (context, index) {
              final location = _savedParkingLocations[index];
              return ListTile(
                leading: const Icon(Icons.local_parking),
                title: Text(location),
                onTap: () => Navigator.pop(context, location),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
    if (selected != null) {
      controller.text = selected;
    }
  }

  void _selectLocation(TextEditingController controller) async {'''

content = content.replace(old, new)
open('lib/screens/booking_screen.dart', 'w', encoding='utf-8').write(content)
print('OK' if 'void _selectParkingLocation' in content else 'FAIL')
