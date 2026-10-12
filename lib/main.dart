import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animated_container_widget.dart';
import 'animated_cross_fade_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Quran Learning App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: green, secondary: gold, surface: bg),
      scaffoldBackgroundColor: bg,
    ),
    home: const FrontScreen(),
  );
}

// ======================= FRONT SCREEN =======================
// Ek hi screen mein: Learning header + Role choose karna + Login/Sign Up
// Screen ka colour ek hi rehta hai (green).
class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});
  @override
  State<FrontScreen> createState() => _FrontState();
}

class _FrontState extends State<FrontScreen> {
  final name = TextEditingController(), email = TextEditingController(), pass = TextEditingController(), conf = TextEditingController();
  bool teacher = false, showLogin = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    conf.dispose();
    super.dispose();
  }

  void submit() {
    final role = teacher ? 'Teacher' : 'Student';
    final e = email.text.trim().toLowerCase();

    if (showLogin) {
      final err = vEmail(e) ?? (pass.text.isEmpty ? 'Please enter your password' : null);
      if (err != null) return snack(context, err);
      final err2 = store.login(e, pass.text, role);
      if (err2 != null) return snack(context, err2);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => teacher ? const TeacherHome() : const StudentHome()), (r) => false);
    } else {
      final err = vName(name.text) ?? vEmail(e) ?? vPass(pass.text) ?? (conf.text != pass.text ? 'Passwords do not match' : null);
      if (err != null) return snack(context, err);
      final err2 = store.signUp(User(role, name.text.trim(), e, pass.text));
      if (err2 != null) return snack(context, err2);
      snack(context, 'Account created! Please login.');
      setState(() {
        showLogin = true;
        pass.clear();
        conf.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final role = teacher ? 'Teacher' : 'Student';
    const accent = green;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: grad),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(children: [
              // back: Sign Up se wapas Login par
              SizedBox(
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: showLogin ? null : Tap(onTap: () => setState(() => showLogin = true), child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.arrow_back, color: Colors.white))),
                ),
              ),
              // ---------- 1. LEARNING HEADER ----------
              SizedBox(
                height: 176,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    popIn(Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold, width: 2)),
                      child: const CircleAvatar(radius: 38, backgroundColor: Colors.white24, child: Icon(Icons.menu_book_rounded, size: 40, color: Colors.white)),
                    )),
                    const SizedBox(height: 12),
                    const Text('Quran Learning App', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Learn the Quran with qualified teachers, anywhere in the world.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ),
              ),
              // ---------- 2. ROLE + 3. LOGIN / SIGN UP ----------
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: h - 260),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
                decoration: const BoxDecoration(color: bg, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                child: Column(children: [
                  const Text('Continue as', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: RoleCard('Student', Icons.school, !teacher, () => setState(() => teacher = false))),
                    const SizedBox(width: 12),
                    Expanded(child: RoleCard('Teacher', Icons.person_pin, teacher, () => setState(() => teacher = true))),
                  ]),
                  const SizedBox(height: 20),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 1500),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accent),
                    child: Text('$role ${showLogin ? "Login" : "Sign Up"}'),
                  ),
                  const SizedBox(height: 14),
                  // AnimatedCrossFade: Login aur Sign Up form ek dusre mein fade hote hain
                  AuthCrossFade(showLogin: showLogin, name: name, email: email, pass: pass, conf: conf),
                  const SizedBox(height: 14),
                  AnimButton(showLogin ? 'Login' : 'Create Account', submit),
                  const SizedBox(height: 8),
                  Tap(
                    onStart: () => setState(() => showLogin = !showLogin),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 1500),
                        style: TextStyle(color: accent, fontWeight: FontWeight.w600),
                        child: Text(showLogin ? "Don't have an account? Sign up" : 'Already have an account? Login'),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ======================= MODELS =======================
class User {
  final String role, name, email, pass;
  User(this.role, this.name, this.email, this.pass);
  String enc() => jsonEncode([role, name, email, pass]);
  static User dec(String s) {
    final l = jsonDecode(s) as List;
    return User(l[0], l[1], l[2], l[3]);
  }
}

class Sub {
  final String student, email, note;
  int? marks;
  String? feedback;
  Sub(this.student, this.email, this.note, {this.marks, this.feedback});
}

class Assign {
  final String title, course, due;
  final List<Sub> subs;
  Assign(this.title, this.course, this.due, this.subs);
}

class Lesson {
  final String title, type, text; // type: lecture / pdf / lesson
  bool done;
  Lesson(this.title, this.type, {this.text = 'Lesson notes will appear here.', this.done = false});
}

class Course {
  final String title, teacher;
  final int students;
  final List<Lesson> lessons;
  final Color c1, c2; // book cover colors
  final IconData icon; // book cover icon
  final List<List<String>> pages; // book ke pages: [heading, arabic, text]
  Course(this.title, this.teacher, this.students, this.lessons, {required this.c1, required this.c2, required this.icon, required this.pages});
  double get progress => lessons.isEmpty ? 0 : lessons.where((l) => l.done).length / lessons.length;
}

class Pupil {
  final String name;
  final int attendance;
  final double progress;
  Pupil(this.name, this.attendance, this.progress);
}

