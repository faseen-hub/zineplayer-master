import 'package:flutter/material.dart';
import 'package:zineplayer/AccessFolders/loadFolders.dart';
import 'package:zineplayer/Home/Screens/Folder%20Screen/access_video_data.dart';

class FolderContainer extends StatelessWidget {
  final int index;

  const FolderContainer({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    loadFolders.value.sort((a, b) {
      //sorting in ascending order
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
    //(a, b) => a.length.compareTo(b.length));

    //log(loadFolders.value[index].split("/").last);
    return SizedBox(
      height: 80,
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  VideoList(folderPath: loadFolders.value[index]),
            ));
          },
          title: Text(loadFolders.value[index].split("/").last),
          leading: const Icon(
            Icons.folder,
            size: 60.0,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}