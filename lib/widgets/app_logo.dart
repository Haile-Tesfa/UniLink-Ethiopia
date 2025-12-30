import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withText;

  const AppLogo({
    super.key,
    this.size = 100,
    this.withText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.school,
              size: size * 0.6,
              color: Colors.white,
            ),
          ),
        ),

        if (withText) ...[
          const SizedBox(height: 15),

          const Text(
            'UniLink',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'ETHIOPIA',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}