import 'package:flutter/cupertino.dart';

class ChildWidget extends StatefulWidget {
  @override
  _ChildWidgetState createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {
  // Function to refresh data in Widget B
  void refreshData() {
    print('Data in Child Widget refreshed!');
    // Add your logic to refresh data here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Child Widget'),
    );
  }
}