import 'package:flutter/material.dart';

// ======================= COLORS =======================
const green = Color(0xFF0F5C3F);
const light = Color(0xFF1B8A5E);
const gold = Color(0xFFD4A937);
const bg = Color(0xFFF4F7F5);
const grad = LinearGradient(colors: [green, light], begin: Alignment.topLeft, end: Alignment.bottomRight);


// =====================================================================
//  ANIMATED CONTAINER WIDGETS
//  Is file ke sab widgets AnimatedContainer / AnimatedScale use karte hain.
// =====================================================================

/// Har tap par widget thora sa bara hota hai (colour bhi badalta hai) aur phir wapas normal ho jata hai.
/// onStart: tap shuru hote hi chalta hai, onTap: animation ke baad chalta hai.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap, onStart;
  final bool tint; // true: click par card ka colour badalta hai
  final double radius;
  const Tap({super.key, required this.child, this.onTap, this.onStart, this.tint = false, this.radius = 14});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  static const tints = [Color(0xFF1565C0), Color(0xFF8E24AA), Color(0xFFE65100), Color(0xFFC62828), Color(0xFF00897B), Color(0xFF0F5C3F)];
  double scale = 1;
  bool busy = false;
  int ti = -1;

  Future<void> press() async {
    if (busy) return;
    busy = true;
    widget.onStart?.call();
    setState(() {
      scale = 1.1; // thora bara
      if (widget.tint) ti = (ti + 1) % tints.length; // colour badlo
    });
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    setState(() => scale = 1.0); // wapas normal
    await Future.delayed(const Duration(milliseconds: 180));
    busy = false;
    if (mounted) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: press,
    child: AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: widget.tint
          ? Stack(clipBehavior: Clip.none, children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: ti < 0 ? tints[0].withAlpha(0) : tints[ti].withAlpha(70),
                borderRadius: BorderRadius.circular(widget.radius),
              ),
            ),
          ),
        ),
      ])
          : widget.child,
    ),
  );
}

/// Button: har click par thora bara hota hai aur colour badal jata hai.
class AnimButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;
  final double width, height;
  final int start; // shuru ka colour (alag alag buttons ke liye)
  const AnimButton(this.text, this.onTap, {super.key, this.icon, this.width = double.infinity, this.height = 54, this.start = 0});
  @override
  State<AnimButton> createState() => _AnimButtonState();
}

class _AnimButtonState extends State<AnimButton> {
  static const colors = [green, Color(0xFF1565C0), Color(0xFF8E24AA), Color(0xFFE65100), Color(0xFFC62828), Color(0xFF00897B)];
  late int c = widget.start % colors.length;

  @override
  Widget build(BuildContext context) => Tap(
    onStart: () => setState(() => c = (c + 1) % colors.length),
    onTap: widget.onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors[c],
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: colors[c].withAlpha(90), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: 20), const SizedBox(width: 6)],
        Flexible(child: Text(widget.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
      ]),
    ),
  );
}

/// AnimatedContainer: select hone par size, colour, radius aur shadow smoothly badalte hain.
class RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const RoleCard(this.title, this.icon, this.selected, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Tap(
    onStart: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: selected ? 24 : 14, horizontal: 10),
      decoration: BoxDecoration(
        color: selected ? green : Colors.white,
        borderRadius: BorderRadius.circular(selected ? 30 : 14),
        border: Border.all(color: green, width: selected ? 0 : 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(selected ? 60 : 10), blurRadius: selected ? 16 : 5, offset: const Offset(0, 4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: selected ? 40 : 28, color: selected ? Colors.white : green),
        const SizedBox(height: 4),
        Text("I'm a $title", style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black87)),
      ]),
    ),
  );
}

/// Slideshow ke dots: active dot AnimatedContainer se lamba hota hai.
class DotsIndicator extends StatelessWidget {
  final int count, current;
  final Color active, inactive;
  const DotsIndicator({super.key, required this.count, required this.current, this.active = gold, this.inactive = Colors.white38});

  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    for (int n = 0; n < count; n++)
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        width: n == current ? 26 : 8,
        height: 8,
        decoration: BoxDecoration(color: n == current ? active : inactive, borderRadius: BorderRadius.circular(8)),
      ),
  ]);
}

/// Text field (password par eye icon ke saath)
class AppField extends StatefulWidget {
  final TextEditingController c;
  final String label;
  final IconData icon;
  final bool pass;
  final TextInputType? kt;
  const AppField(this.c, this.label, this.icon, {super.key, this.pass = false, this.kt});
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool hide = true;

  OutlineInputBorder border(Color c, [double w = 1]) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: widget.c,
      keyboardType: widget.kt,
      obscureText: widget.pass && hide,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon, color: green),
        suffixIcon: widget.pass
            ? Tap(onTap: () => setState(() => hide = !hide), child: Icon(hide ? Icons.visibility_off : Icons.visibility))
            : null,
        filled: true,
        fillColor: Colors.white,
        border: border(Colors.grey.shade300),
        enabledBorder: border(Colors.grey.shade300),
        focusedBorder: border(green, 2),
      ),
    ),
  );
}
