import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/view_model/content_viewmodel.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:uptrail/utils/app_spacing.dart';

import '../utils/app_text_style.dart';

class LeadStatusPage extends StatefulWidget {
  const LeadStatusPage({super.key});

  @override
  State<LeadStatusPage> createState() => _LeadStatusPageState();
}

class _LeadStatusPageState extends State<LeadStatusPage> {
  bool _hasTriedApiLoad = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling API during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubmittedLeads();
    });
  }

  Future<void> _loadSubmittedLeads() async {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    
    try {
      print('📋 Loading submitted leads from API...');
      await contentViewModel.fetchMyLeads(forceRefresh: true);
      _hasTriedApiLoad = true;
      print('📋 Successfully loaded leads from API');
    } catch (e) {
      print('📋 API load failed, trying local storage fallback: $e');
      _hasTriedApiLoad = true;
      // Fallback will be handled in the build method by checking if userLeads is empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Applications',
          style: AppTextStyle.headline2,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _loadSubmittedLeads,
          ),
        ],
      ),
      body: Consumer<ContentViewModel>(
        builder: (context, contentViewModel, child) {
          final isLoading = contentViewModel.isLeadsLoading || !_hasTriedApiLoad;
          final userLeads = contentViewModel.userLeads;
          final error = contentViewModel.error;

          return RefreshIndicator(
            onRefresh: _loadSubmittedLeads,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? _buildErrorState(error)
                    : userLeads.isEmpty
                        ? _buildEmptyState()
                        : _buildLeadsList(userLeads),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.champagnePink,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.large,
            const Text(
              'Unable to Load Applications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.medium,
            Text(
              error,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.large,
            ElevatedButton(
              onPressed: _loadSubmittedLeads,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightPinkCrayola,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.champagnePink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.description_outlined,
                size: 60,
                color: AppColors.brightPinkCrayola.withValues(alpha: 0.6),
              ),
            ),
            AppSpacing.large,
            const Text(
              'No Applications Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.medium,
            Text(
              'You haven\'t submitted any course applications yet. Start your learning journey by submitting an application!',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.large,
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightPinkCrayola,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsList(List<UserLead> userLeads) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: userLeads.length,
      itemBuilder: (context, index) {
        final lead = userLeads[index];
        return _buildLeadCard(lead);
      },
    );
  }

  Widget _buildLeadCard(UserLead lead) {
    final submittedAt = lead.submittedAt;
    final status = lead.status;
    final localStorageFormat = lead.toLocalStorageFormat();
    final nextSteps = List<String>.from(localStorageFormat['nextSteps']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with reference and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ref: LD${lead.id}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied: ${_formatDate(submittedAt)}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(status).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusDisplayName(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          AppSpacing.medium,
          
          // Application Details
          _buildDetailRow(
            icon: Icons.person,
            label: 'Name',
            value: lead.name,
          ),
          AppSpacing.small,
          _buildDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: lead.email,
          ),
          AppSpacing.small,
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: lead.phone,
          ),
          AppSpacing.small,
          _buildDetailRow(
            icon: Icons.interests,
            label: 'Interest',
            value: _formatAreaOfInterest(lead.areaOfInterest),
          ),
          
          AppSpacing.medium,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.logoDarkTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.logoDarkTeal.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.logoDarkTeal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expected Contact: ${lead.contactedAt != null ? 'Contacted' : 'within 24 hours'}',
                  style: TextStyle(
                    color: AppColors.logoDarkTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          if (nextSteps.isNotEmpty) ...[
            AppSpacing.medium,
            const Text(
              'Next Steps:',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.small,
            ...nextSteps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.brightPinkCrayola,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.black54,
          size: 18,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'contacted':
        return Colors.orange;
      case 'in_progress':
        return Colors.purple;
      case 'enrolled':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.send;
      case 'contacted':
        return Icons.phone;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'enrolled':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'contacted':
        return 'Contacted';
      case 'in_progress':
        return 'In Progress';
      case 'enrolled':
        return 'Enrolled';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatAreaOfInterest(String areaOfInterest) {
    final formatted = areaOfInterest.replaceAll('_', ' ');
    return formatted.split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }
}