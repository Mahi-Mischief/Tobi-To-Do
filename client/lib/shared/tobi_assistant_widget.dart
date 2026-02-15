import 'package:flutter/material.dart';
import 'package:tobi_todo/core/constants/app_colors.dart';

class TobiAssistant extends StatefulWidget {
  final VoidCallback? onTap;

  const TobiAssistant({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  State<TobiAssistant> createState() => _TobiAssistantState();
}

class _TobiAssistantState extends State<TobiAssistant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FloatingActionButton(
          onPressed: () {
            _toggle();
            widget.onTap?.call();
            // TODO: implement AI suggestions here
          },
          backgroundColor: AppColors.primary,
          child: const Text(
            '✨',
            style: TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
