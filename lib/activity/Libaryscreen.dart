import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/database_helper.dart';
import 'package:nb_utils/nb_utils.dart';

class OfflineScreen extends StatefulWidget {
  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen>
    with AfterLayoutMixin<OfflineScreen> {
  final dbHelper = DatabaseHelper.instance;
  var downloadedList = List<DownloadedBook>();
  bool mIsLoading = false;
  String firstName = "";

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  DownloadedBook isExists(
      List<DownloadedBook> tasks, BookInfoDetails mBookDetail) {
    DownloadedBook exist;
    tasks.forEach((task) {
      if (task.bookId == mBookDetail.id.toString()) {
        exist = task;
      }
    });
    if (exist == null) {
      exist = defaultBook(mBookDetail, "purchased");
    }
    return exist;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    fetchData(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget blankView = Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(spacing_standard_30),
            child: Image.asset(
              "logo.png",
              width: 150,
            ),
          ),
          Text(
            keyString(context, 'lbl_book_not_available'),
            style: TextStyle(
                fontSize: fontSizeLarge,
                color: appStore.appTextPrimaryColor,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );

    Widget getList(List<DownloadedBook> list, context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
          width: MediaQuery.of(context).size.width,
          child: (list.length < 1)
              ? blankView
              : Column(
                  children: [
                    GridView.builder(
                      itemCount: list.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: getChildAspectRatio(),
                        crossAxisCount: getCrossAxisCount(),
                      ),
                      controller: ScrollController(keepScrollOffset: false),
                      itemBuilder: (context, index) {
                        DownloadedBook bookDetail = list[index];
                        return GestureDetector(
                          onTap: () {
                            /* _settingModalBottomSheet(
                                context, list);*/
                            readFile(context, bookDetail.filePath,
                                bookDetail.bookName,
                                isCloseApp: false);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            width: bookWidth,
                            height: bookHeight,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: bookWidth,
                                  height: bookHeight,
                                  child: Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Center(
                                        child: bookLoaderWidget,
                                      ),
                                      imageUrl: bookDetail.frontCover,
                                      fit: BoxFit.fill,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 5,
                                    margin: EdgeInsets.all(8),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(left: 8, right: 8),
                                    child: Text(
                                      bookDetail.bookName,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: appStore.textSecondaryColor,
                                          fontSize: fontSizeSmall),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: keyString(context, 'lbl_offline_book')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          (!mIsLoading)
              ? getList(downloadedList, context)
              : appLoaderWidget.center().visible(mIsLoading),
        ],
      ),
    );
  }

  void fetchData(context) async {
    mIsLoading = true;
    List<DownloadedBook> books = await dbHelper.queryAllRows();
    if (books.isNotEmpty) {
      downloadedList.clear();
      downloadedList.addAll(books);
      setState(() {
        mIsLoading = false;
      });
    } else {
      setState(() {
        downloadedList.clear();
      });
    }
  }

/* void _settingModalBottomSheet(
      context, List<DownloadedBook> mDownload) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          primary: false,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: spacing_standard_new,
                      ),
                      padding: EdgeInsets.only(right: spacing_standard),
                      child: Text(
                        "All Files",
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: appStore.appTextPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: appStore.iconColor,
                        size: 30,
                      ),
                      onTap: () => {Navigator.of(context).pop()},
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: spacing_standard_new),
                  height: 2,
                  color: lightGrayColor,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return DownloadFilesViewOffline(
                        mDownload[index].bookId,
                        mDownload[index],
                        mDownload[index].frontCover,
                        mDownload[index].bookName,
                        isOffline: true,
                      );
                    },
                    itemCount: viewFiles.length,
                    shrinkWrap: true,
                  ),
                ).visible(viewFiles.isNotEmpty),
              ],
            ),
          ),
        );
      },
    );
  }*/
}