// ======================= STORE =======================
class Store extends ChangeNotifier {
  List<User> users = [];
  User? user;
  SharedPreferences? _p;

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    users = (_p!.getStringList('users') ?? []).map(User.dec).toList();
  }

  String? signUp(User u) {
    if (users.any((x) => x.email == u.email)) return 'This email is already registered. Please login.';
    users.add(u);
    _p?.setStringList('users', users.map((x) => x.enc()).toList());
    return null;
  }

  String? login(String email, String pass, String role) {
    final m = users.where((x) => x.email == email).toList();
    if (m.isEmpty) return 'No account found. Please sign up first.';
    if (m.first.role != role) return 'This email is registered as a ${m.first.role}.';
    if (m.first.pass != pass) return 'Incorrect password.';
    user = m.first;
    return null;
  }

  void logout() => user = null;
  String get me => user?.name ?? '';
  String get email => user?.email ?? '';

  final courses = [
    Course('Noorani Qaida', 'Ustaz Usman', 24, [
      Lesson('Lesson 1: Huroof Mufradat', 'lecture', text: 'Single letters: learn the shape and sound of every Arabic letter.', done: true),
      Lesson('Lesson 2: Huroof Murakkabat', 'pdf', text: 'Joined letters: learn how letters change shape at the start, middle and end of a word.'),
      Lesson('Lesson 3: Harakat', 'lecture', text: 'Fatha, Kasra and Damma: the three short vowel signs.'),
    ], c1: green, c2: light, icon: Icons.auto_stories,
        pages: [
          ['Huroof Mufradat', 'ا ب ت ث ج ح خ د ذ ر ز', 'Arabic has 29 letters. Learn each letter by its shape and by the sound it makes.'],
          ['Harakat', 'بَ  بِ  بُ', 'Fatha gives an "a" sound, Kasra an "i" sound and Damma a "u" sound.'],
          ['Tanween', 'بً  بٍ  بٌ', 'Tanween is a double vowel that adds an "n" sound at the end of a word.'],
          ['Sukoon', 'اَبْ  اِبْ  اُبْ', 'Sukoon means the letter carries no vowel. Stop gently on it.'],
        ]),
    Course('Tajweed Basics', 'Ustaz Usman', 18, [
      Lesson('Makharij al-Huroof', 'lecture', text: 'Makharij are the points of articulation of every letter.'),
      Lesson('Rules of Noon Sakinah', 'pdf', text: 'Four rules: Izhar, Idgham, Iqlab and Ikhfa. Practise each with your teacher.'),
      Lesson('Madd and its types', 'lesson', text: 'Madd means elongation. Natural Madd is held for two counts.'),
    ], c1: Color(0xFF1E3A8A), c2: Color(0xFF3B82F6), icon: Icons.record_voice_over,
        pages: [
          ['Makharij', 'ء ه ع ح غ خ', 'The throat has three places of articulation: the deep, the middle and the upper throat.'],
          ['Noon Sakinah', 'إِظْهَار  إِدْغَام  إِقْلَاب  إِخْفَاء', 'Four rules: Izhar, Idgham, Iqlab and Ikhfa. Each one depends on the letter that follows the noon.'],
          ['Madd', 'قَالَ  قِيلَ  يَقُولُ', 'Natural Madd is held for two counts. It comes from alif, ya and waw.'],
          ['Qalqalah', 'ق ط ب ج د', 'These five letters bounce slightly when they carry a sukoon.'],
        ]),
    Course('Surah Memorization', 'Ustaza Ayesha', 12, [
      Lesson('Surah Al-Fatiha', 'lecture', text: 'Learn Surah Al-Fatiha verse by verse with correct pronunciation.'),
      Lesson('Surah Al-Ikhlas', 'lecture', text: 'Learn Surah Al-Ikhlas and revise it daily until it is memorized.'),
    ], c1: Color(0xFF7C2D12), c2: Color(0xFFEA580C), icon: Icons.bookmark,
        pages: [
          ['Surah Al-Fatiha', 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'The opening chapter of the Quran has 7 verses. Learn it verse by verse.'],
          ['Surah Al-Ikhlas', 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'A short chapter of 4 verses about the oneness of Allah.'],
          ['How to memorize', '', 'Listen carefully, repeat after your teacher, revise daily and recite in your prayer.'],
        ]),
  ];
  final pupils = [Pupil('Fatima Noor', 97, 0.85), Pupil('Bilal Hussain', 80, 0.45), Pupil('Maryam Ali', 88, 0.6), Pupil('Hamza Tariq', 91, 0.7)];
  late final List<Assign> assignments = [
    Assign('Recite Surah Al-Fatiha', 'Tajweed Basics', '25/10/2026', [
      Sub('Fatima Noor', 'f@x.com', 'Recitation uploaded', marks: 92, feedback: 'Mashallah, beautiful!'),
      Sub('Bilal Hussain', 'b@x.com', 'Recitation uploaded'),
    ]),
    Assign('Write Huroof Mufradat', 'Noorani Qaida', '28/10/2026', []),
    Assign('Memorize Surah Al-Ikhlas', 'Surah Memorization', '02/11/2026', []),
  ];

  void addLesson(Course c, Lesson l) { c.lessons.add(l); notifyListeners(); }
  void addAssignment(Assign a) { assignments.insert(0, a); notifyListeners(); }
  void submit(Assign a, String note) { a.subs.add(Sub(me, email, note)); notifyListeners(); }
  void grade(Sub s, int m, String f) { s.marks = m; s.feedback = f; notifyListeners(); }
  void done(Lesson l) { if (!l.done) { l.done = true; notifyListeners(); } }
  Sub? mySub(Assign a) {
    for (final s in a.subs) { if (s.email == email) return s; }
    return null;
  }
  int get doneLessons => courses.fold(0, (n, c) => n + c.lessons.where((l) => l.done).length);
}

