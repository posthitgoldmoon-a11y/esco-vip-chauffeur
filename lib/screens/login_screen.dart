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
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final isAdmin = await _authService.isAdmin();
      if (!mounted) return;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.login(
        user.uid,
        user.displayName ?? '사용자',
        isAdmin: isAdmin,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google 로그인 실패: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithKakao();
      if (!mounted) return;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final userData = await _authService.getUserData(user.uid);
      if (!mounted) return;
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.login(
        user.uid,
        userData?['name'] as String? ?? '카카오 사용자',
        isAdmin: userData?['isAdmin'] as bool? ?? false,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('카카오 로그인 실패: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInAnonymously();
      if (!mounted) return;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.login(user.uid, '게스트');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('게스트 로그인 실패: $e')));
      setState(() => _isLoading = false);
    }
  }

  Widget _buildLoginButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: foregroundColor),
        label: Text(
          label,
          style: TextStyle(
              color: foregroundColor,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car,
                  size: 80, color: Colors.black87),
              const SizedBox(height: 16),
              const Text(
                'ESCO VIP Chauffeur',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                '프리미엄 운전대행 서비스',
                style:
                    TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                _buildLoginButton(
                  label: 'Google로 로그인',
                  icon: Icons.g_mobiledata,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: _handleGoogleLogin,
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  label: '카카오로 로그인',
                  icon: Icons.chat_bubble,
                  backgroundColor: const Color(0xFFFEE500),
                  foregroundColor: Colors.black87,
                  onPressed: _handleKakaoLogin,
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  label: '게스트로 시작하기',
                  icon: Icons.person_outline,
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black54,
                  onPressed: _handleGuestLogin,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}