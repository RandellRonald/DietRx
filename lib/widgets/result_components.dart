import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DESCRIPTION CARD WIDGET ---
class DescriptionCard extends StatelessWidget {
  final Color pillColor;
  final Color pillTextColor;
  final List<String> descriptionPoints;

  const DescriptionCard({
    super.key,
    required this.pillColor,
    required this.pillTextColor,
    required this.descriptionPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.elliptical(300, 50),
          bottom: Radius.circular(20),
        ),
        border: Border(top: BorderSide(color: pillColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Description",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...descriptionPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(fontSize: 20, color: pillTextColor),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ALTERNATIVES LIST WIDGET ---
class AlternativesList extends StatelessWidget {
  final List<Map<String, dynamic>> alternatives;

  const AlternativesList({super.key, required this.alternatives});

  void _showReasonDialog(
    BuildContext context,
    Map<String, dynamic> altProduct,
  ) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Why is ${altProduct['name']} better?",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          altProduct['match_reason'] ?? "It fits all your health limits.",
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.green[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(
              "Got it",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "No safer alternatives currently available in the database.",
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: alternatives.length,
        itemBuilder: (context, index) {
          final alt = alternatives[index];
          return GestureDetector(
            onTap: () => _showReasonDialog(context, alt),
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: alt['image_url'] != null
                        ? Image.network(alt['image_url'], fit: BoxFit.contain)
                        : const Icon(Icons.eco, color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alt['name'] ?? "Unknown",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