final store = Store();
Widget watch(Widget Function() b) => ListenableBuilder(listenable: store, builder: (context, child) => b());
String lessonLabel(String t) => t == 'lecture' ? 'Lecture' : t == 'pdf' ? 'PDF notes' : 'Reading';
void snack(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

// ======================= VALIDATORS =======================
/// Validates user full name ensuring acceptable length and character formatting.
String? vName(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'Please enter your full name';
  if (t.length < 3) return 'Name must be at least 3 characters long';
  if (!RegExp(r"^[A-Za-z .'-]+$").hasMatch(t)) return 'Name can contain letters, spaces, and hyphens only';
  return null;
}

/// Validates email format adhering to standard Gmail requirements.
String? vEmail(String? v) {
  final t = v?.trim() ?? '';
  if (t.isEmpty) return 'Please enter your email address';
  if (!RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false).hasMatch(t)) {
    return 'Please enter a valid @gmail.com email address';
  }
  return null;
}

/// Enforces password complexity (minimum 8 characters, upper, lower, and digit).
String? vPass(String? v) {
  final t = v ?? '';
  if (t.isEmpty) return 'Please enter a secure password';
  if (t.length < 8) return 'Password must be at least 8 characters long';
  if (!RegExp(r'[A-Z]').hasMatch(t)) return 'Password must contain at least one uppercase letter (A-Z)';
  if (!RegExp(r'[a-z]').hasMatch(t)) return 'Password must contain at least one lowercase letter (a-z)';
  if (!RegExp(r'[0-9]').hasMatch(t)) return 'Password must contain at least one numeric digit (0-9)';
  return null;
}

// ======================= ANIMATED WIDGETS =======================

/// Course ki khoobsurat book ki picture (har course ka alag rang aur icon).
class BookCover extends StatelessWidget {
  final Course c;
  final double size; // width
  const BookCover(this.c, {super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final big = size >= 90;
    return Container(
      width: size,
      height: size * 1.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.c1, c.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: size * 0.12, offset: Offset(size * 0.04, size * 0.06))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // book ki spine
        Container(
          width: size * 0.09,
          decoration: BoxDecoration(color: Colors.black.withAlpha(60), borderRadius: const BorderRadius.horizontal(left: Radius.circular(4))),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(size * 0.07),
            decoration: BoxDecoration(border: Border.all(color: gold, width: big ? 1.5 : 1), borderRadius: BorderRadius.circular(6)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(c.icon, color: gold, size: size * 0.28),
              if (big) ...[
                SizedBox(height: size * 0.06),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size * 0.05),
                  child: Text(c.title, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: size * 0.1, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: size * 0.05),
                Container(width: size * 0.25, height: 2, color: gold),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Progress bar jo ahista ahista bharti hai.
class ProgressBar extends StatelessWidget {
  final double value, height;
  final Color color;
  const ProgressBar(this.value, this.color, {super.key, this.height = 8});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOut,
    builder: (context, v, child) => LinearProgressIndicator(value: v, minHeight: height, borderRadius: BorderRadius.circular(8), color: color, backgroundColor: color.withAlpha(30)),
  );
}

/// Screen khulte hi widget chhota se bada hokar aata hai.
Widget popIn(Widget child) => TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.6, end: 1),
  duration: const Duration(milliseconds: 600),
  curve: Curves.easeOutBack,
  builder: (context, s, c) => Transform.scale(scale: s, child: c),
  child: child,
);


// ======================= APP BAR + SHELL =======================
AppBar bar(BuildContext c, String t, {bool back = true, VoidCallback? onBack, Color color = green, List<Widget>? actions, PreferredSizeWidget? bottom}) => AppBar(
  automaticallyImplyLeading: false,
  leading: back ? Center(child: Tap(onTap: onBack ?? (() => Navigator.pop(c)), child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.arrow_back)))) : null,
  title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  backgroundColor: color,
  foregroundColor: Colors.white,
  actions: actions,
  bottom: bottom,
);

class Dest {
  final String label;
  final IconData icon;
  final Widget page;
  final Widget? fab;
  Dest(this.label, this.icon, this.page, {this.fab});
}

class Shell extends StatefulWidget {
  final String title;
  final List<Dest> dests;
  const Shell({super.key, required this.title, required this.dests});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;

