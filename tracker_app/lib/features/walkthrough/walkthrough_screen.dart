import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_dialog.dart';
import '../../core/widgets/glass_text_field.dart';
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

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _showShopNameDialog();
    }
  }

  Future<void> _showShopNameDialog() async {
    final name = await showGlassDialog<String>(
      context: context,
      title: 'What is your shop name?',
      message:
          'This will appear at the top of your app instead of the app name.',
      barrierDismissible: false,
      content: Builder(
        builder: (dialogCtx) => GlassTextField(
          controller: _shopNameController,
          hint: 'e.g. My Resale Shop',
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) =>
              Navigator.of(dialogCtx).pop(_shopNameController.text.trim()),
        ),
      ),
      actionsBuilder: (ctx) => [
        GlassDialogAction(
          label: 'Skip',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        GlassDialogAction(
          label: 'Save & Continue',
          isPrimary: true,
          onPressed: () =>
              Navigator.of(ctx).pop(_shopNameController.text.trim()),
        ),
      ],
    );
    if (!mounted) return;
    final shopName = (name == null || name.isEmpty) ? 'Invenio' : name;
    await ref.read(walkthroughProvider.notifier).completeWalkthrough(shopName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _PageContent(page: _pages[index]),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
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
