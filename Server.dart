import 'dart:convert';
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
	LevelUpTrader trader = LevelUpTrader(cryptocurrency,10,.01,.5);

  	await for (HttpRequest request in server) {
		Object responseObject = {
			"cryptocurrency": trader.cryptocurrency.symbol,
			"investedfunds": trader.funds,
			"heldFunds":trader.heldFunds,
		};
		dynamic json = jsonEncode(responseObject);
		request.response.write(json);
		await request.response.close();
  	}
}