library plummbur_kruk_test;

import 'package:scheduled_test/scheduled_test.dart';
import 'dart:html';
import 'package:json/json.dart' as JSON;

import 'package:plummbur_kruk/kruk.dart';

part 'kruk_test.dart';

final String URL_ROOT = '${Kruk.SERVER_ROOT}/widgets';

main() {
  kruk_tests();

  group("/widgets -", (){
    setUp(() {
      currentSchedule.
        onComplete.
        schedule(() {
          return HttpRequest.request('${URL_ROOT}/ALL', method: 'delete');
        });
    });

    test("can POST new records", (){
      var responseReady = schedule(() {
        return HttpRequest.
          request(URL_ROOT, method: 'post', sendData: '{"test": 42}');
      });

      schedule(() {
        responseReady.then((req) {
          var rec = JSON.parse(req.response);
          expect(rec['test'], 42);
        });
      });
    });

    test("can GET the list of records", (){
      schedule(()=> post(URL_ROOT, '{"test": 1}'));
      schedule(()=> post(URL_ROOT, '{"test": 2}'));
      schedule(()=> post(URL_ROOT, '{"test": 3}'));
      var response = schedule(()=> get(URL_ROOT));

      schedule(() {
        response.then((json) {
          var list = JSON.parse(json);
          expect(list.length, 3);
        });
      });
    });
  });


  group("/widgets/:id -", (){
    var id;
    setUp(() {
      schedule(() {
        return post(URL_ROOT, '{"test": 1}').
          then((req) {
            var rec = JSON.parse(req.response);
            id = rec['id'];
          });
      });

      currentSchedule.
        onComplete.
        schedule(()=> delete('${URL_ROOT}/ALL'));
    });

    test("can GET existing records", (){
      var response = schedule(()=> get('$URL_ROOT/$id'));

      schedule(() {
        response.then((json) {
          var rec = JSON.parse(json);
          expect(rec['test'], 1);
        });
      });
    });

    test("can PUT updates to existing records", (){
      schedule(()=> put('$URL_ROOT/$id', '{"test": 42}'));
      var response = schedule(()=> get('$URL_ROOT/$id'));

      schedule(() {
        response.then((json) {
          var rec = JSON.parse(json);
          expect(rec['test'], 42);
        });
      });
    });

    test("can DELETE existing records", (){
      schedule(()=> delete('$URL_ROOT/$id'));
      var response = schedule((){
        return HttpRequest.request('$URL_ROOT/$id')
          .then((_) { fail('Successful request to non-existent resource?!'); })
          .catchError((e)=> e.target);
      });

      schedule(() {
        response.then((res) {
          expect(res.status, 404);
        });
      });
    });
  });

  test("Complete", (){
    schedule((){
      window.postMessage('done', window.location.href);
    });
  });
}

Future<String> get(url)=> HttpRequest.getString(url);

Future<HttpRequest> post(url, data) {
  return HttpRequest.request(url, method: 'post', sendData: data);
}

Future<HttpRequest> put(url, data) {
  return HttpRequest.request(url, method: 'put', sendData: data);
}

Future<HttpRequest> delete(url)=> HttpRequest.request(url, method: 'delete');



pollForDone() {
  // if (tests.every((t)=> t.isComplete)) {
  if (currentSchedule == null) {
    window.postMessage('done', window.location.href);
    return;
  }

  var wait = new Duration(milliseconds: 100);
  new Timer(wait, ()=> pollForDone(tests));
}
