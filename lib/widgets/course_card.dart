import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/mentor.dart';

class CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback? onFavorite;

  const CourseCard({super.key, required this.course, this.onFavorite});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  Color get _cardColor =>
      widget.course.cardColor == 'pink' ? const Color(0xFFF1B5FF) : const Color(0xFFBCEBFF);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Black Shadow/Offset Layer on right edge matching Figma
          Positioned(
            right: 0,
            top: 8,
            bottom: 0,
            width: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
          // Main Colored Card
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Action Icon / Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.course.title,
                        style: GoogleFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.course.isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B1D1D),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Live',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: widget.onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            widget.course.isFavorited ? Icons.favorite : Icons.favorite_border_rounded,
                            size: 22,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  widget.course.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom content: Class End vs Progress vs Rating
                if (widget.course.isLive && widget.course.minutesRemaining != null)
                  Text(
                    'Class End in ${widget.course.minutesRemaining} mns',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  )
                else if (widget.course.progress != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      height: 7,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.course.progress ?? 0.35,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.course.rating} rating',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${widget.course.durationHours}hrs',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}