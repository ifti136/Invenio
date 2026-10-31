import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/glass_panel.dart';
import '../walkthrough/walkthrough_provider.dart';

class WalkthroughScreen extends ConsumerStatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  ConsumerState<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends ConsumerState<WalkthroughScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _shopNameController = TextEditingController();

  static const List<WalkthroughPage> _pages = [
    WalkthroughPage(
      title: 'Welcome to Invenio',
      description:
          'Your offline-first inventory and economy tracker for small resellers.',
      icon: Icons.storefront_outlined,
    ),
    WalkthroughPage(
      title: 'Track Your Products',
      description:
          'Add products, set cost prices, manage stock levels, and get low-stock alerts.',
      icon: Icons.inventory_2_outlined,
    ),
    WalkthroughPage(
      title: 'Log Sales',
      description:
          'Record every sale with quantity, price, platform, and payment status. See live profit preview.',
      icon: Icons.receipt_outlined,
    ),
    WalkthroughPage(
      title: 'Track Expenses',
      description:
          'Log business expenses by category and see how they affect your net profit.',
      icon: Icons.payment_outlined,
    ),
    WalkthroughPage(
      title: 'View Profit Reports',
      description:
          'View daily and monthly profit & loss reports with charts and export to Excel.',
      icon: Icons.bar_chart_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showShopNameDialog();
    }
  }

  void _showShopNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GlassPanel(
        radius: AppRadii.card,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What is your shop name?',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will appear at the top of your app instead of the app name.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shopNameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. My Resale Shop',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.input),
                ),
              ),
              onSubmitted: (_) => _saveShopName(ctx),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveShopName(ctx),
                    child: const Text('Save & Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveShopName(BuildContext ctx) async {
    final name = _shopNameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(walkthroughProvider.notifier).completeWalkthrough(name);
    if (mounted) {
      Navigator.of(ctx).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length + 1,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              if (index == _pages.length) {
                return _ShopNamePage(controller: _shopNameController);
              }
              return _PageContent(page: _pages[index]);
            },
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length + 1,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? AppColors.accent
                        : AppColors.accent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          if (_currentPage > 0)
            Positioned(
              left: 16,
              bottom: 40,
              child: TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Back'),
              ),
            ),
          if (_currentPage < _pages.length)
            Positioned(
              right: 16,
              bottom: 40,
              child: ElevatedButton(
                onPressed: _nextPage,
                child: Text(_currentPage == _pages.length - 1
                    ? 'Enter Shop Name'
                    : 'Next'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final WalkthroughPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(page.icon, size: 48, color: AppColors.accent),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ShopNamePage extends StatelessWidget {
  final TextEditingController controller;
  const _ShopNamePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.store_outlined, size: 48, color: AppColors.accent),
          ),
          const SizedBox(height: 32),
          Text(
            'Personalize Your App',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Enter your shop name to see it at the top of your app.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. My Resale Shop',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
            ),
            onSubmitted: (_) {},
          ),
        ],
      ),
    );
  }
}

class WalkthroughPage {
  final String title;
  final String description;
  final IconData icon;

  const WalkthroughPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
