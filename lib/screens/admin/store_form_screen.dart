import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/store_service.dart';
import '/services/category_service.dart';
import '/models/store.dart';
import '/models/category.dart';

class StoreFormScreen extends StatefulWidget {
  final StoreDto? store;

  const StoreFormScreen({super.key, this.store});

  @override
  State<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends State<StoreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _imageController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _floorController;
  
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isActive = true;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  List<Category> _categories = [];
  
  final StoreService _storeService = StoreService();
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.store != null;
    
    _nameArController = TextEditingController(text: widget.store?.nameAr ?? '');
    _nameEnController = TextEditingController(text: widget.store?.nameEn ?? '');
    _descArController = TextEditingController(text: widget.store?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: widget.store?.descriptionEn ?? '');
    _imageController = TextEditingController(text: widget.store?.imageUrl ?? '');
    _phoneController = TextEditingController(text: widget.store?.phone ?? '');
    _websiteController = TextEditingController(text: widget.store?.website ?? '');
    _floorController = TextEditingController(text: widget.store?.floor.toString() ?? '');
    
    _selectedCategoryId = widget.store?.categoryId;
    _isActive = widget.store?.isActive ?? true;
    
    // استخدام addPostFrameCallback لتأخير تحميل التصنيفات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _imageController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingCategories = true;
    });
    
    try {
      final categories = await _categoryService.getAllCategoriesForAdmin(
        language: context.locale.languageCode,
      );
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
          
          if (_selectedCategoryId != null && _categories.isNotEmpty) {
            final selectedCat = _categories.firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => _categories.first,
            );
            _selectedCategoryName = selectedCat.getName(context.locale.languageCode);
          }
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (_isEditing) {
        // تحديث متجر موجود
        final updateDto = StoreUpdateDto(
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          descriptionAr: _descArController.text.trim().isEmpty ? null : _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim().isEmpty ? null : _descEnController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          floor: int.tryParse(_floorController.text.trim()),
          categoryId: _selectedCategoryId,
          isActive: _isActive,
        );
        
        await _storeService.updateStore(widget.store!.id, updateDto);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('store_updated'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // إنشاء متجر جديد
        final createDto = StoreCreateDto(
          nameAr: _nameArController.text.trim(),
          nameEn: _nameEnController.text.trim(),
          descriptionAr: _descArController.text.trim().isEmpty ? null : _descArController.text.trim(),
          descriptionEn: _descEnController.text.trim().isEmpty ? null : _descEnController.text.trim(),
          floor: int.parse(_floorController.text.trim()),
          imageUrl: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
          categoryId: _selectedCategoryId,
        );
        
        await _storeService.createStore(createDto);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('store_created'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteStore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_store'.tr()),
        content: Text('delete_store_confirmation'.tr(args: [_nameEnController.text])),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      
      try {
        await _storeService.deleteStore(widget.store!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('store_deleted'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _pickImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('feature_coming_soon'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: _isEditing ? 'edit_store'.tr() : 'add_store'.tr(),
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
                    // Image Preview
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                              image: _imageController.text.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_imageController.text),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imageController.text.isEmpty
                                ? Icon(
                                    Icons.store,
                                    size: 50,
                                    color: scheme.onSurface.withOpacity(0.3),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Arabic Fields
                    _buildSectionTitle(context, 'arabic_info'.tr()),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameArController,
                      label: 'store_name_ar'.tr(),
                      icon: Icons.text_fields,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _descArController,
                      label: 'description_ar'.tr(),
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // English Fields
                    _buildSectionTitle(context, 'english_info'.tr()),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameEnController,
                      label: 'store_name_en'.tr(),
                      icon: Icons.text_fields,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _descEnController,
                      label: 'description_en'.tr(),
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // Category Dropdown
                    _buildSectionTitle(context, 'category'.tr()),
                    const SizedBox(height: 16),
                    
                    _isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[850] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.outlineVariant,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: _selectedCategoryId,
                                decoration: InputDecoration(
                                  labelText: 'category'.tr(),
                                  prefixIcon: Icon(Icons.category_outlined, color: scheme.primary),
                                  filled: true,
                                  fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: scheme.outlineVariant),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: scheme.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem<int>(
                                    value: category.id,
                                    child: Text(category.getName(context.locale.languageCode)),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'required_field'.tr();
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),

                    const SizedBox(height: 24),

                    // Contact Info
                    _buildSectionTitle(context, 'contact_info'.tr()),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'phone_number'.tr(),
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _websiteController,
                      label: 'website'.tr(),
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 24),

                    // Location Info
                    _buildSectionTitle(context, 'location_info'.tr()),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _floorController,
                      label: 'floor'.tr(),
                      icon: Icons.layers,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr();
                        }
                        if (int.tryParse(value) == null) {
                          return 'invalid_number'.tr();
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _imageController,
                      label: 'image_url'.tr(),
                      icon: Icons.image,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveStore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _isEditing ? 'update_store'.tr() : 'create_store'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isActive = !_isActive; 
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: !(_isActive) ? Colors.green : Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              !(_isActive) ? 'active'.tr() : 'inactive'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: _deleteStore,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'delete_store'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: scheme.primary, size: 22),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}