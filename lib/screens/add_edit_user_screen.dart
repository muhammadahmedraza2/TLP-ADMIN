import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserModel? existingUser;

  const AddEditUserScreen({super.key, this.existingUser});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController cnicCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController districtCtrl;
  late final TextEditingController unionCouncilCtrl;
  late final TextEditingController chargeCtrl;
  late final TextEditingController psConstituencyIdCtrl;
  bool _isSaving = false;

  bool get isEditMode => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    final user = widget.existingUser;
    nameCtrl = TextEditingController(text: user?.name ?? '');
    emailCtrl = TextEditingController(text: user?.email ?? '');
    cnicCtrl = TextEditingController(text: user?.cnic ?? '');
    phoneCtrl = TextEditingController(text: user?.phone ?? '');
    districtCtrl = TextEditingController(text: user?.district ?? '');
    unionCouncilCtrl = TextEditingController(
      text: (user?.unionCouncil ?? 0).toString(),
    );
    chargeCtrl = TextEditingController(text: (user?.charge ?? 0).toString());
    psConstituencyIdCtrl = TextEditingController(
      text: (user?.psConstituencyId ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    cnicCtrl.dispose();
    phoneCtrl.dispose();
    districtCtrl.dispose();
    unionCouncilCtrl.dispose();
    chargeCtrl.dispose();
    psConstituencyIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final user = UserModel(
      id: widget.existingUser?.id,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      cnic: cnicCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      district: districtCtrl.text.trim(),
      unionCouncil: int.parse(unionCouncilCtrl.text.trim()),
      charge: int.parse(chargeCtrl.text.trim()),
      psConstituencyId: int.parse(psConstituencyIdCtrl.text.trim()),
    );

    try {
      if (isEditMode) {
        await ApiService.updateUser(widget.existingUser!.id!, user);
      } else {
        await ApiService.addUser(user);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return '$label is required';
        if (text.isNotEmpty && keyboardType == TextInputType.number) {
          if (int.tryParse(text) == null) return 'Enter a valid whole number';
        }
        if (text.isNotEmpty && keyboardType == TextInputType.emailAddress) {
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
            return 'Enter a valid email address';
          }
        }
        return null;
      },
    );
  }

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.emerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldGrid(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 2 : 1;
        final width = (constraints.maxWidth - 14 * (columns - 1)) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: fields
              .map((field) => SizedBox(width: width, child: field))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit volunteer' : 'Add volunteer';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  Text(
                    isEditMode
                        ? 'Update details'
                        : 'Create a volunteer profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep contact and constituency information up to date.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Personal information',
                            'Volunteer name and contact details',
                            Icons.person_outline_rounded,
                          ),
                          _fieldGrid([
                            _buildField(
                              controller: nameCtrl,
                              label: 'Full name',
                              icon: Icons.badge_outlined,
                            ),
                            _buildField(
                              controller: emailCtrl,
                              label: 'Email address',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _buildField(
                              controller: phoneCtrl,
                              label: 'Phone number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            _buildField(
                              controller: cnicCtrl,
                              label: 'CNIC',
                              icon: Icons.credit_card_outlined,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Area & constituency',
                            'Local team and electoral area details',
                            Icons.location_on_outlined,
                          ),
                          _fieldGrid([
                            _buildField(
                              controller: districtCtrl,
                              label: 'District',
                              icon: Icons.map_outlined,
                            ),
                            _buildField(
                              controller: unionCouncilCtrl,
                              label: 'Union Council',
                              icon: Icons.account_tree_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            _buildField(
                              controller: chargeCtrl,
                              label: 'Charge',
                              icon: Icons.groups_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            _buildField(
                              controller: psConstituencyIdCtrl,
                              label: 'PS Constituency ID',
                              icon: Icons.how_to_vote_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveUser,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSaving
                          ? 'Saving…'
                          : isEditMode
                          ? 'Save changes'
                          : 'Create volunteer',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
