import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../controllers/auction_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common/loading_widget.dart';

class SellerAuctionProductView extends StatefulWidget {
  const SellerAuctionProductView({Key? key}) : super(key: key);

  @override
  State<SellerAuctionProductView> createState() => _SellerAuctionProductViewState();
}

class _SellerAuctionProductViewState extends State<SellerAuctionProductView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _endTimeController = TextEditingController();
  
  File? _selectedImage;
  DateTime? _selectedEndTime;
  bool _isCreating = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Auction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Selection Section
                _buildImageSection(),
                const SizedBox(height: 24),

                // Auction Details Form
                _buildAuctionDetailsForm(),
                const SizedBox(height: 24),

                // End Time Selection
                _buildEndTimeSection(),
                const SizedBox(height: 32),

                // Create Auction Button
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auction Image',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to select auction image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auction Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Title Field
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Auction Title',
            prefixIcon: Icon(Icons.title),
            border: OutlineInputBorder(),
            hintText: 'Enter auction title',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter auction title';
            }
            if (value.length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description Field
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Icons.description),
            border: OutlineInputBorder(),
            hintText: 'Enter auction description',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter description';
            }
            if (value.length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Starting Price Field
        TextFormField(
          controller: _startingPriceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Starting Price (Rs.)',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
            hintText: 'Enter starting price',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter starting price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEndTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Auction End Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedEndTime != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedEndTime!)
                        : 'Select auction end time',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedEndTime != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Consumer<AuctionController>(
      builder: (context, auctionController, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isCreating || auctionController.isLoading)
                ? null
                : _createAuction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCreating || auctionController.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingWidget.circular(size: 20, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Creating Auction...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Create Auction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Error selecting image: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Validate that end time is at least 1 hour from now
        if (selectedDateTime.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
          setState(() {
            _selectedEndTime = selectedDateTime;
            _endTimeController.text = DateFormat('MMM dd, yyyy - hh:mm a').format(selectedDateTime);
          });
        } else {
          _showErrorDialog('Auction end time must be at least 1 hour from now');
        }
      }
    }
  }

  Future<void> _createAuction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showErrorDialog('Please select an image for the auction');
      return;
    }

    if (_selectedEndTime == null) {
      _showErrorDialog('Please select an end time for the auction');
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    if (authController.currentUser == null) {
      _showErrorDialog('You must be logged in to create an auction');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final auctionController = Provider.of<AuctionController>(context, listen: false);
      
      // For now, we'll use a placeholder image URL
      // In a real app, you'd upload the image to Firebase Storage first
      final imageUrls = [_selectedImage!.path]; // This should be uploaded URL
      
      final success = await auctionController.createAuction(
        productId: 'product_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startingPrice: double.parse(_startingPriceController.text),
        sellerId: authController.currentUser!.id,
        endTime: _selectedEndTime!,
        imageUrls: imageUrls,
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(auctionController.error ?? 'Failed to create auction');
      }
    } catch (e) {
      _showErrorDialog('Error creating auction: $e');
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success!'),
          ],
        ),
        content: const Text('Your auction has been created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}