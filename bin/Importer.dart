import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'Cryptocurrency.dart';
import 'Currencies.dart';
import 'Price.dart';
import 'Utils.dart';

abstract class Importer {

	String baseURL;
	
}

class CoinGeckoImporter extends Importer {

	Cryptocurrency cryptocurrency;
	Currency currency;

	CoinGeckoImporter(Cryptocurrency cryptocurrency, Currency currency) {
		this.baseURL="https://api.coingecko.com/api/v3/";
		this.cryptocurrency=cryptocurrency;
		this.currency=currency;
	}

	Future<Price> getCurrentPrice() async {
		String url = baseURL+"simple/price?ids="+cryptocurrency.id+"&vs_currencies="+convertCurrencyToString(currency);

		double price;

		Response response = await get(url);
		
		if(response.statusCode==200) {
			dynamic content = jsonDecode(response.body);
			price = content[cryptocurrency.id][convertCurrencyToString(currency).toLowerCase()];
			return Price(price,DateTime.now().millisecondsSinceEpoch);
		} else {
			throw Exception("Cannot get price. This is most likely an API issue.");
		}
	}

	Future<List<Price>> getMarketChart(int days) async {
		String url = baseURL+"coins/"+cryptocurrency.id+"/market_chart?vs_currency="+convertCurrencyToString(currency)+"&days="+days.toString();

		Response response = await get(url);

		if(response.statusCode==200) {
			dynamic content = jsonDecode(response.body);
			return Utils.convertToPriceList(content);
		} else {
			throw Exception("Cannot get prices. This is most likely an API issue.");
		}

	}
}

class BacktestImporter extends Importer {

	String fileContents;

	BacktestImporter(File file) {
		this.fileContents = file.readAsStringSync();
	}

	getData() {
		Utils.convertToPriceList(jsonDecode(this.fileContents));
	}
}

class HttpService {
	
}