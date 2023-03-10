import 'package:flutter/material.dart';
import 'package:zineplayer/Home/Screens/HomeScreen/folderList/colors_and_texts.dart';
import 'package:zineplayer/Home/Screens/PlaylistScreen/play_list_screen.dart';
import 'package:zineplayer/Home/Screen%20functions/list_item_functions.dart';
import 'package:zineplayer/functions/datamodels.dart';
import 'package:zineplayer/functions/functions.dart';

void addToPlayList({required context, required widgetpath, required duration}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
        title: Text(selectPlaylistText),
        content: playlistDailog(
            context: context, widgetpath: widgetpath, duration: duration)),
  );
}

void showDetails(
    {required context,
    required title,
    required path,
    required duration,
    required size}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: detailsDailog(path: path, duration: duration, size: size),
      );
    },
  );
}

Widget detailsDailog({required path, required duration, required size}) {
  return SizedBox(
    height: 180.0,
    width: 200.0,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text("Location : $path"),
        text("Duration : $duration"),
        text("Size : $size")
      ],
    ),
  );
}

Widget text(text) => Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.normal),
    );
double sizeHeight = 1.5;
Widget playlistDailog(
    {required widgetpath, required context, required duration}) {
  return Container(
    height: sizeHeight * 96.0,
    width: 200.0,
    color: bluecolor,
    child: Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            newPlayListDialog(context, formKey, newPlayListController);
          },
          icon: Icon(
            Icons.add,
            color: black,
          ),
          label: Text(
            createPlaylist,
            style: TextStyle(color: black),
          ),
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(white)),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: playListNotifier,
            builder:
                (BuildContext context, List<PlayList> playlist, Widget? child) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final listdata = playlist[index];
                    sizeHeight = 1;
                    sizeHeight = sizeHeight + playlist.length;
                    return Card(
                      child: ListTile(
                        onTap: () {
                          addItemToPlayList(
                              playlistFolderIndex: listdata.index,
                              context: context,
                              videoPath: widgetpath,
                              duration: duration);
                        },
                        title: Text(listdata.name),
                      ),
                    );
                  },
                  itemCount: playlist.length);
            },
          ),
        ),
        TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.cancel,
              color: white,
            ),
            label: Text(
              cancel,
              style: TextStyle(color: white),
            ))
      ],
    ),
  );
}
