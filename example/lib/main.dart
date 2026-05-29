import 'package:flutter/material.dart';
import 'examples/draw_engine_and_zoom_example.dart';
import 'examples/interactive_demo_example.dart';
import 'examples/double_elimination_example.dart';
import 'examples/light_theme_example.dart';
import 'examples/minimal_boilerplate_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pool Tournament Road Map Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF131A30),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.6),
                  radius: 1.4,
                  colors: [Color(0xFF0F1735), Color(0xFF070B19)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  const Text(
                    'CHỌN BẢN DEMO ĐỂ TRẢI NGHIỆM',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildExampleCard(
                          context,
                          title: 'Draw Engine & 2D Zoom Map',
                          desc:
                              'Tự động bốc thăm hạt giống/BYE. Hỗ trợ xem sơ đồ thu phóng/pan 2D cực rộng, tích hợp check-in, Walkover, Dispute và tự động đẩy đấu thủ vào vòng sau.',
                          icon: Icons.grid_view_rounded,
                          gradientColors: [
                            const Color(0xFF10B981),
                            const Color(0xFF00E5FF),
                          ],
                          screen: const DrawEngineAndZoomExample(),
                        ),
                        _buildExampleCard(
                          context,
                          title: 'Interactive Bracket Customize',
                          desc:
                              'Sơ đồ thi đấu có bảng điều khiển trực quan (Connector Style, Pulsing, Gradient, độ dày nét, check-in, walkover, tranh chấp và xem chi tiết trận đấu).',
                          icon: Icons.tune,
                          gradientColors: [
                            const Color(0xFF0066FF),
                            const Color(0xFF00E5FF),
                          ],
                          screen: const InteractiveDemoExample(),
                        ),
                        _buildExampleCard(
                          context,
                          title: 'Double Elimination Sơ đồ',
                          desc:
                              'Ví dụ cấu hình giải đấu 2 lần thua (nhánh thắng & nhánh thua) tự động cập nhật dữ liệu và hiển thị chuyển tab mượt mà.',
                          icon: Icons.alt_route,
                          gradientColors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFFD946EF),
                          ],
                          screen: const DoubleEliminationExample(),
                        ),
                        _buildExampleCard(
                          context,
                          title: 'Premium Light Theme',
                          desc:
                              'Trải nghiệm giao diện sáng (Light Mode) của Road Map với cấu hình màu sắc, bóng đổ và các nét nối vô cùng tinh tế.',
                          icon: Icons.light_mode,
                          gradientColors: [
                            const Color(0xFFF59E0B),
                            const Color(0xFFEF4444),
                          ],
                          screen: const LightThemeExample(),
                        ),
                        _buildExampleCard(
                          context,
                          title: 'Minimal Copy-Paste Boilerplate',
                          desc:
                              'Mẫu code rút gọn (dưới 80 dòng) đơn giản nhất để các nhà phát triển sao chép nhanh vào dự án và sử dụng ngay lập tức.',
                          icon: Icons.code,
                          gradientColors: [
                            const Color(0xFF10B981),
                            const Color(0xFF059669),
                          ],
                          screen: const MinimalBoilerplateExample(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROAD MAP MATCHES PACKAGE',
                style: TextStyle(
                  color: Colors.blueAccent.shade100,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tournament Bracket Showcase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Color(0xFFFFB300),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required List<Color> gradientColors,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF131A30).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}