  void logout() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: Text('${store.me}\n${store.email}\n\nAre you sure you want to logout?'),
      actions: [
        AnimButton('Cancel', () => Navigator.pop(ctx), width: 100, height: 44),
        AnimButton('Logout', () {
          store.logout();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const FrontScreen()), (r) => false);
        }, width: 100, height: 44),
      ],
    ),
  );

  // Back: pehle pehle tab par wapas, phir logout ka sawal
  void goBack() {
    if (i != 0) {
      setState(() => i = 0);
    } else {
      logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dests[i];
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) goBack();
        },
        child: Scaffold(
          appBar: bar(context, widget.title, onBack: goBack, actions: [
            Tap(
              onTap: logout,
              child: CircleAvatar(backgroundColor: gold, child: Text(store.me.isEmpty ? '?' : store.me[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
            ),
            const SizedBox(width: 12),
          ]),
          // page badalte waqt smooth fade
          body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: KeyedSubtree(key: ValueKey(i), child: d.page)),
          floatingActionButton: d.fab,
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: SafeArea(
              top: false,
              child: Row(children: [
                for (int n = 0; n < widget.dests.length; n++)
                  Expanded(
                    child: Tap(
                      onStart: () => setState(() => i = n),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: n == i ? green.withAlpha(35) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                        // FIX: mainAxisSize.min -> bar poori screen ki height nahi leti
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(widget.dests[n].icon, color: n == i ? green : Colors.grey),
                          Text(widget.dests[n].label, style: TextStyle(fontSize: 11, color: n == i ? green : Colors.grey, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ));
  }
}

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});
  @override
  Widget build(BuildContext context) => Shell(title: 'Quran Learning', dests: [
    Dest('Courses', Icons.menu_book, const CoursesPage(teacher: false)),
    Dest('Tasks', Icons.assignment, const StudentTasks()),
    Dest('Record', Icons.bar_chart, const RecordPage()),
    Dest('Alerts', Icons.notifications, const AlertsPage()),
  ]);
}

class TeacherHome extends StatelessWidget {
  const TeacherHome({super.key});
  @override
  Widget build(BuildContext context) => Shell(title: 'Teacher Dashboard', dests: [
    Dest('Courses', Icons.menu_book, const CoursesPage(teacher: true)),
    Dest('Assignments', Icons.assignment, const TeacherTasks(),
        fab: Builder(builder: (c) => AnimButton('New', () => newAssignment(c), icon: Icons.add, width: 120, height: 48))),
    Dest('Students', Icons.groups, const StudentsPage()),
  ]);
}

// ======================= COURSES + LECTURES =======================
class CoursesPage extends StatelessWidget {
  final bool teacher;
  const CoursesPage({super.key, required this.teacher});
  @override
  Widget build(BuildContext context) => watch(() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: grad, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Assalamu Alaikum,', style: TextStyle(color: Colors.white70)),
            Text(store.me, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(teacher ? '${store.courses.length} courses • ${store.pupils.length} students' : '${store.doneLessons} lectures completed', style: const TextStyle(color: gold, fontWeight: FontWeight.w600)),
          ]),
        ),
        const Icon(Icons.auto_stories, color: Colors.white24, size: 64),
      ]),
    ),
    const SizedBox(height: 16),
    QuickButtons(teacher ? teacherCourseBtns : studentCourseBtns),
    const SizedBox(height: 16),
    Text(teacher ? 'My Courses' : 'Enrolled Courses', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    for (final c in store.courses)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Tap(tint: true, radius: 18,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(c: c, teacher: teacher))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 3))]),
            child: Row(children: [
              BookCover(c, size: 54), // video ki jagah book ki picture
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(teacher ? '${c.students} students • ${c.lessons.length} lessons' : '${c.teacher} • ${c.lessons.length} lessons', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  if (!teacher) ...[
                    const SizedBox(height: 10),
                    ProgressBar(c.progress, green),
                    const SizedBox(height: 4),
                    Text('${(c.progress * 100).round()}% complete', style: const TextStyle(fontSize: 12)),
                  ],
                ]),
              ),
              const Icon(Icons.chevron_right),
            ]),
          ),
        ),
      ),
  ]));
}

// ======================= QUICK BUTTONS + INFO PAGES =======================
// Har section mein 2-3 buttons: click par colour badalta hai aur related page khulta hai.
class Item {
  final String title, sub;
  final IconData icon;
  const Item(this.title, this.sub, this.icon);
}

class QuickBtn {
  final String label, title;
  final IconData icon;
  final List<Item> Function() items;
  const QuickBtn(this.label, this.title, this.icon, this.items);
}

class QuickButtons extends StatelessWidget {
  final List<QuickBtn> btns;
  const QuickButtons(this.btns, {super.key});
  static const colors = [green, Color(0xFF1565C0), Color(0xFF8E24AA)];

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 32 - 10) / 2;
    return Wrap(spacing: 10, runSpacing: 10, children: [
      for (int i = 0; i < btns.length; i++)
        AnimButton(
          btns[i].label,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => InfoScreen(btns[i], colors[i % 3]))),
          icon: btns[i].icon,
          width: (i == 2 || btns.length == 1) ? w * 2 + 10 : w,
          height: 48,
          start: i,
        ),
    ]);
  }
}

class InfoScreen extends StatelessWidget {
  final QuickBtn b;
  final Color color;
  const InfoScreen(this.b, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: bar(context, b.title, color: color),
    body: watch(() {
      final list = b.items();
      return ListView(padding: const EdgeInsets.all(16), children: [
        popIn(Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withAlpha(170)]), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Icon(b.icon, color: Colors.white, size: 44),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('${list.length} items', style: const TextStyle(color: Colors.white70)),
              ]),
            ),
          ]),
        )),
        const SizedBox(height: 16),
        if (list.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Nothing here yet'))),
        for (final it in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tap(
              tint: true,
              child: Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(it.icon, color: color)),
                  title: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(it.sub),
                ),
              ),
            ),
          ),
      ]);
    }),
  );
}

