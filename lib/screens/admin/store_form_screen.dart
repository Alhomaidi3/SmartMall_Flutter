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
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
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

  void _toggleActive() async {
    if (!_isEditing) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _storeService.updateStore(
        widget.store!.id,
        StoreUpdateDto(
          isActive: !_isActive,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isActive = !_isActive;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isActive ? 'store_activated'.tr() : 'store_deactivated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
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

  void _pickImage() {
    showMessage(context, 'feature_coming_soon'.tr(), type: MessageType.info);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                    _buildImagePreview(),

                    const SizedBox(height: 32),

                    SectionTitle(title: 'arabic_info'.tr()),
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _nameArController,
                      label: 'store_name_ar'.tr(),
                      icon: Icons.text_fields,
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _descArController,
                      label: 'description_ar'.tr(),
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'english_info'.tr()),
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _nameEnController,
                      label: 'store_name_en'.tr(),
                      icon: Icons.text_fields,
                      isRequired: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _descEnController,
                      label: 'description_en'.tr(),
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'category'.tr()),
                    const SizedBox(height: 16),
                    
                    _isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : UnifiedDropdown<int>(
                            value: _selectedCategoryId,
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
                            label: 'category'.tr(),
                            icon: Icons.category_outlined,
                            isRequired: true,
                          ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'contact_info'.tr()),
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _phoneController,
                      label: 'phone_number'.tr(),
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _websiteController,
                      label: 'website'.tr(),
                      icon: Icons.language,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(title: 'location_info'.tr()),
                    const SizedBox(height: 16),
                    
                    UnifiedTextField(
                      controller: _floorController,
                      label: 'floor'.tr(),
                      icon: Icons.layers,
                      keyboardType: TextInputType.number,
                      isRequired: true,
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
                    
                    UnifiedTextField(
                      controller: _imageController,
                      label: 'image_url'.tr(),
                      icon: Icons.image,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 40),

                    UnifiedButton.form(
                      onPressed: _saveStore,
                      text: _isEditing ? 'update_store'.tr() : 'create_store'.tr(),
                      icon: Icons.save,
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 16),

                      UnifiedButton.form(
                        onPressed: _toggleActive,
                        text: _isActive ? 'deactivate'.tr() : 'activate'.tr(),
                        isDestructive: _isActive,
                        icon: _isActive ? Icons.block : Icons.check_circle,
                      ),

                      const SizedBox(height: 16),

                      UnifiedButton.form(
                        onPressed: _deleteStore,
                        text: 'delete_store'.tr(),
                        isDestructive: true,
                        isOutlined: true,
                        icon: Icons.delete_outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
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
                    color: scheme.onSurface.withValues(alpha: 0.3),
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
    );
  }
}