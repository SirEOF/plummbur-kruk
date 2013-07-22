library plumbur_kruk_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'dart:io';

import 'package:plumbur_kruk/server.dart' as PlumburKruk;

class MockHttpRequest extends Mock implements HttpRequest {}
class MockHttpResponse extends Mock implements HttpResponse {}

main(){
  group("Core Server", (){
    test("non-existent resource results in a 404", (){
      var response = new MockHttpResponse();
      var req = new MockHttpRequest()
        ..when(callsTo('get response')).alwaysReturn(response);

      PlumburKruk.notFoundResponse(req);

      response.
        getLogs(callsTo('set statusCode', 404)).
        verify(happenedOnce);
    });
  });

  group("Running Server", (){
    var server;
    setUp((){
      return PlumburKruk.main()
        ..then((s){ server = s; });
    });

    tearDown(() => server.close());

    test("POST /stub responds successfully", (){
      new HttpClient().
        postUrl(Uri.parse("http://localhost:31337/stub")).
        then((request) {
          request.write('{"foo": 42}');
          return request.close();
        }).
        then(expectAsync1(
           (response) {
             expect(response.statusCode, 204);
           }
        ));
    });

  });
}