List<Item> _lessons(bool onlyPending) => [
  for (final c in store.courses)
    for (final l in c.lessons)
      if (!onlyPending || !l.done) Item(l.title, c.title, Icons.menu_book),
];

List<Item> _tasks(bool Function(Sub?) test, String Function(Assign, Sub?) sub, IconData icon) => [
  for (final a in store.assignments)
    if (test(store.mySub(a))) Item(a.title, sub(a, store.mySub(a)), icon),
];

// ---------- Student ----------
final studentCourseBtns = <QuickBtn>[
  QuickBtn('My Progress', 'My Progress', Icons.trending_up, () => [
    for (final c in store.courses) Item(c.title, '${c.lessons.where((l) => l.done).length}/${c.lessons.length} lectures • ${(c.progress * 100).round()}% complete', c.icon),
  ]),
  QuickBtn('Teachers', 'My Teachers', Icons.person, () => [for (final c in store.courses) Item(c.teacher, c.title, Icons.person)]),
  QuickBtn('Next Lessons', 'Next Lessons', Icons.play_lesson, () => _lessons(true)),
];

final studentTaskBtns = <QuickBtn>[
  QuickBtn('Pending', 'Pending Tasks', Icons.pending_actions, () => _tasks((s) => s == null, (a, s) => '${a.course} • Due ${a.due}', Icons.pending_actions)),
  QuickBtn('Submitted', 'Submitted Tasks', Icons.upload_file, () => _tasks((s) => s != null && s.marks == null, (a, s) => 'Waiting for teacher to grade', Icons.upload_file)),
  QuickBtn('Graded', 'Graded Tasks', Icons.grade, () => _tasks((s) => s?.marks != null, (a, s) => '${s!.marks}/100 • ${s.feedback ?? ""}', Icons.grade)),
];

final studentRecordBtns = <QuickBtn>[
  QuickBtn('Attendance', 'My Attendance', Icons.event_available, () => [
    for (int i = 1; i <= 6; i++) Item('Week $i', i == 4 ? 'Absent' : 'Present', i == 4 ? Icons.cancel : Icons.check_circle),
  ]),
  QuickBtn('Certificates', 'Certificates', Icons.workspace_premium, () => [
    const Item('Arabic Alphabet', 'Completed • 91/100', Icons.verified),
    for (final c in store.courses) Item(c.title, c.progress >= 1 ? 'Completed' : '${(c.progress * 100).round()}% done', c.progress >= 1 ? Icons.verified : Icons.hourglass_bottom),
  ]),
  QuickBtn('Teacher Notes', 'Teacher Notes', Icons.rate_review, () => [
    const Item('Ustaz Usman', 'Excellent makharij.', Icons.comment),
    for (final a in store.assignments)
      if (store.mySub(a)?.feedback != null) Item(a.title, store.mySub(a)!.feedback!, Icons.rate_review),
  ]),
];

final studentAlertBtns = <QuickBtn>[
  QuickBtn('Announcements', 'Announcements', Icons.campaign, () => const [
    Item('New batch starting', 'Enrolment for the new Tajweed batch is open.', Icons.campaign),
    Item('Eid holidays', 'Classes will be closed during Eid holidays.', Icons.celebration),
    Item('Quran competition', 'Recitation competition next month. Register now!', Icons.emoji_events),
  ]),
  QuickBtn('Reminders', 'Reminders', Icons.alarm, () => [for (final a in store.assignments) Item(a.title, 'Due ${a.due}', Icons.alarm)]),
  QuickBtn('Messages', 'Messages', Icons.message, () => const [
    Item('Ustaz Usman', 'Please revise Lesson 2 before class.', Icons.message),
    Item('Ustaza Ayesha', 'Well done on Surah Al-Fatiha!', Icons.message),
  ]),
];

// ---------- Teacher ----------
final teacherCourseBtns = <QuickBtn>[
  QuickBtn('Schedule', 'Class Schedule', Icons.schedule, () {
    const slots = ['Mon & Wed • 4:00 PM', 'Tue & Thu • 5:00 PM', 'Sat • 10:00 AM'];
    return [for (int i = 0; i < store.courses.length; i++) Item(store.courses[i].title, slots[i % slots.length], Icons.schedule)];
  }),
  QuickBtn('Reports', 'Course Reports', Icons.bar_chart, () => [
    for (final c in store.courses) Item(c.title, '${c.students} students • ${c.lessons.length} lectures', Icons.bar_chart),
  ]),
  QuickBtn('Lectures', 'All Lectures', Icons.menu_book, () => _lessons(false)),
];

final teacherTaskBtns = <QuickBtn>[
  QuickBtn('To Grade', 'To Grade', Icons.pending_actions, () => [
    for (final a in store.assignments)
      for (final s in a.subs)
        if (s.marks == null) Item(s.student, a.title, Icons.pending_actions),
  ]),
  QuickBtn('Graded', 'Graded Work', Icons.grade, () => [
    for (final a in store.assignments)
      for (final s in a.subs)
        if (s.marks != null) Item(s.student, '${a.title} • ${s.marks}/100', Icons.grade),
  ]),
  QuickBtn('Deadlines', 'Deadlines', Icons.event, () => [for (final a in store.assignments) Item(a.title, '${a.course} • Due ${a.due}', Icons.event)]),
];

