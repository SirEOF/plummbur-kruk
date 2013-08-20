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
  });
}
