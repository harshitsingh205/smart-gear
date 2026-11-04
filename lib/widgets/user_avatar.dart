import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double size;
  final double borderRadius;
  final bool showBorder;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.size = 40,
    this.borderRadius = 12,
    this.showBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl;
    final name = user?.name ?? 'Rider';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';

    Widget avatarContent;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          photoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(initial),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              color: AppColors.surfaceMuted,
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.mountainBlue),
                ),
              ),
            );
          },
        ),
      );
    } else {
      avatarContent = _buildFallbackInitial(initial);
    }

    if (showBorder) {
      avatarContent = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius + 2),
          border: Border.all(color: AppColors.mountainBlueLight, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.mountainBlue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: avatarContent,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallbackInitial(String initial) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.mountainBlue, AppColors.mountainBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.mountainBlue.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
