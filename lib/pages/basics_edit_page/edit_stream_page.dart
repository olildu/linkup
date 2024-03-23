import 'package:demo/elements/profile_elements/elements.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class EditStream extends StatefulWidget {
  final String title;
  final IconData type;

  const EditStream({Key? key, required this.title, required this.type}) : super(key: key);

  @override
  State<EditStream> createState() => EditStreamState();
}

class GenderBuilder extends StatefulWidget {
  final String gender;

  const GenderBuilder({Key? key, required this.gender}) : super(key: key);

  @override
  _GenderBuilderState createState() => _GenderBuilderState();
}

class _GenderBuilderState extends State<GenderBuilder> {
  bool _isSelected = false;
  bool _isSelectedWoman = false;
  bool _isSelectedMan = false;
  bool _isSelectedOthers = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle the selected state if not already selected
          _isSelected = !_isSelected;

          // Uncheck other options based on the selected gender
          switch (widget.gender) {
            case "Woman":
              _isSelectedWoman = _isSelected;
              _isSelectedMan = false;
              _isSelectedOthers = false;
              break;
            case "Man":
              _isSelectedWoman = false;
              _isSelectedMan = _isSelected;
              _isSelectedOthers = false;
              break;
            case "Others":
              _isSelectedWoman = false;
              _isSelectedMan = false;
              _isSelectedOthers = _isSelected;
              setState(() {
                
              });
              break;

          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: _isSelected ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              widget.gender,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            _isSelected
                ? Icon(
                    Icons.radio_button_checked,
                  )
                : Icon(
                    Icons.radio_button_unchecked_rounded,
                  ),
          ],
        ),
      ),
    );
  }
}



class EditStreamState extends State<EditStream> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   showSearch(context: context, delegate: CustomSearchDelegate());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate());
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleAndSubtitle("Choose your ${widget.title.toLowerCase()}", "Select your ${widget.title.toLowerCase()}"),
            const SizedBox(height: 30,),
            GestureDetector(
              onTap: () {
                showSearch(context: context, delegate: CustomSearchDelegate());
              },
              child: childrenBuilder(widget.type, widget.title)
            ),
            const SizedBox(height: 30,),

          ],
        ),
      ),
    );
  }
}


class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Text(
            'Nothing found for: $query',
            style: GoogleFonts.poppins(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      Transform.translate(
        offset: Offset(-5, 0),
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Sample data to search for
    final List<String> streamsData = [
      'B.Tech',
      'BBA',
      'LLB',
      'BA',
      'B.Arch',
      'B.Sc',
      'BBA',
      'B.Com',
      'BCA',
      'BHM',
      'LLB',
      'B.Des',
      'BFA',
      'M.Arch',
      'M.Des',
      'M.FA',
      'M.Plan',
      'M.A',
      'M.Sc',
      'M.Tech',
      'LLM',
      'MBA',
      'PhD',
    ];

    final List<String> streams = query.isEmpty
        ? streamsData
        : streamsData.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: streams.length,
      itemBuilder: (BuildContext context, int index) {
        final String suggestion = streams[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            close(context, suggestion);
          },
        );
      },
    );
  }
}
