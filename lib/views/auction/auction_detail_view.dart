import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/routes.dart';
import '../../controllers/auction_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/models.dart';
import '../../widgets/common/loading_widget.dart';

class AuctionDetailView extends StatefulWidget {
  final String auctionId;

  const AuctionDetailView({super.key, required this.auctionId});

  @override
  State<AuctionDetailView> createState() => _AuctionDetailViewState();
}

class _AuctionDetailViewState extends State<AuctionDetailView> {
  final TextEditingController _bidController = TextEditingController();
  Timer? _timer;
  Auction? auction;
  bool _isPlacingBid = false;
  static const double _minimumBidIncrement = 5.0; // Default minimum increment

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuctionDetails();
    });

    // Update countdown timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _bidController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAuctionDetails() async {
    final auctionController =
        Provider.of<AuctionController>(context, listen: false);
    final fetchedAuction = await auctionController.getAuction(widget.auctionId);

    if (fetchedAuction != null && mounted) {
      setState(() {
        auction = fetchedAuction;
        _bidController.text = (fetchedAuction.currentBid + _minimumBidIncrement)
            .toStringAsFixed(2);
      });
    }
  }

  Future<void> _placeBid() async {
    if (auction == null) return;

    final authController = Provider.of<AuthController>(context, listen: false);
    final auctionController =
        Provider.of<AuctionController>(context, listen: false);

    if (authController.currentUser == null) {
      _showLoginDialog();
      return;
    }

    final bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null) {
      _showErrorSnackBar('Please enter a valid bid amount');
      return;
    }

    if (bidAmount <= auction!.currentBid) {
      _showErrorSnackBar('Bid must be higher than current bid');
      return;
    }

    if (bidAmount < auction!.currentBid + _minimumBidIncrement) {
      _showErrorSnackBar(
          'Bid must be at least Rs. ${(auction!.currentBid + _minimumBidIncrement).toStringAsFixed(2)}');
      return;
    }

    setState(() {
      _isPlacingBid = true;
    });

    try {
      final success = await auctionController.placeBid(
        auctionId: auction!.id,
        bidderId: authController.currentUser!.id,
        bidAmount: bidAmount,
      );

      if (success && mounted) {
        _showSuccessSnackBar('Bid placed successfully!');
        await _loadAuctionDetails(); // Refresh auction data

        // Update bid controller with next minimum bid
        _bidController.text =
            (auction!.currentBid + auction!.minimumBidIncrement)
                .toStringAsFixed(2);
      } else if (mounted) {
        _showErrorSnackBar(
            auctionController.errorMessage ?? 'Failed to place bid');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingBid = false;
        });
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to login to place a bid.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          auction?.title ?? 'Auction Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: auction == null
          ? Center(child: LoadingWidget.circular(size: 40))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  _buildAuctionInfo(),
                  _buildBidSection(),
                  _buildBidHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Image.network(
            auction!.primaryImageUrl,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.image,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          // Status overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isAuctionActive() ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isAuctionActive() ? 'LIVE AUCTION' : 'AUCTION ENDED',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            auction!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            auction!.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Price information
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Current Bid',
                  'Rs. ${auction!.currentBid.toStringAsFixed(2)}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Starting Price',
                  'Rs. ${auction!.startingPrice.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Bids',
                  '${auction!.bids.length}',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Min. Increment',
                  'Rs. ${auction!.minimumBidIncrement.toStringAsFixed(2)}',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time remaining
          _buildTimeRemainingCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    final timeRemaining = _getTimeRemaining();
    final isExpired = timeRemaining['expired'] as bool;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red[200]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            isExpired ? 'Auction Ended' : 'Time Remaining',
            style: TextStyle(
              fontSize: 14,
              color: isExpired ? Colors.red[700] : Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (!isExpired) ...[
            Text(
              _formatTimeRemaining(timeRemaining),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ] else ...[
            Text(
              'Ended ${_formatDate(auction!.endTime)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBidSection() {
    if (!_isAuctionActive()) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'This auction has ended. No more bids can be placed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Place Your Bid',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bidController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Bid Amount (Rs.)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter your bid amount',
                    helperText:
                        'Minimum: Rs. ${(auction!.currentBid + auction!.minimumBidIncrement).toStringAsFixed(2)}',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: _isPlacingBid ? null : _placeBid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isPlacingBid
                      ? LoadingWidget.circular(size: 20)
                      : const Text(
                          'Bid Now',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidHistory() {
    if (auction!.bids.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No bids placed yet. Be the first to bid!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    // Sort bids by timestamp (most recent first)
    final sortedBids = List<AuctionBid>.from(auction!.bids)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bid History (${auction!.bids.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedBids.length > 10
                ? 10
                : sortedBids.length, // Show max 10 bids
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final bid = sortedBids[index];
              final isHighestBid = index == 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isHighestBid ? Colors.green : Colors.grey[300],
                  child: Icon(
                    isHighestBid ? Icons.emoji_events : Icons.gavel,
                    color: isHighestBid ? Colors.white : Colors.grey[600],
                  ),
                ),
                title: Text(
                  'Rs. ${bid.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight:
                        isHighestBid ? FontWeight.bold : FontWeight.normal,
                    color: isHighestBid ? Colors.green : null,
                  ),
                ),
                subtitle: Text(
                  _formatBidTime(bid.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: isHighestBid
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Highest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),
          if (sortedBids.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  '... and ${sortedBids.length - 10} more bids',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isAuctionActive() {
    return DateTime.now().isBefore(auction!.endTime);
  }

  Map<String, dynamic> _getTimeRemaining() {
    final now = DateTime.now();
    final difference = auction!.endTime.difference(now);

    if (difference.isNegative) {
      return {'expired': true};
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return {
      'expired': false,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  String _formatTimeRemaining(Map<String, dynamic> timeRemaining) {
    if (timeRemaining['expired'] == true) return 'Expired';

    final days = timeRemaining['days'] as int;
    final hours = timeRemaining['hours'] as int;
    final minutes = timeRemaining['minutes'] as int;
    final seconds = timeRemaining['seconds'] as int;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatBidTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
