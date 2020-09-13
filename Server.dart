import 'dart:io';
import 'Cryptocurrency.dart';
import 'Trader.dart';

Future main() async {
  var server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    4040,
  );
  print('Listening on localhost:${server.port}');

	Cryptocurrency cryptocurrency = new Cryptocurrency("bitcoin","btc","Bitcoin");
	Trader trader = LevelUpTrader(cryptocurrency,10,.01,.5);

  await for (HttpRequest request in server) {
	print("Request");
    request.response.write(trader.funds.toString()+"\n"+trader.heldFunds.toString());
    await request.response.close();
  }
}