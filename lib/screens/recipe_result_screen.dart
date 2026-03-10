import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/dynamic_rule_service.dart';

class RecipeResultScreen extends StatefulWidget {
  final Map<String, dynamic> evaluation;

  const RecipeResultScreen({super.key, required this.evaluation});

  @override
  State<RecipeResultScreen> createState() => _RecipeResultScreenState();
}

class _RecipeResultScreenState extends State<RecipeResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String? _substitutions;
  bool _isLoadingSubs = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();

    if (!widget.evaluation['isSafe']) {
      _fetchSubstitutions();
    }
  }

  Future<void> _fetchSubstitutions() async {
    setState(() => _isLoadingSubs = true);
    final subs = await DynamicRuleService.getRecipeSubstitutions(
      recipeData: widget.evaluation['recipeData'],
      warnings: List<String>.from(widget.evaluation['warnings']),
    );
    if (mounted) {
      setState(() {
        _substitutions = subs;
        _isLoadingSubs = false;
      });
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // Parses the raw text into a clean list of individual substitutions
  List<String> _parseSubstitutions(String rawText) {
    return rawText
        .split('\n')
        .map((e) => e.replaceAll('*', '').replaceAll('-', '').trim())
        .where((e) => e.length > 10)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSafe = widget.evaluation['isSafe'];
    final List<String> warnings = List<String>.from(
      widget.evaluation['warnings'],
    );
    final Map<String, dynamic> recipeData = widget.evaluation['recipeData'];
    final String recipeName = recipeData['recipeName'] ?? "Analyzed Recipe";

    List<String> subList = [];
    if (_substitutions != null) {
      subList = _parseSubstitutions(_substitutions!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Analysis Result",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- RECIPE TITLE & STATUS ---
                Text(
                  recipeName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSafe
                            ? const Color(0xFF8CC63F).withOpacity(0.15)
                            : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isSafe
                              ? const Color(0xFF8CC63F)
                              : Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    isSafe ? "SAFE TO COOK" : "MODIFICATION NEEDED",
                    style: GoogleFonts.poppins(
                      color: isSafe ? const Color(0xFF8CC63F) : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 40),

                // --- DIETARY ANALYSIS SECTION ---
                Text(
                  "Dietary Analysis",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child:
                      isSafe
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF8CC63F),
                                  size: 30,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    "This recipe matches your dietary profile perfectly. No restricted ingredients found.",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: warnings
                                  .map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2.0),
                                            child: Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              w,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white70,
                                                fontSize: 15,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                ),

                // --- SUBSTITUTIONS SECTION ---
                if (!isSafe) ...[
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Text(
                        "Substitutions",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  if (_isLoadingSubs)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD97706),
                        ),
                      ),
                    )
                  else if (subList.isNotEmpty)
                    ...subList.map(
                      (sub) => Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFFD97706).withOpacity(0.5), 
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    sub,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      "No specific substitutions found.",
                      style: GoogleFonts.poppins(color: Colors.white54),
                    ),
                ],
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}