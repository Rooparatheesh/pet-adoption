import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/pet_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/pet_image_widget.dart';

class PetAddScreen extends ConsumerStatefulWidget {
  const PetAddScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PetAddScreen> createState() => _PetAddScreenState();
}

class _PetAddScreenState extends ConsumerState<PetAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  String _selectedGender = 'Male';
  String _selectedSize = 'Medium';
  String? _selectedImageUrl;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,   // reduced from 1024 → smaller payload
        maxHeight: 600,
        imageQuality: 50, // reduced from 80 → much smaller file
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      final String base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        _selectedImageUrl = base64Image;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null || _selectedImageUrl == null) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a Category'),
            backgroundColor: AppColors.danger,
          ),
        );
      } else if (_selectedImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload a pet photo'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    // Show feedback immediately so user knows it's uploading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Uploading listing, please wait...'),
          ],
        ),
        duration: Duration(seconds: 30),
        backgroundColor: AppColors.primary,
      ),
    );

    try {
      await ref.read(petRepositoryProvider).createPet(
            name: _nameController.text.trim(),
            breed: _breedController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _selectedGender,
            size: _selectedSize,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            imageUrl: _selectedImageUrl!,
            location: _locationController.text.trim(),
            categoryId: _selectedCategoryId!,
          );

      // Refresh pet lists so the new pet is visible immediately
      ref.invalidate(petListProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🐾 Pet listed successfully for adoption!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext WidgetContext) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final theme = Theme.of(WidgetContext);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Pet for Adoption',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pet Details',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fade(duration: 300.ms),
              const SizedBox(height: 16),

              // Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Pet Name',
                hintText: 'e.g., Buddy',
                prefixIcon: Icons.pets,
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ).animate().fade(delay: 50.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Category Selection Dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  hint: const Text('Select Pet Category'),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                    fillColor: isDark ? AppColors.darkCardBg : Colors.white,
                    filled: true,
                  ),
                  dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                  validator: (val) => val == null ? 'Category is required' : null,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error loading categories: $e'),
              ).animate().fade(delay: 100.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Breed & Age Side by Side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _breedController,
                      labelText: 'Breed',
                      hintText: 'e.g., Golden Retriever',
                      prefixIcon: Icons.history_edu_outlined,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Breed is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _ageController,
                      labelText: 'Age (in months)',
                      hintText: 'e.g., 12',
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Age is required';
                        if (int.tryParse(val.trim()) == null) return 'Must be a number';
                        return null;
                      },
                    ),
                  ),
                ],
              ).animate().fade(delay: 150.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Gender Toggle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Male', 'Female'].map((gender) {
                            final isSelected = _selectedGender == gender;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedGender = gender),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark ? AppColors.darkCardBg : Colors.grey.shade100),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      gender,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fade(delay: 200.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Size Toggle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Small', 'Medium', 'Large'].map((size) {
                      final isSelected = _selectedSize == size;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => setState(() => _selectedSize = size),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkCardBg : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ).animate().fade(delay: 250.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Location
              CustomTextField(
                controller: _locationController,
                labelText: 'Location',
                hintText: 'e.g., Seattle, WA',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Location is required' : null,
              ).animate().fade(delay: 300.ms, duration: 300.ms),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Describe pet\'s personality, vaccination status, habits...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
              ).animate().fade(delay: 350.ms, duration: 300.ms),
              const SizedBox(height: 24),

              // Photo Section
              Text(
                'Pet Photo',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ).animate().fade(delay: 400.ms, duration: 300.ms),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      style: _selectedImageUrl != null ? BorderStyle.none : BorderStyle.solid,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _selectedImageUrl != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              PetImageWidget(
                                imageUrl: _selectedImageUrl,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                size: 48,
                                color: AppColors.primary.withOpacity(0.8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to Upload Pet Photo',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supports PNG, JPG, JPEG',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ).animate().fade(delay: 450.ms, duration: 300.ms),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Publish Listing',
                onPressed: _submit,
                isLoading: _isLoading,
              ).animate().fade(delay: 550.ms, duration: 300.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
