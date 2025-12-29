import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zay_chin/api/models/cart.dart';
import 'package:zay_chin/api/services/cart_service.dart';
import 'package:zay_chin/api/services/group_service.dart';
import 'package:zay_chin/widget/cart/cart_item_card.dart';
import 'package:zay_chin/widget/cart/cart_item_edit_card.dart';
import 'package:zay_chin/widget/cart/category_picker_sheet.dart';
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

  List<CartItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _newNameController = TextEditingController();
  final TextEditingController _newPriceController = TextEditingController(
    text: '0',
  );
  int _newQuantity = 1;
  String _newCategory = 'General';

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
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      if (_items.isEmpty) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
      final items = await _cartService.getCart(widget.groupId);
      items.sort((a, b) => a.id.compareTo(b.id));
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
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

  Future<void> _refresh() async {
    await _loadItems();
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

  Future<void> _submitNewItem() async {
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
      );

      _newNameController.clear();
      _newPriceController.text = '0';
      _newQuantity = 1;

      await _refresh();
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
    _refresh();
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
                            _refresh();
                          },
                          onIncrement: () async {
                            final nextCurrent = item.current + 1;
                            await _cartService.updateItem(
                              groupId: groupId,
                              id: item.id,
                              current: nextCurrent,
                            );
                            _refresh();
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
                              await _refresh();
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
              onQuantityChanged: (value) {
                setState(() {
                  _newQuantity = value.clamp(1, 999);
                });
              },
              onCategoryTap: _pickCategoryCupertino,
              onSubmit: _submitNewItem,
            ),
          ],
        ),
      ),
    );
  }
}
