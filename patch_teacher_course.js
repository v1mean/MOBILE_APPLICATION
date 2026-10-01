const fs = require('fs');
let file = 'lib/screens/teacher_home_screen.dart';
let content = fs.readFileSync(file, 'utf8');

const target = `          _courses = (data as List).map((c) => TeacherCourse(
            id: c['id']?.toString() ?? '',
            title: c['title'] ?? 'Course Title',
            description: c['description'] ?? 'No description',
            rating: (c['rating'] as num?)?.toDouble() ?? 5.0,
            timeAgo: _formatTimeAgo(c['created_at']),
            color: _parseColor(c['card_color']),
          )).toList();`;

const replace = `          _courses = (data as List).map((c) => TeacherCourse(
            id: c['id']?.toString() ?? '',
            title: c['title'] ?? 'Course Title',
            description: c['description'] ?? 'No description',
            category: c['category']?.toString() ?? 'General',
            rating: (c['rating'] as num?)?.toDouble() ?? 5.0,
            timeAgo: _formatTimeAgo(c['created_at']),
            color: _parseColor(c['card_color']),
          )).toList();`;

content = content.replace(target, replace);
fs.writeFileSync(file, content);
