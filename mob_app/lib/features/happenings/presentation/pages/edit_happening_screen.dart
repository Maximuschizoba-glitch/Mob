import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_field.dart';
import '../../../feed/domain/entities/happening.dart';
import '../bloc/happening_detail_cubit.dart';


class EditHappeningScreen extends StatefulWidget {
  const EditHappeningScreen({super.key, required this.happening});

  final Happening happening;

  @override
  State<EditHappeningScreen> createState() => _EditHappeningScreenState();
}

class _EditHappeningScreenState extends State<EditHappeningScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late HappeningCategory _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.happening.title);
    _descriptionController = TextEditingController(
      text: widget.happening.description?.trim(),
    );
    _selectedCategory = widget.happening.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    return _titleController.text.trim() != widget.happening.title ||
        (_descriptionController.text.trim() !=
            (widget.happening.description?.trim() ?? '')) ||
        _selectedCategory != widget.happening.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Edit Happening',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            MobTextField(
              label: 'Title',
              hint: 'What\u2019s happening?',
              controller: _titleController,
              maxLength: 255,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.lg),


            MobTextField(
              label: 'Description',
              hint: 'Tell people more about it...',
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 2000,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.lg),


            Text(
              'Category',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildCategoryDropdown(),

            const SizedBox(height: AppSpacing.xxl),


            MobGradientButton(
              label: 'Save Changes',
              isLarge: true,
              isLoading: _isSaving,
              onPressed: _hasChanges && !_isSaving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<HappeningCategory>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: AppColors.elevated,
          style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          items: HappeningCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.categoryColor(cat.name),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(cat.displayName),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedCategory = value);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Title cannot be empty',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);


    final cubit = context.read<HappeningDetailCubit>();
    final success = await cubit.updateHappening(
      title: title != widget.happening.title ? title : null,
      description: _descriptionController.text.trim() !=
              (widget.happening.description?.trim() ?? '')
          ? _descriptionController.text.trim()
          : null,
      category: _selectedCategory != widget.happening.category
          ? _selectedCategory.value
          : null,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Happening updated',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update. Please try again.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}