final teacherStudentBtns = <QuickBtn>[
  QuickBtn('Attendance', 'Attendance Sheet', Icons.event_available, () => [for (final p in store.pupils) Item(p.name, '${p.attendance}% attendance', Icons.event_available)]),
  QuickBtn('Top Students', 'Top Students', Icons.emoji_events, () {
    final l = [...store.pupils]..sort((a, b) => b.progress.compareTo(a.progress));
    return [for (final p in l) Item(p.name, 'Progress ${(p.progress * 100).round()}%', Icons.emoji_events)];
  }),
  QuickBtn('Needs Help', 'Needs Help', Icons.support_agent, () => [
    for (final p in store.pupils)
      if (p.progress < 0.6) Item(p.name, 'Progress ${(p.progress * 100).round()}% • needs extra practice', Icons.support_agent),
  ]),
];

/// Course par click karne se book khulti hai: har course ke apne pages hain.
class BookScreen extends StatefulWidget {
  final Course c;
  final bool teacher;
  const BookScreen({super.key, required this.c, required this.teacher});
  @override
  State<BookScreen> createState() => _BookState();
}

class _BookState extends State<BookScreen> {
  final pc = PageController(viewportFraction: 0.92);
  int p = 0;

  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  // Button se page badalna (drag ki zaroorat nahi)
  void go(int d) {
    final n = p + d;
    if (n < 0 || n >= widget.c.pages.length) return;
    pc.animateToPage(n, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Widget bookPage(Course c, int n) {
    final pg = c.pages[n]; // [heading, arabic, text]
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 16, 6, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(width: 12, color: c.c1), // book ki spine
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(c.icon, color: c.c2, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text(pg[0], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: c.c1))),
              ]),
              const Divider(color: gold, thickness: 1.5, height: 28),
              if (pg[1].isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: c.c1.withAlpha(18), borderRadius: BorderRadius.circular(14)),
                  child: Text(pg[1], textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 32, height: 1.9, color: c.c1)),
                ),
              Text(pg[2], style: const TextStyle(fontSize: 16, height: 1.6)),
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: Text('Page ${n + 1} / ${c.pages.length}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Scaffold(
      appBar: bar(context, c.title, color: c.c1),
      body: Column(children: [
        Expanded(
          // book khulne ki animation (cover left se khulta hai)
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.4, end: 0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, a, child) => Transform(
              alignment: Alignment.centerLeft,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-a),
              child: child,
            ),
            child: PageView.builder(
              controller: pc,
              itemCount: c.pages.length,
              onPageChanged: (v) => setState(() => p = v),
              itemBuilder: (_, n) => bookPage(c, n),
            ),
          ),
        ),
        DotsIndicator(count: c.pages.length, current: p, active: c.c1, inactive: Colors.black26),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            Expanded(child: Opacity(opacity: p > 0 ? 1 : 0.4, child: AnimButton('Previous', () => go(-1), icon: Icons.arrow_back, height: 48))),
            const SizedBox(width: 12),
            Expanded(child: Opacity(opacity: p < c.pages.length - 1 ? 1 : 0.4, child: AnimButton('Next', () => go(1), icon: Icons.arrow_forward, height: 48, start: 1))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AnimButton('View lectures', () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetail(c: c, teacher: widget.teacher))), icon: Icons.menu_book),
        ),
      ]),
    );
  }
}

class CourseDetail extends StatelessWidget {
  final Course c;
  final bool teacher;
  const CourseDetail({super.key, required this.c, required this.teacher});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: teacher ? 2 : 1,
    child: Scaffold(
      appBar: bar(context, c.title,
          bottom: teacher ? const TabBar(labelColor: Colors.white, unselectedLabelColor: Colors.white70, indicatorColor: gold, tabs: [Tab(text: 'Lectures'), Tab(text: 'Students')]) : null),
      floatingActionButton: teacher ? AnimButton('Add lecture', () => addLesson(context, c), icon: Icons.add, width: 160, height: 48) : null,
      body: TabBarView(children: [
        watch(() => ListView(padding: const EdgeInsets.all(16), children: [
          Center(child: popIn(BookCover(c, size: 120))),
          const SizedBox(height: 16),
          if (!teacher) ...[ProgressBar(c.progress, green, height: 10), const SizedBox(height: 16)],
          for (final l in c.lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Tap(tint: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LessonScreen(c: c, l: l, teacher: teacher))),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: BookCover(c, size: 40),
                    title: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(lessonLabel(l.type)),
                    trailing: Icon(l.done ? Icons.check_circle : Icons.chevron_right, color: l.done ? green : Colors.grey),
                  ),
                ),
              ),
            ),
        ])),
        if (teacher)
          ListView(padding: const EdgeInsets.all(16), children: [
            for (final p in store.pupils) Card(child: ListTile(leading: CircleAvatar(child: Text(p.name[0])), title: Text(p.name), subtitle: Text('Attendance ${p.attendance}%'))),
          ]),
      ]),
    ),
  );
}

