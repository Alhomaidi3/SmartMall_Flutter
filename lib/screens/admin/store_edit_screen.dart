import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/data/data.dart';

class StoreEditScreen extends StatefulWidget {
  final StoreData? store;

  const StoreEditScreen({super.key, this.store});

  @override
  State<StoreEditScreen> createState() => _StoreEditScreenState();
}

class _StoreEditScreenState extends State<StoreEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _descArController;
  late TextEditingController _descEnController;
  late TextEditingController _imageController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _floorController;
  late TextEditingController _ratingController;
  
  String _selectedCategory = 'clothing';
  bool _isEditing = false;

  final List<String> _categories = [
    'clothing',
    'shoes',
    'perfumes',
    'electronics',
    'accessories',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.store != null;
    
    _nameArController = TextEditingController(text: widget.store?.nameAr ?? '');
    _nameEnController = TextEditingController(text: widget.store?.nameEn ?? '');
    _descArController = TextEditingController(text: widget.store?.descriptionAr ?? '');
    _descEnController = TextEditingController(text: widget.store?.descriptionEn ?? '');
    _imageController = TextEditingController(text: widget.store?.image ?? '');
    _phoneController = TextEditingController(text: widget.store?.phone ?? '');
    _websiteController = TextEditingController(text: widget.store?.website ?? '');
    _floorController = TextEditingController(text: widget.store?.floor.toString() ?? '');
    _ratingController = TextEditingController(text: widget.store?.rating.toString() ?? '4.5');
    
    if (widget.store != null) {
      _selectedCategory = widget.store!.category;
    }
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
    _ratingController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required_field'.tr();
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'required_field'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Category Dropdown
              _buildSectionTitle(context, 'category'.tr()),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
  value: _selectedCategory,
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
    return DropdownMenuItem<String>(
      value: category,
      child: Text('${category}_title'.tr()),
    );
  }).toList(),
  onChanged: (String? value) {
    setState(() {
      _selectedCategory = value!;
    });
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'required_field'.tr();
    }
    return null;
  },
)
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
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _ratingController,
                label: 'rating'.tr(),
                icon: Icons.star,
                keyboardType: TextInputType.number,
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

  void _pickImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('feature_coming_soon'.tr())),
    );
  }

  void _saveStore() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save store to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'store_updated'.tr() : 'store_created'.tr(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deleteStore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_store'.tr()),
        content: Text('delete_store_confirmation'.tr(args: [_nameEnController.text])),
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
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // TODO: Delete store from database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('store_deleted'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}