import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart'; // تأكد من استيراد ملف الـ widgets.dart الذي يحتوي على FilterChipData و FilterChipsRow
import '/services/store_service.dart';
import '/models/store.dart';
import 'store_details_screen.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;

  const MapScreen({super.key, required this.onProfilePressed});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final StoreService _storeService = StoreService();

  List<StoreDto> _stores = [];
  List<String> _categories = [];
  String _selectedCategory = 'all';
  int _selectedFloor = 1;
  bool _isLoading = true;
  String? _error;

  double _scale = 1.0; // متغير scale لمتابعة التكبير والتصغير

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _storeService.getStores(
        page: 1,
        pageSize: 100,
        language: context.locale.languageCode,
      );

      final uniqueCategories = <String>{};

      for (final store in response.data) {
        final categoryName = store.getCategoryName(context.locale.languageCode);

        if (categoryName != null && categoryName.isNotEmpty) {
          uniqueCategories.add(categoryName);
        }
      }

      if (mounted) {
        setState(() {
          _stores = response.data;
          _categories = uniqueCategories.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<StoreDto> get _filteredStores {
    List<StoreDto> result = _stores;

    result = result.where((store) => store.floor == _selectedFloor).toList();

    if (_selectedCategory != 'all') {
      result = result.where((store) {
        final categoryName = store.getCategoryName(context.locale.languageCode);
        return categoryName == _selectedCategory;
      }).toList();
    }

    return result;
  }

  void _showFloorSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_floor'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFloorOption(1),
                  _buildFloorOption(2),
                  _buildFloorOption(3),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloorOption(int floor) {
    final isSelected = _selectedFloor == floor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFloor = floor;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$floor',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<FilterChipData> get categoryFilters {
    final filters = [
      const FilterChipData(
        value: 'all',
        labelKey: 'all_categories',
        icon: Icons.category_outlined,
      ),
      ..._categories.map((c) => FilterChipData(
        value: c,
        dynamicLabel: c,
        icon: Icons.category,
        selectedColor: Theme.of(context).colorScheme.primary,
      )),
    ];
    return filters;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CustomAppBar(
        title: 'smart_mall_guide'.tr(),
        showBackButton: false,
        showProfileIcon: true,
        onProfilePressed: widget.onProfilePressed,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(_error!),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('retry'.tr()),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),  
                        child: FilterChipsRow(
                          filters: categoryFilters, 
                          selectedStatus: _selectedCategory,
                          onSingleSelected: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ),

                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 1.0,
                        maxScale: 3.0,
                        onInteractionUpdate: (details) {
                          setState(() {
                            _scale = details.scale.clamp(1.0, 5.0);
                          });
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final height = constraints.maxHeight;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  isDark
                                      ? 'assets/images/map.png'
                                      : 'assets/images/map2.png',
                                  width: width,
                                  height: height,
                                  fit: BoxFit.contain,
                                ),
                                ..._filteredStores.map((store) {
                                  if (store.x == null || store.y == null) {
                                    return const SizedBox();
                                  }

                                  final left = store.x! * width;
                                  final top = store.y! * height;

                                  double markerSize = 30 / _scale - 1;

                                  markerSize = markerSize.clamp(1.0, double.infinity);

                                  return Positioned(
                                    left: left,
                                    top: top,
                                    child: MapMarker(
                                      label: store.getName(locale),
                                      isActive: store.isActive,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StoreDetailsScreen(
                                              storeId: store.id,
                                            ),
                                          ),
                                        );
                                      },
                                      size: markerSize, // تمرير الحجم المعدل
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: scheme.primary,
            onPressed: () {},
            child: Icon(Icons.my_location, color: scheme.onPrimary),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            mini: true,
            backgroundColor: scheme.primary,
            onPressed: _showFloorSelector,
            child: Icon(Icons.layers, color: scheme.onPrimary),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class MapMarker extends StatelessWidget {
  final String label;
  final bool isActive;
  final double size; // إضافة الحجم المتغير
  final VoidCallback? onTap;

  const MapMarker({
    super.key,
    required this.label,
    this.isActive = true,
    this.size = 30, // القيمة الافتراضية
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size * 0.3, vertical: size * 0.1),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: size * 0.4),
        ),
      ),
    );
  }
}