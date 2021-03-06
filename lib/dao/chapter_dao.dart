import 'dart:io';

import 'package:book_reader/entity/book_chapter.dart';
import 'package:book_reader/entity/book_content.dart';
import 'package:book_reader/entity/book_info.dart';
import 'package:book_reader/global/global_info.dart';

class ChapterDao {
  ChapterDao();

  loadChaptersByBook(BookInfo bookInfo) async {
    var database = await GlobalInfo.dbDao.getConnection();
    var query = await database
        .query(tableChapter, where: "bookId=?", whereArgs: [bookInfo.id]);
    return query.map((e) {
      return Chapter.formMap(e);
    }).toList();
  }

  saveBookChapters(BookInfo bookInfo) async {
    var database = await GlobalInfo.dbDao.getConnection();
    await database
        .delete(tableChapter, where: "bookId=?", whereArgs: [bookInfo.id]);
    bookInfo.chapters.forEach((Chapter e) {
      e.bookId = bookInfo.id;
      database.insert(tableChapter, e.toMap());
    });
  }

  Future<BookInfo> parseBookFromNet(String url) async {
    return await GlobalInfo.bookParseFactory.parseBookInfo(url);
  }

  Future<BookContent> loadContent(Chapter chapter) async {
    File file =
        File(await GlobalInfo.dbDao.getFilePath() + chapter.savePath + ".txt");
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      BookContent c = await GlobalInfo.bookParseFactory
          .parseChapterContent(chapter.netPath);
      file.writeAsString(c.content);
      return c;
    }
    return BookContent(await file.readAsString());
  }
}
