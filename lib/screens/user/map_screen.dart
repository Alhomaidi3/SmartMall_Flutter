import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/widgets/widgets.dart';
import '/services/store_service.dart';
import '/models/store.dart';
import 'store_details_screen.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback onProfilePressed;
  final int? selectedStoreId; // ✅ إضافة هذا

  const MapScreen({
    super.key, 
    required this.onProfilePressed,
    this.selectedStoreId, // ✅ إضافة هذا
  });

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
bool _isPickingLocation = false;
  
  // ✅ متغيرات مسار المستخدم
  Offset? _userPosition; // موقع المستخدم على الخريطة (بالنسبة المئوية)
  StoreDto? _selectedStore; // المحل المختار لعرض الاتجاهات
  bool _isShowingRoute = false; // هل يتم عرض المسار حالياً
  
  // ألوان المسار
  static const Color _routeColor = Colors.blue;
  static const Color _userMarkerColor = Colors.green;
  static const Color _storeMarkerColor = Colors.red;
  bool _hasProcessedSelectedStore = false;

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
        
        // ✅ بعد تحميل البيانات، معالجة selectedStoreId إن وجد
        _processSelectedStoreId();
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
  void _processSelectedStoreId() {
    // تجنب المعالجة المتكررة
    if (_hasProcessedSelectedStore || widget.selectedStoreId == null) return;
    
    _hasProcessedSelectedStore = true;
    
    // البحث عن المتجر في القائمة
    final store = _stores.firstWhere(
      (s) => s.id == widget.selectedStoreId,
      orElse: () => throw Exception('Store not found'),
    );
    
    // تأخير بسيط لضمان اكتمال بناء الواجهة
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        // ✅ تغيير الطابق إذا لزم الأمر
        if (store.floor != _selectedFloor) {
          setState(() {
            _selectedFloor = store.floor;
          });
          // تأخير إضافي بعد تغيير الطابق
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _startDirections(store);
          });
        } else {
          _startDirections(store);
        }
      }
    });
  }

