import 'dart:convert';
import 'Price.dart';

class Utils {

	Utils() {
		throw new Exception("Cannot instantiate class Utils. Use static methods instead");
	}

	static List<Price> convertToPriceList(dynamic json) {
		List<dynamic> priceList = json["prices"];
		List<Price> prices = List<Price>();
		for (dynamic item in priceList) {
		  prices.add(Price(item[1],item[0]));
		}
		return prices;
	}
}