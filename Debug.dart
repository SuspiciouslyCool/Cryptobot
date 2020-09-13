import 'dart:io';

import 'Cryptocurrency.dart';
import 'Backtester.dart';
import 'Trader.dart';
import 'Importer.dart';
import 'Currencies.dart';


main(List<String> args) {

Cryptocurrency cryptocurrency = new Cryptocurrency("bitcoin","btc","Bitcoin");
CoinGeckoImporter i = new CoinGeckoImporter(cryptocurrency, Currency.CHF);
// print(i.getMarketChart(2).then((list) {print(list);}));
	// Trader trader = LevelUpBacktestTrader(cryptocurrency,10,.02,.25,File("./data/btc-14d-10-9-20.json"));
Trader trader = LevelUpTrader(cryptocurrency,10,.01,.5);
}