void _setUserLocation(Offset position) {
  setState(() {
    _userPosition = position;
    _isPickingLocation = false;
  });
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

void _showStoreBottomSheet(StoreDto store) {
  final locale = context.locale.languageCode;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: store.isActive ? Colors.orange : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.getName(locale),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!store.isActive)
                          Text(
                            'inactive'.tr(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

const SizedBox(height: 12),

// ✅ التقييمات - تظهر دائماً
Row(
  children: [
    // عرض النجوم
    Row(
      children: List.generate(5, (index) {
        final rating = store.averageRating ?? 0;
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating && rating - index > 0.5) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    ),
    const SizedBox(width: 8),
    Text(
      store.ratingsCount == 0
          ? 'no_ratings_yet'.tr()
          : '${store.averageRating?.toStringAsFixed(1) ?? "0"} (${store.ratingsCount} ${'reviews'.tr()})',
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    ),
  ],
),

const SizedBox(height: 16),

              if (store.getDescription(locale) != null &&
                  store.getDescription(locale)!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    store.getDescription(locale)!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),

              const Divider(height: 24),

              if (store.openHours != null &&
                  store.openHours!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time,
                  'open_hours'.tr(),
                  store.openHours!,
                  isDark,
                ),
              ],

              if (store.phone != null && store.phone!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.phone,
                  'phone_number'.tr(),
                  store.phone!,
                  isDark,
                ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _startDirections(store);
                      },
                      icon: const Icon(Icons.directions),
                      label: Text('directions'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoreDetailsScreen(
                              storeId: store.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline),
                      label: Text('more_details'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _startDirections(StoreDto store) {
    if (store.x == null || store.y == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('store_location_error'.tr())),
      );
      return;
    }
    
    setState(() {
      _selectedStore = store;
      _isShowingRoute = true;
      
      // إذا لم يكن هناك موقع محدد للمستخدم، افتح الـ BottomSheet لاختيار الموقع
      if (_userPosition == null) {
        _showSetUserLocationDialog();
      }
    });
  }
  
void _showSetUserLocationDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('set_your_location'.tr()),
      content: Text('tap_on_map_to_set_your_location_first'.tr()),
      actions: [
        TextButton(
          onPressed: () { 
            setState(() {
              _isShowingRoute = false;
              _selectedStore = null;
            });
            Navigator.pop(context);
          },
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // ✅ تفعيل وضع اختيار الموقع تلقائياً
            setState(() {
              _isPickingLocation = true;
            });
          },
          child: Text('set_location'.tr()),
        ),
      ],
    ),
  );
}  
  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
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
          // تغيير الطابق يزيل المسار الحالي
          _userPosition = null;
          _selectedStore = null;
          _isShowingRoute = false;
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
                              // تغيير الفلتر يزيل المسار الحالي
                              _userPosition = null;
                              _selectedStore = null;
                              _isShowingRoute = false;
                            });
                          },
                        ),
                      ),
                    
                    // ✅ شريط معلومات المسار
                    if (_isShowingRoute && _userPosition != null && _selectedStore != null)
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.route, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'directions_to'.tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (_selectedStore != null) {
                                        return Text(
                                          _selectedStore!.getName(locale),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // يمكن إضافة المسافة هنا عند الحاجة
                          ],
                        ),
                      ),
                    
                    Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final imageSize = Size(constraints.maxWidth, constraints.maxHeight);
      
      return GestureDetector(
        onTapDown: (details) {
          // ✅ فقط إذا كان في وضع اختيار الموقع
          if (_isPickingLocation) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            
            // تحويل الإحداثيات إلى نسبة مئوية (0-1)
            final x = (localPosition.dx) / imageSize.width;
            final y = (localPosition.dy) / imageSize.height;
            
            if (x >= 0 && x <= 1 && y >= 0 && y <= 1) {
              _setUserLocation(Offset(x, y));
            }
          }
        },

                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 1.0,
                              maxScale: 3.0,
                              onInteractionUpdate: (details) {
                              },
                              child: Container(
                                width: imageSize.width,
                                height: imageSize.height,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Image.asset(
                                      isDark
                                          ? 'assets/images/map.png'
                                          : 'assets/images/map2.png',
                                      width: imageSize.width,
                                      height: imageSize.height,
                                      fit: BoxFit.contain,
                                    ),
                                    
// ✅ رسم الخط بين المستخدم والمحل (النسخة المصححة)
if (_isShowingRoute && 
    _userPosition != null && 
    _selectedStore != null &&
    _selectedStore!.x != null &&
    _selectedStore!.y != null)
  Positioned(
    left: 0,
    top: 0,
    child: SizedBox(
      width: imageSize.width,
      height: imageSize.height,
      child: CustomPaint(
        painter: RoutePainter(
          start: Offset(
            _userPosition!.dx * imageSize.width,
            _userPosition!.dy * imageSize.height,
          ),
          end: Offset(
            _selectedStore!.x! * imageSize.width,
            _selectedStore!.y! * imageSize.height,
          ),
          color: _routeColor,
        ),
      ),
    ),
  ),
                                    
                                    // ✅ ماركر المستخدم
                                    if (_userPosition != null)
                                      Positioned(
                                        left: _userPosition!.dx * imageSize.width - 12,
                                        top: _userPosition!.dy * imageSize.height - 24,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: _userMarkerColor,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'You',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 0,
                                              height: 0,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: _userMarkerColor,
                                                    width: 8,
                                                  ),
                                                  left: BorderSide(color: Colors.transparent, width: 6),
                                                  right: BorderSide(color: Colors.transparent, width: 6),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: _userMarkerColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // ✅ ماركرات المتاجر (الموجودة أصلاً)
                                    ..._filteredStores.map((store) {
                                      if (store.x == null || store.y == null) {
                                        return const SizedBox();
                                      }

                                      final left = store.x! * imageSize.width;
                                      final top = store.y! * imageSize.height;
                                      const double markerSize = 20.0; // أو أي حجم تريده

                                      // تمييز المحل المحدد للمسار
                                      final isSelectedStore = _selectedStore?.id == store.id;
                                      final markerColor = isSelectedStore ? _storeMarkerColor : (store.isActive ? Colors.red : Colors.grey);

                                      return Positioned(
                                        left: left,
                                        top: top,
                                        child: MapMarker(
                                          label: store.getName(locale),
                                          isActive: store.isActive,
                                          isSelected: isSelectedStore,
                                          onTap: () => _showStoreBottomSheet(store),
                                          size: markerSize,
                                          markerColor: markerColor,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isShowingRoute)
FloatingActionButton(
  mini: true,
  backgroundColor: _isPickingLocation ? Colors.orange : Colors.green,
  onPressed: () {
    setState(() {
      _isPickingLocation = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('tap_on_map_to_set_your_location'.tr()),
        duration: const Duration(seconds: 3),
      ),
    );
  },
  child: Icon(
    _isPickingLocation ? Icons.gps_fixed : Icons.my_location,
    color: Colors.white,
  ),
),
          if (_isShowingRoute)
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

// ✅ // ✅ كلاس رسم المسار المبسط (النسخة الأساسية العاملة)
class RoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  RoutePainter({
    required this.start,
    required this.end,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // ✅ رسم الخط المستقيم الأساسي
    canvas.drawLine(start, end, paint);
    
    // ✅ رسم دائرة في البداية (موقع المستخدم)
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 8, startPaint);
    canvas.drawCircle(start, 4, Paint()..color = Colors.white);
    
    // ✅ رسم دائرة في النهاية (موقع المحل)
    final endPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(end, 8, endPaint);
    canvas.drawCircle(end, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.start != start || 
           oldDelegate.end != end;
  }
}

// ✅ ماركر محسن مع دعم التحديد
class MapMarker extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isSelected;
  final double size;
  final Color markerColor;
  final VoidCallback? onTap;

  const MapMarker({
    super.key,
    required this.label,
    this.isActive = true,
    this.isSelected = false,
    this.size = 30,
    this.markerColor = Colors.red,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: size * 0.3,
          vertical: size * 0.1,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : markerColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(Icons.star, color: Colors.white, size: 12),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.4,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}