import 'package:flutter/material.dart';

class FloatingNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color activeColor;
  final Color activeBgColor;

  const FloatingNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.activeBgColor,
  });
}

class FloatingPillNavBar extends StatelessWidget {
  const FloatingPillNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.onCenterButtonPressed,
    this.centerButtonIcon = Icons.add_rounded,
    this.centerButtonGradient,
    this.centerButtonColor,
    this.showCenterButton = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<FloatingNavItem> items;
  final VoidCallback? onCenterButtonPressed;
  final IconData centerButtonIcon;
  final Gradient? centerButtonGradient;
  final Color? centerButtonColor;
  final bool showCenterButton;

  @override
  Widget build(BuildContext context) {
    const double barHeight = 58.0;
    const double protrusion = 16.0;
    const double totalHeight = barHeight + protrusion;
    const double centerButtonSize = 50.0;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final double bottomMargin = bottomInset > 0 ? (bottomInset * 0.3) : 2.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomMargin),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: Container(
          height: totalHeight,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // White Dock Bar Container
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: barHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x140D3B66),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: showCenterButton ? _buildSplitContent() : _buildFullContent(),
                  ),
                ),

                // Elevated Center Button
                if (showCenterButton)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildCenterButton(centerButtonSize),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitContent() {
    final half = items.length ~/ 2;
    final leftItems = items.sublist(0, half);
    final rightItems = items.sublist(half);

    return Row(
      children: [
        // Left tabs
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(leftItems.length, (i) {
              return _buildTabItem(index: i, item: leftItems[i]);
            }),
          ),
        ),

        // Center gap for the circular elevated button
        const SizedBox(width: 58),

        // Right tabs
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(rightItems.length, (i) {
              final originalIndex = half + i;
              return _buildTabItem(index: originalIndex, item: rightItems[i]);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(items.length, (i) {
        return _buildTabItem(index: i, item: items[i]);
      }),
    );
  }

  Widget _buildTabItem({required int index, required FloatingNavItem item}) {
    final isSelected = selectedIndex == index;
    final activeColor = item.activeColor;
    const inactiveColor = Color(0xFF94A3B8);

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.06 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                (isSelected && item.activeIcon != null) ? item.activeIcon! : item.icon,
                size: 21,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2.5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.2,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(double size) {
    final gradient = centerButtonGradient ??
        (centerButtonColor != null
            ? LinearGradient(colors: [centerButtonColor!, centerButtonColor!])
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ));

    return GestureDetector(
      onTap: onCenterButtonPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          border: Border.all(color: Colors.white, width: 4.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x407C5CFC),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color(0x140D3B66),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            centerButtonIcon,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}
