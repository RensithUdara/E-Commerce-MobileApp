import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/seller_controller.dart';
import '../../widgets/common/loading_widget.dart';

class SellerProfileView extends StatefulWidget {
  const SellerProfileView({Key? key}) : super(key: key);

  @override
  State<SellerProfileView> createState() => _SellerProfileViewState();
}

class _SellerProfileViewState extends State<SellerProfileView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isEditing = false;
  bool _isUpdating = false;

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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      // Bio field would need to be added to User model in real app
      _bioController.text = 'Passionate seller of quality jewelry and gemstones.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Seller Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white,
            ),
            onPressed: _isUpdating ? null : _toggleEdit,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              // Statistics Cards
              _buildStatsSection(),
              
              // Profile Form
              _buildProfileForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name and Title
          Consumer<AuthController>(
            builder: (context, authController, child) {
              return Column(
                children: [
                  Text(
                    authController.currentUser?.name ?? 'Seller Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verified Seller',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Consumer<SellerController>(
        builder: (context, sellerController, child) {
          final stats = sellerController.sellerStats;
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Products',
                  '${stats['totalProducts'] ?? 0}',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Auctions',
                  '${stats['totalAuctions'] ?? 0}',
                  Icons.gavel,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Orders',
                  '${stats['totalOrders'] ?? 0}',
                  Icons.shopping_bag,
                  Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Name Field
            _buildFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            _buildFormField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              enabled: false, // Email usually can't be changed
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Phone Field
            _buildFormField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address Field
            _buildFormField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              enabled: _isEditing,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Bio Field
            _buildFormField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info,
              enabled: _isEditing,
              maxLines: 3,
            ),
            
            if (_isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _cancelEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isUpdating
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingWidget.circular(size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                const Text('Saving...'),
                              ],
                            )
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reset form data
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // In a real app, you would update the user profile through AuthController
      final authController = Provider.of<AuthController>(context, listen: false);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
}