import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

// ignore: must_be_immutable
class VerticalStepper extends StatefulWidget {
  List<Step>? steps;
  double? dashLength;
  Color? iconColor;
  VerticalStepper({this.steps, this.dashLength, this.iconColor});

  @override
  _VerticalStepperState createState() => _VerticalStepperState();
}

class _VerticalStepperState extends State<VerticalStepper> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Positioned(
              height: 1000,
              top: 23,
              left: 27,
              child: DottedLine(
                dashLength: widget.dashLength != null ? widget.dashLength! : 5,
                direction: Axis.vertical,
                lineLength: double.infinity,
                dashColor: Colors.black,
              ),
            ),
            Column(
              children: [
                for (int i = 0; i < widget.steps!.length - 1; i++)
                  Container(
                    child: widget.steps![i],
                  )
              ],
            )
          ],
        ),
        Stack(
          children: [
            Positioned(
              top: 4,
              left: 27,
              child: DottedLine(
                direction: Axis.vertical,
                lineLength: 22,
                dashColor: Colors.black,
                dashLength: widget.dashLength!,
              ),
            ),
            Container(
              child: widget.steps!.last,
            )
          ],
        )
      ],
    );
  }
}

class Step extends StatefulWidget {
  final String? title;
  final Widget? content;
  final Color? iconStyle;
  final bool? shimmer;
  final bool? isExpanded;
  final Function(bool)? onExpansion;

  const Step({
    this.title,
    this.content,
    this.iconStyle,
    this.shimmer = false,
    this.isExpanded = false,
    this.onExpansion,
  });

  @override
  _StepState createState() => _StepState();
}

class _StepState extends State<Step> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: widget.isExpanded!,
        onExpansionChanged: widget.onExpansion,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                child: Stack(children: [
                  Icon(
                    Icons.circle,
                    color: widget.iconStyle != null
                        ? widget.iconStyle
                        : Colors.white,
                  ),
                ]),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 1.5),
                        blurRadius: 0.5)
                  ],
                ),
              ),
            ),
          ],
        ),
        title: Text(widget.title!),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 69.0),
            child: Column(
              children: [widget.content!],
            ),
          ),
        ],
      ),
    );
  }
}
