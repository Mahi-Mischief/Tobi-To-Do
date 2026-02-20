import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/shared/widgets/tobi_widget.dart';
import 'package:tobi_todo/shared/services/tobi_controller.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
import 'package:tobi_todo/features/shared/screens/tobi_dashboard_screen.dart';

class TobiAIAssistant extends ConsumerStatefulWidget {
  const TobiAIAssistant({super.key});

  @override
  ConsumerState<TobiAIAssistant> createState() => _TobiAIAssistantState();
}

class _TobiAIAssistantState extends ConsumerState<TobiAIAssistant>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAssistant() {
    setState(() {
      _isExpanded = !_isExpanded;
        if (_isExpanded) {
        _animationController.forward();
        // play a small 'think' animation when opened via service
        try {
          TobiService.instance.think();
        } catch (_) {}
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Suggestions Panel
          if (_isExpanded) 
            ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
              ),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/tobi_animations/Tobi.png', height: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Tobi AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _toggleAssistant,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💡 Smart Suggestions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSuggestion(
                            '📌 You have 3 overdue tasks. Break them down?',
                            () {
                              TobiService.instance.think();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Breaking down tasks with AI...'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildSuggestion(
                            '⏱️ Start a focus session on your top priority',
                            () {
                              TobiService.instance.wave();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening Focus tab...'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _buildSuggestion(
                            '🎯 Review your goals progress today',
                            () {
                              TobiService.instance.think();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Loading goal analysis...'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Open full Tobi dashboard screen
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TobiDashboardScreen()));
                                // play a celebratory animation when opening
                                TobiService.instance.dance();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('View Full Dashboard'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Main FAB replaced with Tobi icon that animates via provider
          GestureDetector(
            onTap: _toggleAssistant,
            child: SizedBox(
              height: 56,
              width: 56,
              child: ClipOval(
                child: Container(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                      child: ValueListenableBuilder(
                        valueListenable: TobiController.instance.state,
                        builder: (context, value, _) {
                          final s = value as dynamic;
                          return TobiWidget(
                            animationName: s.animationName,
                            size: 40,
                            frameCount: s.frameCount,
                            fps: s.fps,
                            loop: s.loop,
                            animate: false, // static icon on FAB to avoid continuous anim
                          );
                        },
                      ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestion(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
