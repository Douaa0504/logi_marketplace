import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/product_inventory_option_entity.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class AddProductPage extends StatefulWidget {
  final ProductEntity? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _simpleStockController = TextEditingController();

  String _selectedCategory = 'Electronics';
  File? _selectedImage;
  String _inventoryMode = 'simple';
  bool _inventoryLoading = false;
  final List<_VariantInventoryInput> _variantInputs = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home',
    'Beauty',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _titleController.text = product.title;
      _descriptionController.text = product.description ?? '';
      _priceController.text = product.price.toString();
      _selectedCategory = product.category;
      if (!_categories.contains(product.category)) {
        _categories.add(product.category);
      }
      _inventoryLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInventory());
    }
  }

  Future<void> _loadInventory() async {
    try {
      final inventory = await context
          .read<ProductCubit>()
          .getSellerProductInventory(widget.product!.id);
      if (!mounted) return;
      final options = (inventory['options'] as List<dynamic>? ?? [])
          .map((option) => Map<String, dynamic>.from(option as Map))
          .where((option) => option['is_available'] == true)
          .toList();
      setState(() {
        _inventoryMode = inventory['mode'] as String? ?? 'unconfigured';
        if (_inventoryMode == 'simple') {
          final simpleOption = options.where(
            (option) => option['color'] == null && option['size'] == null,
          );
          if (simpleOption.isNotEmpty) {
            _simpleStockController.text =
                simpleOption.first['stock_quantity'].toString();
          }
        } else if (_inventoryMode == 'variants') {
          for (final option in options) {
            _variantInputs.add(
              _VariantInventoryInput(
                color: option['color'] as String? ?? '',
                size: option['size'] as String? ?? '',
                quantity: option['stock_quantity'].toString(),
              ),
            );
          }
        } else {
          _inventoryMode = 'simple';
        }
        _inventoryLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _inventoryLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load inventory: $error')),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitProduct() {
    if (!_formKey.currentState!.validate()) return;
    if (_inventoryLoading) return;

    final inventoryOptions = <ProductInventoryOptionEntity>[];
    if (_inventoryMode == 'simple') {
      final quantity = int.tryParse(_simpleStockController.text.trim());
      if (quantity == null || quantity < 0) {
        _showInventoryError('Enter a non-negative whole-number stock quantity.');
        return;
      }
      inventoryOptions.add(
        ProductInventoryOptionEntity(
          id: '',
          isAvailable: true,
          isInStock: quantity > 0,
          stockQuantity: quantity,
        ),
      );
    } else {
      if (_variantInputs.isEmpty) {
        _showInventoryError('Add at least one product variant.');
        return;
      }
      final combinations = <String>{};
      for (final input in _variantInputs) {
        final color = input.color.text.trim();
        final size = input.size.text.trim();
        final quantity = int.tryParse(input.quantity.text.trim());
        if ((color.isEmpty && size.isEmpty) ||
            quantity == null ||
            quantity < 0) {
          _showInventoryError(
            'Each variant needs a color or size and a non-negative whole-number quantity.',
          );
          return;
        }
        if (!combinations.add('$color\u0000$size')) {
          _showInventoryError('Variant color and size combinations must be unique.');
          return;
        }
        inventoryOptions.add(
          ProductInventoryOptionEntity(
            id: '',
            color: color.isEmpty ? null : color,
            size: size.isEmpty ? null : size,
            isAvailable: true,
            isInStock: quantity > 0,
            stockQuantity: quantity,
          ),
        );
      }
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final product = widget.product;

    if (product != null) {
      context.read<ProductCubit>().updateProduct(
        product: product,
        title: title,
        description: description,
        price: price,
        category: _selectedCategory,
        inventoryMode: _inventoryMode,
        inventoryOptions: inventoryOptions,
        imageFile: _selectedImage,
      );
    } else {
      context.read<ProductCubit>().addProduct(
        title: title,
        description: description,
        price: price,
        category: _selectedCategory,
        sellerId: currentUser.id,
        inventoryMode: _inventoryMode,
        inventoryOptions: inventoryOptions,
        imageFile: _selectedImage,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _simpleStockController.dispose();
    for (final input in _variantInputs) {
      input.dispose();
    }
    super.dispose();
  }

  void _showInventoryError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add New Product' : 'Edit Product'),
      ),
      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.product == null
                      ? 'Product added successfully!'
                      : 'Product updated successfully!',
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ProductFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.product?.remoteImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.product!.remoteImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.image_not_supported_outlined,
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text('Tap to select product image'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Product Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Price is required';
                    if (double.tryParse(v) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Inventory',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _inventoryMode,
                  decoration: const InputDecoration(
                    labelText: 'Product type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'simple', child: Text('Simple stock')),
                    DropdownMenuItem(value: 'variants', child: Text('Color/size variants')),
                  ],
                  onChanged: _inventoryLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _inventoryMode = value);
                          }
                        },
                ),
                const SizedBox(height: 12),
                if (_inventoryLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_inventoryMode == 'simple')
                  TextFormField(
                    controller: _simpleStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available quantity',
                      helperText: 'Enter 0 to mark this product out of stock.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_inventoryMode != 'simple') return null;
                      if (value == null || !RegExp(r'^\d+$').hasMatch(value)) {
                        return 'Enter a whole-number quantity of 0 or more.';
                      }
                      return null;
                    },
                  )
                else
                  _buildVariantEditor(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is ProductLoading || _inventoryLoading
                          ? null
                          : _submitProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: state is ProductLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              widget.product == null
                                  ? 'Publish Product'
                                  : 'Save Changes',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariantEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _variantInputs.length; index++)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Variant ${index + 1}')),
                      IconButton(
                        tooltip: 'Remove variant',
                        onPressed: () {
                          final removed = _variantInputs.removeAt(index);
                          removed.dispose();
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _variantInputs[index].color,
                          decoration: const InputDecoration(labelText: 'Color'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _variantInputs[index].size,
                          decoration: const InputDecoration(labelText: 'Size'),
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _variantInputs[index].quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Available quantity',
                      helperText: 'Enter 0 to mark this variant out of stock.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(
            () => _variantInputs.add(_VariantInventoryInput()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add variant'),
        ),
      ],
    );
  }
}

class _VariantInventoryInput {
  final TextEditingController color;
  final TextEditingController size;
  final TextEditingController quantity;

  _VariantInventoryInput({String color = '', String size = '', String quantity = ''})
    : color = TextEditingController(text: color),
      size = TextEditingController(text: size),
      quantity = TextEditingController(text: quantity);

  void dispose() {
    color.dispose();
    size.dispose();
    quantity.dispose();
  }
}
