import 'package:demo/api/api_calls.dart';
import 'package:demo/elements/profile_elements/elements.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditStream extends StatefulWidget {
  final String title;
  final IconData type;
  final String data;

  const EditStream({Key? key, required this.title, required this.type, required this.data}) : super(key: key);

  @override
  State<EditStream> createState() => EditStreamState();
}

class EditStreamState extends State<EditStream> {
  @override
  void initState() {
    super.initState();
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
              child: childrenBuilder1(widget.type, widget.title, widget.data)
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
        offset: const Offset(-5, 0),
        child: IconButton(
          icon: const Icon(Icons.clear),
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
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
            Map userDataTags = {
              "uid": userValues.uid,
              'type': 'uploadTagData',
              'key': userValues.cookieValue,
              'keyToUpdate': "stream",
              'value': suggestion
            };
            ApiCalls.uploadUserTagData(userDataTags);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
