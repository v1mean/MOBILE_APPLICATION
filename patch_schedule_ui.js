const fs = require('fs');
let file = 'lib/screens/teacher_schedules_screen.dart';
let content = fs.readFileSync(file, 'utf8');

const targetStr = `                                                  Expanded(
                                                    child: Text('\\$\\{booking['student_name']\\} - Booked', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)), overflow: TextOverflow.ellipsis),
                                                  ),`.replace(/\\\\/g, ''); // Unescape manually

const replaceStr = `                                                  Expanded(
                                                    child: Text('\\$\\{booking['student_name']\\} (\\$\\{booking['booking_date'] ?? ''\\}) - Booked', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF166534)), overflow: TextOverflow.ellipsis),
                                                  ),`.replace(/\\\\/g, '');

content = content.replace(targetStr, replaceStr);
fs.writeFileSync(file, content);