/// Lecture screen: video ki jagah course ki book ki bari picture.
class LessonScreen extends StatelessWidget {
  final Course c;
  final Lesson l;
  final bool teacher;
  const LessonScreen({super.key, required this.c, required this.l, required this.teacher});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: bar(context, l.title),
    body: watch(() => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: popIn(BookCover(c, size: 170))),
        const SizedBox(height: 22),
        Text(l.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('${c.title} • ${lessonLabel(l.type)}', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 14),
        Text(l.text, style: const TextStyle(fontSize: 16, height: 1.6)),
        const SizedBox(height: 24),
        if (!teacher)
          DoneCrossFade(
            done: l.done,
            onDone: () {
              store.done(l);
              snack(context, 'Lecture completed!');
            },
          ),
      ]),
    )),
  );
}

void addLesson(BuildContext context, Course c) {
  final title = TextEditingController(), notes = TextEditingController();
  String type = 'lecture';
  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: const Text('Add lecture'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: title, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Lecture title')),
            const SizedBox(height: 12),
            DropdownButton<String>(
              isExpanded: true,
              value: type,
              items: const [
                DropdownMenuItem(value: 'lecture', child: Text('Lecture')),
                DropdownMenuItem(value: 'pdf', child: Text('PDF notes')),
                DropdownMenuItem(value: 'lesson', child: Text('Reading')),
              ],
              onChanged: (x) {
                if (x != null) set(() => type = x);
              },
            ),
            TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes (optional)')),
          ]),
        ),
        actions: [
          AnimButton('Cancel', () => Navigator.pop(ctx), width: 100, height: 44),
          AnimButton('Add', () {
            if (title.text.trim().isEmpty) return snack(ctx, 'Enter a lecture title');
            store.addLesson(c, Lesson(title.text.trim(), type, text: notes.text.trim().isEmpty ? 'Lesson notes will appear here.' : notes.text.trim()));
            Navigator.pop(ctx);
          }, width: 100, height: 44),
        ],
      ),
    ),
  ).whenComplete(() {
    title.dispose();
    notes.dispose();
  });
}

// ======================= STUDENT PAGES =======================
class StudentTasks extends StatelessWidget {
  const StudentTasks({super.key});
  @override
  Widget build(BuildContext context) => watch(() => ListView(padding: const EdgeInsets.all(16), children: [
    QuickButtons(studentTaskBtns),
    const SizedBox(height: 14),
    for (final a in store.assignments)
      Builder(builder: (_) {
        final s = store.mySub(a);
        final graded = s?.marks != null;
        final label = graded ? 'Graded ${s!.marks}/100' : s != null ? 'Submitted' : 'Pending';
        final color = graded ? green : s != null ? Colors.blue : Colors.orange;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Tap(tint: true,
            onTap: () => s == null ? submitSheet(context, a) : showFeedback(context, a, s),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Icon(Icons.assignment, color: color, size: 32),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${a.course}\nDue ${a.due}'),
                isThreeLine: true,
                trailing: Chip(label: Text(label, style: TextStyle(color: color, fontSize: 12)), backgroundColor: color.withAlpha(25), side: BorderSide.none),
              ),
            ),
          ),
        );
      }),
  ]));
}

void submitSheet(BuildContext context, Assign a) {
  final ctl = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: ctl, maxLines: 3, decoration: const InputDecoration(labelText: 'Notes for teacher', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        AnimButton('Attach file / recording', () {}, icon: Icons.attach_file, height: 48),
        const SizedBox(height: 12),
        AnimButton('Submit assignment', () {
          if (ctl.text.trim().isEmpty) return snack(ctx, 'Please write a note for your teacher');
          store.submit(a, ctl.text.trim());
          Navigator.pop(ctx);
        }),
      ]),
    ),
  ).whenComplete(ctl.dispose);
}

void showFeedback(BuildContext context, Assign a, Sub s) => showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(a.title),
    content: Text(s.marks == null ? 'Submitted. Waiting for teacher to grade.' : 'Marks: ${s.marks}/100\n\nFeedback: ${s.feedback ?? "-"}'),
    actions: [AnimButton('OK', () => Navigator.pop(ctx), width: 100, height: 44)],
  ),
);

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});
  Widget stat(String v, String l, IconData i) => Expanded(
    child: Tap(tint: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(children: [
            Icon(i, color: gold),
            const SizedBox(height: 6),
            Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: green)),
            Text(l, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => watch(() {
    final graded = [for (final a in store.assignments) if (store.mySub(a)?.marks != null) (a, store.mySub(a)!)];
    final avg = graded.isEmpty ? 0 : graded.map((e) => e.$2.marks!).reduce((x, y) => x + y) ~/ graded.length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      QuickButtons(studentRecordBtns),
      const SizedBox(height: 14),
      Row(children: [stat('92%', 'Attendance', Icons.event_available), stat('$avg', 'Avg marks', Icons.grade), stat('${store.doneLessons}', 'Lectures done', Icons.check_circle)]),
      const SizedBox(height: 8),
      const Text('Past courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Card(child: ListTile(leading: Icon(Icons.verified, color: green), title: Text('Arabic Alphabet'), subtitle: Text('Completed • 91/100\n"Excellent makharij."'), isThreeLine: true)),
      const SizedBox(height: 8),
      const Text('Marks & feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      if (graded.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No graded assignments yet'))),
      for (final g in graded) Tap(tint: true, child: Card(child: ListTile(leading: const Icon(Icons.star, color: gold), title: Text(g.$1.title), subtitle: Text('${g.$2.marks}/100 • ${g.$2.feedback ?? ""}')))),
    ]);
  });
}

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      ('New assignment: Memorize Surah Al-Ikhlas', '2 hours ago', Icons.assignment_add),
      ('New lecture added in Tajweed Basics', 'Yesterday', Icons.menu_book),
      ('Your assignment was graded', '2 days ago', Icons.grade),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      QuickButtons(studentAlertBtns),
      const SizedBox(height: 14),
      for (final n in items) Tap(tint: true, child: Card(child: ListTile(leading: CircleAvatar(backgroundColor: green.withAlpha(30), child: Icon(n.$3, color: green)), title: Text(n.$1), subtitle: Text(n.$2)))),
    ]);
  }
}

