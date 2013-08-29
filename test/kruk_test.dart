part of plummbur_kruk_test;

kruk_tests() {
  group("The Mighty Kruk", (){
    test("is alive", (){
      expect(Kruk.isAlive, isTrue);
    });

    test("Can alias a route in the server", (){
      schedule(()=> post('${Kruk.SERVER_ROOT}/widgets', '{"name": "Sandman"}'));
      schedule(()=> Kruk.alias('/widgets', as: '/comics'));

      var ready = schedule(()=> get('${Kruk.SERVER_ROOT}/comics'));
      schedule(() {
        ready.then((json) {
          var list = JSON.parse(json);
          expect(list.first['name'], 'Sandman');
        });
      });
    });

    test("can create records", (){
      schedule(()=> Kruk.create('{"name": "Sandman"}'));

      var ready = schedule(()=> get('${Kruk.SERVER_ROOT}/comics'));
      schedule(() {
        ready.then((json) {
          var list = JSON.parse(json);
          expect(list.first['name'], 'Sandman');
        });
      });
    });


    test("can delete all records", (){
      schedule(()=> Kruk.create('{"name": "Sandman"}'));
      schedule(()=> Kruk.create('{"name": "V for Vendetta"}'));
      schedule(()=> Kruk.deleteAll());

      var ready = schedule(()=> get('${Kruk.SERVER_ROOT}/comics'));
      schedule(() {
        ready.then((json) {
          expect(json, '[]');
        });
      });
    });

  });
}
