// import 'package:fluffy/models/events.dart';
// import 'package:flutter/material.dart';
//
// class EventCard extends StatefulWidget {
//   const EventCard({
//     super.key,
//     required this.event,
//   });
//
//   final Event event;
//
//   @override
//   State<EventCard> createState() => _EventCardState();
// }
//
// class _EventCardState extends State<EventCard> {
//   bool _isEnabled = true;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     print("initState");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("Build");
//
//     return Card(
//       color: Colors.blue,
//       elevation: 30,
//       shadowColor: Colors.black,
//       margin: EdgeInsets.symmetric(vertical: 7),
//       child: ListTile(
//         enableFeedback: _isEnabled,
//         title: Text(
//           widget.event.name, style: TextStyle(fontSize: 20),
//         ),
//         leading: IconButton(
//           icon: _isEnabled ? Icon(Icons.check_box_outline_blank) : Icon(Icons.check_box),
//           onPressed: () => setState(() => _isEnabled = !_isEnabled,
//         )),
//         onTap: () => print("${widget.event.name} - tap"),
//         onLongPress: () => print("${widget.event.name} - longpress"),
//         enabled: true,
//       ),
//     );
//   }
// }