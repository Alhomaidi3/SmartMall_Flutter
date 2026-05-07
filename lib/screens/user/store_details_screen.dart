import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '/widgets/widgets.dart';
import '/services/store_service.dart';
import '/models/store.dart';

class StoreDetailsScreen extends StatefulWidget {
  final int storeId;

  const StoreDetailsScreen({super.key, required this.storeId});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  final StoreService _storeService = StoreService();
  
  StoreDetailsDto? _store;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final store = await _storeService.getStoreById(
        widget.storeId,
        language: context.locale.languageCode,
      );
      if (mounted) {
        setState(() {
          _store = store;
          _isFavorite = store.isFavorite;
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

  Future<void> _toggleFavorite() async {
    if (_store == null) return;

    setState(() => _isFavorite = !_isFavorite);

    try {
      if (_isFavorite) {
        await _storeService.addToFavorites(_store!.id);
      } else {
        await _storeService.removeFromFavorites(_store!.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFavorite = !_isFavorite);
        showMessage(
          context,
          e.toString().replaceAll('Exception: ', ''),
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final phone = _store?.phone;
    if (phone == null || phone.isEmpty) return;
    
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchWebsite() async {
    final website = _store?.website;
    if (website == null || website.isEmpty) return;
    
    var url = website;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToMapWithStore() {
    Navigator.pop(context, {
      'navigateToMap': true,
      'storeId': _store!.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CustomAppBar(
        title: 'store_details'.tr(),
        showBackButton: true,
        showProfileIcon: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStoreDetails,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : _store == null
                  ? Center(child: Text('store_not_found'.tr()))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStoreInfoCard(isDark, textTheme, locale),
                          const SizedBox(height: 24),
                          _buildDetailsHeader(),
                          const SizedBox(height: 12),
                          _buildStoreDetailsCard(isDark),
                          _buildPhoneCard(isDark, scheme),
                          _buildWebsiteCard(isDark, scheme),
                          const SizedBox(height: 24),
                          _buildActionButtons(scheme),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStoreInfoCard(bool isDark, TextTheme textTheme, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _store!.imageUrl != null
                ? Image.network(
                    _store!.imageUrl!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 240,
                      color: Colors.grey[300],
                      child: const Icon(Icons.store, size: 80),
                    ),
                  )
                : Container(
                    height: 240,
                    color: Colors.grey[300],
                    child: const Icon(Icons.store, size: 80),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            _store!.getName(locale),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _store!.getDescription(locale) ?? '',
            style: textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsHeader() {
    return Text(
      'store_details'.tr(),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStoreDetailsCard(bool isDark) {
    final locale = context.locale.languageCode;
    
    return Card(
      color: isDark ? Colors.grey[850] : Colors.grey[200],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'category'.tr(),
              _store!.getCategoryName(locale) ?? '—',
              isDark,
            ),
            const Divider(),
            _buildInfoRow(
              'floor'.tr(),
              '${_store!.floor}',
              isDark,
            ),
            const Divider(),
            _buildInfoRow(
              'open_hours'.tr(),
              _store!.openHours ?? '—',
              isDark,
            ),
            const Divider(),
            _buildInfoRow(
              'rating'.tr(),
              _store!.ratingsCount == 0
                  ? 'no_ratings_yet'.tr()
                  : '${_store!.averageRating.toStringAsFixed(1)} (${_store!.ratingsCount} ${'reviews'.tr()})',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCard(bool isDark, ColorScheme scheme) {
    if (_store!.phone == null || _store!.phone!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: _launchPhone,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.phone, color: scheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'phone_number'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _store!.phone!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebsiteCard(bool isDark, ColorScheme scheme) {
    if (_store!.website == null || _store!.website!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: _launchWebsite,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: scheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'website'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _store!.website!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _navigateToMapWithStore,
            icon: const Icon(Icons.directions),
            label: Text('directions'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            label: Text(
              _isFavorite ? 'remove_from_favorites'.tr() : 'add_to_favorites'.tr(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}