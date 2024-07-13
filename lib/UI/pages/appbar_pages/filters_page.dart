import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Better your search", style: GoogleFonts.poppins(),),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close)
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Coming Soon...", style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w300),)
      ),
    );
  }
}
