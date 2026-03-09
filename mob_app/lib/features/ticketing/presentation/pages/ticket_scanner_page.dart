import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/repositories/ticket_repository.dart';


class TicketScannerPage extends StatefulWidget {
  const TicketScannerPage({
    super.key,
    required this.happeningUuid,
  });

  final String happeningUuid;

  @override
  State<TicketScannerPage> createState() => _TicketScannerPageState();
}

class _TicketScannerPageState extends State<TicketScannerPage> {
  late final MobileScannerController _cameraController;


  _ScanResult? _scanResult;


  bool _isProcessing = false;


  int _checkedInCount = 0;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),


          _buildScanOverlay(),


          _buildTopBar(context),


          if (_scanResult != null) _buildResultCard(context),


          _buildSessionCounter(),
        ],
      ),
    );
  }


  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    if (_scanResult != null) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;


    final ticketUuid = _extractTicketUuid(rawValue);
    if (ticketUuid == null) {
      _showResult(
        status: 'invalid',
        message: 'Not a valid Mob ticket QR code.',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
      HapticFeedback.heavyImpact();
      return;
    }

    _verifyTicket(ticketUuid);
  }


  String? _extractTicketUuid(String raw) {

    const prefix = 'mob://ticket/';
    if (raw.startsWith(prefix)) {
      final uuid = raw.substring(prefix.length).trim();
      if (uuid.isNotEmpty) return uuid;
    }


    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidPattern.hasMatch(raw.trim())) {
      return raw.trim();
    }

    return null;
  }

  Future<void> _verifyTicket(String ticketUuid) async {
    setState(() => _isProcessing = true);

    final repo = context.read<TicketRepository>();
    final result = await repo.verifyTicketCheckIn(
      happeningUuid: widget.happeningUuid,
      ticketUuid: ticketUuid,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        _showResult(
          status: 'error',
          message: failure.message,
          icon: Icons.wifi_off_rounded,
          color: AppColors.error,
        );
        HapticFeedback.heavyImpact();
      },
      (data) {
        final status = data['status'] as String? ?? 'invalid';
        final message = data['message'] as String? ?? '';
        final attendeeName = data['attendee_name'] as String?;

        switch (status) {
          case 'valid':
            _showResult(
              status: status,
              message: message,
              attendeeName: attendeeName,
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            );
            setState(() => _checkedInCount++);
            HapticFeedback.mediumImpact();
            break;

          case 'already_checked_in':
            final checkedAt = data['checked_in_at'] as String?;
            _showResult(
              status: status,
              message: message,
              attendeeName: attendeeName,
              subtitle: checkedAt != null
                  ? 'Checked in at ${_formatTime(checkedAt)}'
                  : null,
              icon: Icons.info_outline_rounded,
              color: AppColors.warning,
            );
            HapticFeedback.lightImpact();
            break;

          case 'wrong_event':
            final ticketEvent = data['ticket_event'] as String?;
            _showResult(
              status: status,
              message: message,
              subtitle:
                  ticketEvent != null ? 'Ticket is for: $ticketEvent' : null,
              icon: Icons.swap_horiz_rounded,
              color: AppColors.error,
            );
            HapticFeedback.heavyImpact();
            break;

          default:

            _showResult(
              status: status,
              message: message,
              icon: Icons.cancel_outlined,
              color: AppColors.error,
            );
            HapticFeedback.heavyImpact();
        }
      },
    );

    setState(() => _isProcessing = false);
  }

  void _showResult({
    required String status,
    required String message,
    required IconData icon,
    required Color color,
    String? attendeeName,
    String? subtitle,
  }) {
    setState(() {
      _scanResult = _ScanResult(
        status: status,
        message: message,
        icon: icon,
        color: color,
        attendeeName: attendeeName,
        subtitle: subtitle,
      );
    });
  }

  void _dismissResult() {
    setState(() {
      _scanResult = null;
    });
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return isoString;
    }
  }


  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [

                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Tickets',
                        style: AppTypography.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Point camera at attendee\'s QR code',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),


                IconButton(
                  onPressed: () => _cameraController.toggleTorch(),
                  icon: ValueListenableBuilder(
                    valueListenable: _cameraController,
                    builder: (context, state, child) {
                      return Icon(
                        state.torchState == TorchState.on
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: state.torchState == TorchState.on
                            ? AppColors.warning
                            : Colors.white70,
                        size: 24,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isProcessing
                ? AppColors.warning
                : AppColors.cyan.withValues(alpha: 0.8),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Stack(
          children: [

            Positioned(
              top: -1.5,
              left: -1.5,
              child: _cornerAccent(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),

            Positioned(
              top: -1.5,
              right: -1.5,
              child: _cornerAccent(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),

            Positioned(
              bottom: -1.5,
              left: -1.5,
              child: _cornerAccent(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),

            Positioned(
              bottom: -1.5,
              right: -1.5,
              child: _cornerAccent(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),


            if (_isProcessing)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.cyan,
                  strokeWidth: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cornerAccent({required BorderRadius borderRadius}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.cyan,
          width: 4,
        ),
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final result = _scanResult!;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          border: Border(
            top: BorderSide(
              color: result.color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),


                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: result.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        result.icon,
                        color: result.color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result.attendeeName != null) ...[
                            Text(
                              result.attendeeName!,
                              style: AppTypography.h3.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            result.message,
                            style: AppTypography.body.copyWith(
                              color: result.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (result.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              result.subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),


                SizedBox(
                  width: double.infinity,
                  height: AppSpacing.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: _dismissResult,
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                    ),
                    label: const Text('Scan Next Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.elevated,
                      foregroundColor: AppColors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        side: BorderSide(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      textStyle: AppTypography.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCounter() {
    return Positioned(
      bottom: _scanResult != null ? null : 40,
      top: _scanResult != null ? null : null,
      left: 0,
      right: 0,
      child: _scanResult != null
          ? const SizedBox.shrink()
          : Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: AppColors.cyan,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$_checkedInCount checked in this session',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


class _ScanResult {
  final String status;
  final String message;
  final IconData icon;
  final Color color;
  final String? attendeeName;
  final String? subtitle;

  const _ScanResult({
    required this.status,
    required this.message,
    required this.icon,
    required this.color,
    this.attendeeName,
    this.subtitle,
  });
}
