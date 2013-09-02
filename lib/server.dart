library plummbur_kruk;

import 'dart:io';
import 'package:json/json.dart' as JSON;

import 'package:dirty/dirty.dart';
import 'package:uuid/uuid.dart';
import 'package:ansicolor/ansicolor.dart';

Uuid uuid = new Uuid();
Dirty db = new Dirty('test.db');

var stub;

main() {
  var port = Platform.environment['PORT'] == null ?
    31337 : int.parse(Platform.environment['PORT']);

  setEnvOptions();

  return HttpServer.bind('127.0.0.1', port)..then((app) {

    app.listen((HttpRequest req) {
      log(req);

      HttpResponse res = req.response;
      res.headers
        ..add('Access-Control-Allow-Origin', 'null')
        ..add('Access-Control-Allow-Headers', 'Content-Type')
        ..add('Access-Control-Allow-Methods', 'DELETE,PUT');

      if (req.method == 'OPTIONS') {
        handleOptions(req);
        return;
      }

      if (stub != null) {
        req.response.write(stub);
        req.response.close();
        stub = null;
        return;
      }

      var path = req.uri.path;
      if (aliases.containsKey(path)) {
        path = aliases[path];
      }

      if (path == '/ping') {
        return req.response
          ..statusCode = HttpStatus.OK
          ..close();
      }

      if (path.startsWith('/stub')) {
        addStub(req);
        return;
      }

      if (path.startsWith('/alias')) {
        addAlias(req);
        return;
      }

      if (path.startsWith('/widgets')) {
        handleWidgets(req);
        return;
      }

      notFoundResponse(req);
    },
    onDone: removeDb);

    print('Server started on port: ${port}');
  });
}

setEnvOptions() {
  if (Platform.environment['CI'] == 'true') color_disabled = true;
}

addStub(req) {
  req.toList().then((list) {
    stub = new String.fromCharCodes(list[0]);

    HttpResponse res = req.response;
    res.statusCode = HttpStatus.NO_CONTENT;
    res.close();
  });
}

Map aliases = {};
addAlias(req) {
  req.toList().then((list) {
    var body = new String.fromCharCodes(list[0]);
    var alias = Uri.splitQueryString(body);
    aliases[alias['new']] = alias['old'];

    HttpResponse res = req.response;
    res.statusCode = HttpStatus.NO_CONTENT;
    res.close();
  });
}

handleWidgets(req) {
  var r = new RegExp(r"/widgets/([-\w\d]+)");
  var id_path = r.firstMatch(req.uri.path),
      id = (id_path == null) ? null : id_path[1];

  if (req.method == 'GET' && id == null) return readWidgetCollection(req);
  if (req.method == 'POST') return createWidget(req);
  if (req.method == 'GET' && id != null) return readWidget(id, req);
  if (req.method == 'PUT' && id != null) return updateWidget(id, req);
  if (req.method == 'DELETE' && id != null) return deleteWidget(id, req);

  notFoundResponse(req);
}

createWidget(req) {
  HttpResponse res = req.response;

  req.toList().then((list) {
    var post_data = new String.fromCharCodes(list[0]);
    var widget = JSON.parse(post_data);
    widget['id'] = uuid.v1();

    db[widget['id']] = widget;

    res.statusCode = 201;
    res.headers.contentType =
      new ContentType("application", "json", charset: "utf-8");

    res.write(JSON.stringify(widget));
    res.close();
  });
}

readWidgetCollection(req) {
  HttpResponse res = req.response;
  res.headers.contentType =
    new ContentType("application", "json", charset: "utf-8");

  res.write(JSON.stringify(db.values.toList()));
  res.close();
}

readWidget(id, req) {
  HttpResponse res = req.response;

  if (db[id] == null) return notFoundResponse(req);

  res.headers.contentType =
    new ContentType("application", "json", charset: "utf-8");

  res.write(JSON.stringify(db[id]));
  res.close();
}

updateWidget(id, req) {
  HttpResponse res = req.response;

  if (!db.containsKey(id)) return notFoundResponse(req);

  req.
    toList().
    then((list) {
      var data = list.expand((i)=>i),
          body = new String.fromCharCodes(data),
          widget = db[id] = JSON.parse(body);

      res.statusCode = HttpStatus.OK;
      res.headers.contentType =
        new ContentType("application", "json", charset: "utf-8");

      res.write(JSON.stringify(widget));
      res.close();
    });
}

deleteWidget(id, req) {
  if (id == 'ALL') {
    db.clear();
  }
  else {
    if (!db.containsKey(id)) return notFoundResponse(req);
    db.remove(id);
  }

  HttpResponse res = req.response;
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

handleOptions(req) {
  HttpResponse res = req.response;
  res.statusCode = HttpStatus.OK;
  res.close();
}

notFoundResponse(req) {
  HttpResponse res = req.response;
  res.statusCode = HttpStatus.NOT_FOUND;
  res.close();
}

removeDb() {
  var db_file = new File('test.db');
  if (!db_file.existsSync()) return;
  db_file.deleteSync();
}

log(req) {
  req.response.done.then((res){
    var now = new DateTime.now();
    print('[${now}] "${req.method} ${req.uri.path}" ${logStatusCode(res)}');
  });
}

final AnsiPen red = new AnsiPen()..red(bold: true);
final AnsiPen green = new AnsiPen()..green(bold: true);

logStatusCode(HttpResponse res) {
  var code = res.statusCode;
  if (code > 399) return red(code);
  return green(code);
}
