import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/mob_bottom_sheet.dart';
import '../../../../shared/widgets/mob_text_field.dart';
import '../../domain/repositories/report_repository.dart';


enum _ReportReason {
  fake(
    value: 'fake',
    label: 'Fake Event',
    description: 'This event doesn\u2019t exist or is fabricated',
    icon: Icons.warning_amber_rounded,
  ),
  scam(
    value: 'scam',
    label: 'Scam',
    description: 'Trying to collect money or info fraudulently',
    icon: Icons.gpp_bad_outlined,
  ),
  misleading(
    value: 'misleading',
    label: 'Misleading Info',
    description: 'Details, photos, or descriptions are inaccurate',
    icon: Icons.info_outline_rounded,
  ),
  wrongLocation(
    value: 'wrong_location',
    label: 'Wrong Location',
    description: 'The pin or address doesn\u2019t match reality',
    icon: Icons.wrong_location_outlined,
  );

  const _ReportReason({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });


  final String value;


  final String label;


  final String description;


  final IconData icon;
}


class ReportSheet extends StatefulWidget {
  const ReportSheet({
    super.key,
    required this.happeningUuid,
    required this.reportRepository,
  });

  final String happeningUuid;
  final ReportRepository reportRepository;


  static Future<bool?> show(
    BuildContext context, {
    required String happeningUuid,
    required ReportRepository reportRepository,
  }) {
    return MobBottomSheet.show<bool>(
      context,
      maxHeight: 0.85,
      child: ReportSheet(
        happeningUuid: happeningUuid,
        reportRepository: reportRepository,
      ),
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  _ReportReason? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _canSubmit => _selectedReason != null && !_isSubmitting;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await widget.reportRepository.submitReport(
      happeningUuid: widget.happeningUuid,
      reason: _selectedReason!.value,
      details: _detailsController.text.trim().isNotEmpty
          ? _detailsController.text.trim()
          : null,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = failure.message;
        });
      },
      (_) {

        Navigator.of(context).pop(true);


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted. Thanks for keeping Mob safe.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Report Happening',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Why are you reporting this?',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),


          ..._ReportReason.values.map(_buildReasonOption),

          const SizedBox(height: AppSpacing.lg),


          MobTextField(
            label: 'Additional details (optional)',
            hint: 'Tell us more about what\u2019s wrong...',
            controller: _detailsController,
            maxLines: 3,
            maxLength: 1000,
            enabled: !_isSubmitting,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AppSpacing.lg),


          if (_errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
          ],


          _buildSubmitButton(),

          const SizedBox(height: AppSpacing.sm),


          Center(
            child: Text(
              'Reports are reviewed by our moderation team',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildReasonOption(_ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: _isSubmitting
            ? null
            : () => setState(() => _selectedReason = reason),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.error.withValues(alpha: 0.08)
                : AppColors.elevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.error.withValues(alpha: 0.6)
                  : AppColors.surface,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.error : AppColors.textTertiary,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: AppSpacing.sm),


              Icon(
                reason.icon,
                size: 20,
                color: isSelected ? AppColors.error : AppColors.textSecondary,
              ),

              const SizedBox(width: AppSpacing.sm),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reason.label,
                      style: AppTypography.body.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason.description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _canSubmit ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppSpacing.buttonRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _canSubmit ? _submit : null,
            borderRadius: AppSpacing.buttonRadius,
            splashColor: AppColors.textPrimary.withValues(alpha: 0.1),
            highlightColor: AppColors.textPrimary.withValues(alpha: 0.05),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Submit Report',
                      style: AppTypography.button.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
