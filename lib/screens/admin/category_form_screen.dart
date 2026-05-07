import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/category_service.dart';
import '/models/category.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryService _categoryService = CategoryService();
  
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;
    
    _nameArController = TextEditingController(text: widget.category?.nameAr ?? '');
    _nameEnController = TextEditingController(text: widget.category?.nameEn ?? '');
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await _categoryService.updateCategory(
          widget.category!.id,
          CategoryUpdateDto(
            nameAr: _nameArController.text.trim(),
            nameEn: _nameEnController.text.trim(),
            isActive: _isActive,
          ),
        );
      } else {
        await _categoryService.createCategory(
          CategoryCreateDto(
            nameAr: _nameArController.text.trim(),
            nameEn: _nameEnController.text.trim(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'category_updated'.tr() : 'category_added'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleActive() async {
    if (!_isEditing) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _categoryService.updateCategory(
        widget.category!.id,
        CategoryUpdateDto(
          isActive: !_isActive,
        ),
      );
      
      setState(() {
        _isActive = !_isActive;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isActive ? 'category_activated'.tr() : 'category_deactivated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_category'.tr()),
        content: Text('delete_category_confirmation'.tr(args: [_nameArController.text])),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await _categoryService.deleteCategory(widget.category!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('category_deleted'.tr()), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: _isEditing ? 'edit_category'.tr() : 'add_category'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.primary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SectionTitle(title: 'category_info'.tr()),
                    const SizedBox(height: 16),

                    UnifiedTextField(
                      controller: _nameArController,
                      label: 'category_name_ar'.tr(),
                      icon: Icons.text_fields,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    UnifiedTextField(
                      controller: _nameEnController,
                      label: 'category_name_en'.tr(),
                      icon: Icons.text_fields,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    UnifiedButton.form(
                      onPressed: _saveCategory,
                      text: _isEditing ? 'update_category'.tr() : 'add_category'.tr(),
                      icon: Icons.save,
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _toggleActive,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isActive ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _isActive ? 'deactivate'.tr() : 'activate'.tr(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      UnifiedButton.form(
                        onPressed: _deleteCategory,
                        text: 'delete_category'.tr(),
                        isDestructive: true,
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}