// ======================= TEACHER PAGES =======================
class TeacherTasks extends StatelessWidget {
  const TeacherTasks({super.key});
  @override
  Widget build(BuildContext context) => watch(() => ListView(padding: const EdgeInsets.all(16), children: [
    QuickButtons(teacherTaskBtns),
    const SizedBox(height: 14),
    for (final a in store.assignments)
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Tap(tint: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubmissionsScreen(a: a))),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: const Icon(Icons.assignment, color: green, size: 32),
              title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${a.course} • Due ${a.due}\n${a.subs.length} submissions'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      ),
    const SizedBox(height: 70),
  ]));
}

void newAssignment(BuildContext context) {
  final ctl = TextEditingController();
  String course = store.courses.first.title;
  DateTime date = DateTime.now().add(const Duration(days: 7));
  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (ctx, set) => AlertDialog(
        title: const Text('New assignment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: ctl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          DropdownButton<String>(
            isExpanded: true,
            value: course,
            items: [for (final c in store.courses) DropdownMenuItem(value: c.title, child: Text(c.title))],
            onChanged: (v) => set(() => course = v!),
          ),
          Tap(
            onTap: () async {
              final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime(2030));
              if (d != null) set(() => date = d);
            },
            child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text('Due: ${date.day}/${date.month}/${date.year}')),
          ),
        ]),
        actions: [
          AnimButton('Cancel', () => Navigator.pop(ctx), width: 100, height: 44),
          AnimButton('Create', () {
            if (ctl.text.trim().isEmpty) return snack(ctx, 'Enter assignment title');
            store.addAssignment(Assign(ctl.text.trim(), course, '${date.day}/${date.month}/${date.year}', []));
            Navigator.pop(ctx);
          }, width: 100, height: 44),
        ],
      ),
    ),
  ).whenComplete(ctl.dispose);
}

class SubmissionsScreen extends StatelessWidget {
  final Assign a;
  const SubmissionsScreen({super.key, required this.a});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: bar(context, a.title),
    body: watch(() => a.subs.isEmpty
        ? const Center(child: Text('No submissions yet'))
        : ListView(padding: const EdgeInsets.all(16), children: [
      for (final s in a.subs)
        Tap(tint: true,
          onTap: () => gradeDialog(context, s),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(s.student[0])),
              title: Text(s.student),
              subtitle: Text(s.marks == null ? s.note : '${s.marks}/100 • ${s.feedback ?? ""}'),
              trailing: s.marks == null ? const Chip(label: Text('Grade'), backgroundColor: Color(0xFFFFF3D6), side: BorderSide.none) : const Icon(Icons.check_circle, color: green),
            ),
          ),
        ),
    ])),
  );
}

void gradeDialog(BuildContext context, Sub s) {
  final m = TextEditingController(text: s.marks?.toString() ?? '');
  final f = TextEditingController(text: s.feedback ?? '');
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Grade ${s.student}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: m, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Marks (0 - 100)')),
        TextField(controller: f, maxLines: 2, decoration: const InputDecoration(labelText: 'Feedback')),
      ]),
      actions: [
        AnimButton('Cancel', () => Navigator.pop(ctx), width: 100, height: 44),
        AnimButton('Save', () {
          final n = int.tryParse(m.text.trim());
          if (n == null || n < 0 || n > 100) return snack(ctx, 'Marks must be between 0 and 100');
          store.grade(s, n, f.text.trim());
          Navigator.pop(ctx);
        }, width: 100, height: 44),
      ],
    ),
  ).whenComplete(() {
    m.dispose();
    f.dispose();
  });
}

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    QuickButtons(teacherStudentBtns),
    const SizedBox(height: 14),
    for (final p in store.pupils)
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Tap(tint: true,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  CircleAvatar(backgroundColor: green.withAlpha(30), child: Text(p.name[0], style: const TextStyle(color: green))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                  Text('${p.attendance}% attendance', style: const TextStyle(fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                ProgressBar(p.progress, gold),
                const SizedBox(height: 4),
                Text('Progress ${(p.progress * 100).round()}%', style: const TextStyle(fontSize: 12)),
              ]),
            ),
          ),
        ),
      ),
  ]);
}
