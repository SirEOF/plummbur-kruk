library kruk;

import 'dart:html';

class Kruk {
  static String SERVER_ROOT = 'http://localhost:31337';

  static Future<HttpRequest> alias(String old_url, {as: String}) {
    return HttpRequest.request(
      '${SERVER_ROOT}/alias',
      method: 'post',
      sendData: 'old=${Uri.encodeComponent(old_url)}&' +
                'new=${Uri.encodeComponent(as)}'
    );
  }

  static bool get isAlive {
    var req = new HttpRequest()
      ..open('get', '${SERVER_ROOT}/ping', async: false)
      ..send();

    return req.status == 200;
  }

  static Future<HttpRequest> create(String json) {
    return HttpRequest.request(
      '${SERVER_ROOT}/widgets',
      method: 'post',
      sendData: json
    );
  }

  static Future<HttpRequest> deleteAll() {
    return HttpRequest.request(
      '${SERVER_ROOT}/widgets/ALL',
      method: 'delete'
    );
  }
}
