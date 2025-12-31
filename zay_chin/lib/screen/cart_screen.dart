import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zay_chin/api/models/cart.dart';
import 'package:zay_chin/api/realtime/cart_realtime.dart';
import 'package:zay_chin/api/services/cart_service.dart';
import 'package:zay_chin/api/services/group_service.dart';
import 'package:zay_chin/widget/cart/cart_item_card.dart';
import 'package:zay_chin/widget/cart/cart_item_edit_card.dart';
import 'package:zay_chin/widget/cart/category_picker_sheet.dart';
import 'package:zay_chin/widget/cart/location_picker_sheet.dart';
import 'package:zay_chin/widget/cart/new_cart_item_row.dart';

class CartScreen extends StatefulWidget {
  final String groupId;

  const CartScreen({super.key, required this.groupId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final GroupService _groupService = GroupService();
  CartRealtime? _realtime;
  StreamSubscription<List<CartItem>>? _subscription;

  List<CartItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController(
    text: '0',
  );
  int _newQuantity = 1;
  String _newCategory = 'General';
  double? _newLat;
  double? _newLng;
  String? _newLocationName;

  final List<String> _categories = const [
    'General',
    'Produce',
    'Dairy',
    'Snacks',
    'Household',
    'Other',
  ];

  String? _editingItemId;
  TextEditingController? _editNameController;
  TextEditingController? _editPriceController;
  int _editQuantity = 1;
  String _editCategory = 'General';

  @override
  void initState() {
    super.initState();
    _initRealtime();
  }

  Future<void> _initRealtime() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _realtime = CartRealtime(_cartService);
      
      // Set up subscription BEFORE connecting to catch initial data
      _subscription = _realtime!.stream.listen(
        (items) {
          if (mounted) {
            setState(() {
              items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              _items = items;
              // Always clear loading when we receive data
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
              _isLoading = false;
            });
          }
        },
      );
      
      // Now connect, which will emit initial data
      // The initial data should be received by the listener above
      await _realtime!.connect(widget.groupId);
      
      // Additional safety: ensure loading is cleared after connect completes
      // This handles the case where the stream might have already emitted
      if (mounted && _isLoading) {
        // Give a tiny delay to let the stream listener execute
        await Future.delayed(const Duration(milliseconds: 50));
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _realtime?.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _realtime?.refresh();
  }

  Future<void> _pickCategoryCupertino() async {
    await showCategoryPickerSheet(
      context: context,
      currentCategory: _newCategory,
      categories: _categories,
      onCategorySelected: (category) {
                    setState(() {
          _newCategory = category;
                    });
                  },
    );
  }

  Future<void> _pickLocation() async {
    await showLocationPickerSheet(
      context: context,
      initialLat: _newLat,
      initialLng: _newLng,
      initialName: _newLocationName,
      onPicked: (lat, lng, name) {
        setState(() {
          _newLat = lat;
          _newLng = lng;
          _newLocationName = name;
        });
      },
    );
  }

  Future<void> _submitNewItem() async {
    FocusScope.of(context).unfocus();
    final name = _newNameController.text.trim();
    final price = int.tryParse(_newPriceController.text) ?? 0;
    if (name.isEmpty) return;

    try {
      await _cartService.addItem(
        groupId: widget.groupId,
      name: name,
      category: _newCategory,
      quantity: _newQuantity,
      price: price,
        locationLat: _newLat,
        locationLng: _newLng,
        locationName: _newLocationName,
    );

    _newNameController.clear();
    _newPriceController.text = '0';
    _newQuantity = 1;
      _newLat = null;
      _newLng = null;
      _newLocationName = null;

      // Realtime will update automatically
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add item: $e')));
      }
    }
  }

  void _startEdit(CartItem item) {
    setState(() {
      _editingItemId = item.id;
      _editNameController ??= TextEditingController();
      _editPriceController ??= TextEditingController();
      _editNameController!.text = item.itemName;
      _editPriceController!.text = item.price.toString();
      _editQuantity = item.quantity;
      _editCategory = item.category;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingItemId = null;
    });
  }

  Future<void> _saveEdit(String itemId) async {
    final name = _editNameController?.text.trim() ?? '';
    final price = int.tryParse(_editPriceController?.text ?? '') ?? 0;
    final quantity = _editQuantity.clamp(1, 999);

    await _cartService.updateItem(
      groupId: widget.groupId,
      id: itemId,
      name: name.isEmpty ? null : name,
      price: price,
      quantity: quantity,
      category: _editCategory,
    );

    setState(() {
      _editingItemId = null;
    });
    // Realtime will update automatically
  }

  Future<void> _showInviteDialog() async {
    final emailController = TextEditingController();
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invite to group'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'user@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;
                try {
                  await _groupService.inviteToGroup(widget.groupId, email);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Invite sent')));
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupId = widget.groupId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          CupertinoButton(
            onPressed: _showInviteDialog,
            child: const Icon(CupertinoIcons.share),
      ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: Builder(
                  builder: (context) {
                    if (_isLoading && _items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (_errorMessage != null && _items.isEmpty) {
                      return Center(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (_items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text('Cart is empty. Add an item below.'),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final isEditing = item.id == _editingItemId;

                        if (isEditing && _editNameController != null) {
                          return CartItemEditCard(
                            nameController: _editNameController!,
                            priceController: _editPriceController!,
                            quantity: _editQuantity,
                            category: _editCategory,
                            onQuantityChanged: (val) {
                                                          setState(() {
                                _editQuantity = val.clamp(1, 999);
                                                          });
                                                        },
                            onCategoryTap: () async {
                              await showCategoryPickerSheet(
                                context: context,
                                currentCategory: _editCategory,
                                categories: _categories,
                                onCategorySelected: (category) {
                                  setState(() {
                                    _editCategory = category;
                                  });
                                            },
                                          );
                                        },
                            onCancel: _cancelEdit,
                            onSave: () => _saveEdit(item.id),
                          );
                        }

                        return CartItemCard(
                          item: item,
                          onEdit: () => _startEdit(item),
                          onDecrement: () async {
                            final nextCurrent = item.current - 1;
                            await _cartService.updateItem(
                              groupId: groupId,
                                                id: item.id,
                                                current: nextCurrent,
                                              );
                            // Realtime will update automatically
                          },
                          onIncrement: () async {
                            final nextCurrent = item.current + 1;
                            await _cartService.updateItem(
                              groupId: groupId,
                                                id: item.id,
                                                current: nextCurrent,
                                              );
                            // Realtime will update automatically
                          },
                          onDelete: () async {
                            final index = _items.indexWhere((it) => it.id == item.id);
                            if (index < 0) return;
                            final removed = _items[index];
                            setState(() {
                              _items.removeAt(index);
                              if (_editingItemId == removed.id) {
                                _editingItemId = null;
                              }
                            });
                            try {
                              await _cartService.removeItem(
                                groupId: groupId,
                                id: removed.id,
                              );
                              // Realtime will update automatically
                            } catch (e) {
                              setState(() {
                                _items.insert(index, removed);
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to delete: $e')),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            NewCartItemRow(
              nameController: _newNameController,
              priceController: _newPriceController,
              quantity: _newQuantity,
              category: _newCategory,
              locationLabel: _newLocationName,
              onQuantityChanged: (value) {
                setState(() {
                  _newQuantity = value.clamp(1, 999);
                });
              },
              onCategoryTap: _pickCategoryCupertino,
              onLocationTap: _pickLocation,
              onSubmit: _submitNewItem,
            ),
          ],
        ),
      ),
    );
  }
}
