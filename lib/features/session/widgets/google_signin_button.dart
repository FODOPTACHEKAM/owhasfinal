import 'package:flutter/material.dart';
import '../../../services/cloud_service.dart';

/// Compact Google Sign-In / Sign-Out banner for the session setup screen.
/// Shows sign-in button when logged out; shows avatar + name + sign-out when logged in.
class GoogleSignInBanner extends StatefulWidget {
  const GoogleSignInBanner({super.key});

  @override
  State<GoogleSignInBanner> createState() => _GoogleSignInBannerState();
}

class _GoogleSignInBannerState extends State<GoogleSignInBanner> {
  final _cloud = CloudService();
  bool _loading = false;

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    try {
      await _cloud.signInWithGoogle();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _loading = true);
    try {
      await _cloud.signOut();
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _cloud.currentUser;
    final cs   = Theme.of(context).colorScheme;

    if (user != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.green.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              backgroundColor: cs.primary.withValues(alpha: 0.15),
              child: user.photoURL == null
                  ? Text(
                      (user.displayName ?? 'G')[0].toUpperCase(),
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.displayName ?? 'Signed in',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Cloud sync active',
                    style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                onPressed: _handleSignOut,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Sign out', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      );
    }

    return OutlinedButton(
      onPressed: _loading ? null : _handleSignIn,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: cs.outline),
      ),
      child: _loading
          ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/google_logo.png', height: 20, width: 20,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.login, size: 20)),
                const SizedBox(width: 10),
                const Text(
                  'Sign in with Google for cloud backup',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
    );
  }
}
