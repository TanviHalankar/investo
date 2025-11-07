import 'package:flutter/material.dart';
import '../../api_service.dart';

class PredictionScreen extends StatefulWidget {
  final String username;

  const PredictionScreen({super.key, required this.username});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _holdingController = TextEditingController();
  String? _predictionResult;
  bool _isLoading = false;
  double _formProgress = 0.0;
  int _completedFields = 0;
  bool _showResult = false;

  // Modern dark color scheme with orange accents (matching home_screen.dart)
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _resultAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));

    // Add listeners to track form progress
    _buyPriceController.addListener(_updateFormProgress);
    _sellPriceController.addListener(_updateFormProgress);
    _quantityController.addListener(_updateFormProgress);
    _holdingController.addListener(_updateFormProgress);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _resultController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _holdingController.dispose();
    super.dispose();
  }

  void _updateFormProgress() {
    setState(() {
      _completedFields = 0;
      if (_buyPriceController.text.isNotEmpty) _completedFields++;
      if (_sellPriceController.text.isNotEmpty) _completedFields++;
      if (_quantityController.text.isNotEmpty) _completedFields++;
      if (_holdingController.text.isNotEmpty) _completedFields++;
      _formProgress = _completedFields / 4.0;
    });
  }

  Future<void> _getPrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _showResult = false;
      });

      try {
        // Add a small delay for better UX
        await Future.delayed(const Duration(milliseconds: 800));

        final prediction = await ApiService.getPrediction(
          double.parse(_buyPriceController.text),
          double.parse(_sellPriceController.text),
          double.parse(_quantityController.text),
          double.parse(_holdingController.text),
          double.parse(_sellPriceController.text) -
              double.parse(_buyPriceController.text),
        );

        setState(() {
          _predictionResult = prediction;
          _isLoading = false;
          _showResult = true;
        });

        _resultController.forward();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        width: size.width,
        height: size.height,
        color: darkBg,
        child: Stack(
          children: [
            // Animated floating elements
            ...List.generate(4, (index) => _buildFloatingElement(index)),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header with user level
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Progress indicator
                    _buildProgressCard(),
                    const SizedBox(height: 20),

                    // Input form
                    _buildInputForm(),
                    const SizedBox(height: 20),

                    // Prediction button
                    _buildPredictionButton(),
                    const SizedBox(height: 20),

                    // Result display
                    if (_showResult && _predictionResult != null)
                      _buildResultCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final positions = [
      {'top': 80.0, 'right': 40.0, 'size': 60.0},
      {'top': 300.0, 'left': 30.0, 'size': 80.0},
      {'bottom': 200.0, 'right': 60.0, 'size': 70.0},
      {'bottom': 400.0, 'left': 80.0, 'size': 50.0},
    ];

    final pos = positions[index];

    return Positioned(
      top: pos['top'],
      bottom: pos['bottom'],
      left: pos['left'],
      right: pos['right'],
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 3000 + (index * 500)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, 15 * (0.5 - value).abs()),
            child: Container(
              width: pos['size'] as double,
              height: pos['size'] as double,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentOrange.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () => setState(() {}),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [cardDark, cardLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // User avatar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: accentOrange.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: darkBg, size: 24),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.username,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: accentOrange.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: accentOrange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Level ${_completedFields + 1}',
                  style: const TextStyle(
                    color: accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [cardDark, cardLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quest Progress',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$_completedFields/4 fields',
                style: TextStyle(
                  color: accentOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final progressWidth = constraints.maxWidth * _formProgress;
                return Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: progressWidth.clamp(0.0, constraints.maxWidth),
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [accentOrange, accentOrangeDim],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: accentOrange.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Achievement badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              final isCompleted = index < _completedFields;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? accentOrange.withOpacity(0.2)
                      : cardLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted
                        ? accentOrange
                        : borderColor,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? accentOrange : textTertiary,
                  size: 20,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [cardDark, cardLight],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Trading Parameters',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            _buildGameTextField(
              controller: _buyPriceController,
              label: 'Buy Price',
              icon: Icons.trending_up,
              prefix: '\$',
            ),
            const SizedBox(height: 16),

            _buildGameTextField(
              controller: _sellPriceController,
              label: 'Target Sell Price',
              icon: Icons.trending_down,
              prefix: '\$',
            ),
            const SizedBox(height: 16),

            _buildGameTextField(
              controller: _quantityController,
              label: 'Quantity',
              icon: Icons.pie_chart,
              suffix: 'shares',
            ),
            const SizedBox(height: 16),

            _buildGameTextField(
              controller: _holdingController,
              label: 'Holding Period',
              icon: Icons.schedule,
              suffix: 'days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: darkBg, size: 20),
          ),
          prefixText: prefix,
          suffixText: suffix,
          prefixStyle: const TextStyle(color: accentOrange, fontSize: 16),
          suffixStyle: TextStyle(color: textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => v!.isEmpty ? "This field is required" : null,
      ),
    );
  }

  Widget _buildPredictionButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _formProgress == 1.0 ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: _formProgress == 1.0
                  ? const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
              )
                  : LinearGradient(
                colors: [
                  textTertiary.withOpacity(0.3),
                  textTertiary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: _formProgress == 1.0
                  ? [
                BoxShadow(
                  color: accentOrange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _formProgress == 1.0 && !_isLoading ? _getPrediction : null,
                borderRadius: BorderRadius.circular(18),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: darkBg,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _formProgress == 1.0 ? Icons.rocket_launch : Icons.lock,
                        color: _formProgress == 1.0 ? darkBg : textSecondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formProgress == 1.0
                            ? 'Launch Prediction AI'
                            : 'Complete All Fields',
                        style: TextStyle(
                          color: _formProgress == 1.0 ? darkBg : textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _resultAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentOrange.withOpacity(0.15),
                accentOrangeDim.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentOrange.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: accentOrange.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Achievement header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentOrange, accentOrangeDim],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: darkBg,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                '🎉 Prediction Complete!',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  _predictionResult!,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // XP gained indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentOrange, accentOrangeDim],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: darkBg, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      '+100 XP Earned!',
                      style: TextStyle(
                        color: darkBg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}