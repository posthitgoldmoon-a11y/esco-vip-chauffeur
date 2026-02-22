import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential == null || userCredential.user == null) {
        // 사용자가 로그인 취소
        setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user!;
      
      // AppProvider에 로그인 상태 저장
      if (!mounted) return;
      await Provider.of<AppProvider>(context, listen: false)
          .login(user.uid, user.displayName ?? 'Google 사용자');

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google 로그인 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithKakao();
      
      if (userCredential == null || userCredential.user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user!;
      
      // Firestore에서 사용자 정보 가져오기
      final userData = await _authService.getUserData(user.uid);
      final userName = userData?['name'] ?? 'Kakao 사용자';
      
      // AppProvider에 로그인 상태 저장
      if (!mounted) return;
      await Provider.of<AppProvider>(context, listen: false)
          .login(user.uid, userName);

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kakao 로그인 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInAnonymously();
      
      if (userCredential == null || userCredential.user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final user = userCredential.user!;
      
      // AppProvider에 로그인 상태 저장
      if (!mounted) return;
      await Provider.of<AppProvider>(context, listen: false)
          .login(user.uid, '게스트');

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게스트 로그인 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/esco_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Google 로그인
              _buildSocialLoginButton(
                onTap: _isLoading ? null : _handleGoogleLogin,
                icon: Icons.g_mobiledata,
                label: 'Google로 시작하기',
                color: Colors.white,
                textColor: Colors.black87,
                borderColor: Colors.grey.shade300,
              ),

              const SizedBox(height: 16),

              // Kakao 로그인
              _buildSocialLoginButton(
                onTap: _isLoading ? null : _handleKakaoLogin,
                icon: Icons.chat_bubble,
                label: 'Kakao로 시작하기',
                color: const Color(0xFFFEE500),
                textColor: Colors.black87,
              ),

              const SizedBox(height: 40),

              // 게스트 로그인
              TextButton(
                onPressed: _isLoading ? null : _handleGuestLogin,
                child: Text(
                  '게스트로 둘러보기',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    Color? borderColor,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: borderColor != null ? 0 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
