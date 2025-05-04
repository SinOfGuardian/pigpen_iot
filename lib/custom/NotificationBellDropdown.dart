import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pigpen_iot/apps/notification/notif_screen.dart';
import 'package:pigpen_iot/provider/notification_provider.dart';

class NotificationBellDropdown extends ConsumerStatefulWidget {
  const NotificationBellDropdown({super.key});

  @override
  ConsumerState<NotificationBellDropdown> createState() =>
      _NotificationBellDropdownState();
}

class _NotificationBellDropdownState
    extends ConsumerState<NotificationBellDropdown> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlay() {
    final RenderBox renderBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 8,
              width: 300,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _buildNotificationList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    final asyncValue = ref.watch(firestoreNotificationProvider);

    return asyncValue.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Text("No notifications"),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          itemCount: notifications.length.clamp(0, 5), // Show only top 5
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return ListTile(
              title: Text(item.title),
              // subtitle: Text(
              //   item.body,
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
              trailing: Text(
                DateFormat('hh:mm a').format(item.timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              onTap: () {
                // Optional: Navigate or mark as read
                _removeOverlay();
              },
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text('Error: $e'),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadCountProvider);
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NotificationScreen())); // go to notifications screen
          },
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
