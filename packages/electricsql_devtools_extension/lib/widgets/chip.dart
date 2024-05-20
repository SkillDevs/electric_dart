import 'package:flutter/material.dart';

typedef FgAndBgColor = ({
  Color fgColor,
  Color bgColor,
});

const kChipColorGreen = (
  fgColor: Color(0xff67d796),
  bgColor: Color(0xff213328),
);

const kChipColorRed = (
  fgColor: Color(0xfff69b94),
  bgColor: Color(0xff3d1c1f),
);

const kChipColorOrange = (
  fgColor: Color(0xfff7a463),
  bgColor: Color(0xff36261a),
);

const kChipColorGrey = (
  fgColor: Color(0xFFCDD3D0),
  bgColor: Color(0xff272827),
);

class ColoredChip extends StatelessWidget {
  const ColoredChip({
    super.key,
    required this.label,
    required this.fgAndBgColor,
  });

  final FgAndBgColor fgAndBgColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(1),
      side: const BorderSide(width: 0, color: Colors.transparent),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: fgAndBgColor.fgColor,
        ),
      ),
      color: WidgetStatePropertyAll(
        fgAndBgColor.bgColor,
      ),
    );
  }
}
