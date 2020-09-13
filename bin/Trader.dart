import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

import 'Cryptocurrency.dart';
import 'Price.dart';
import 'Importer.dart';
import 'Currencies.dart';

abstract class Trader {

	Cryptocurrency cryptocurrency;

	bool held;

	Price buyPrice;

	double ownedCurrency;
	double funds;
	double heldFunds;

	double profitPercentage;
	double reinvestmentPercentage;

	Trader(Cryptocurrency cryptocurrency, double funds, double profitPercentage, double reinvestmentPercentage) {
		this.cryptocurrency=cryptocurrency;
		this.funds=funds;
		this.profitPercentage=profitPercentage;
		this.reinvestmentPercentage=reinvestmentPercentage;
		this.heldFunds=0;
		held=false;
	}

	void train(List<Price> data);
	bool buy(Price price);
	bool sell(Price price);
}

class LevelUpTrader extends Trader {

	double average;

	int days;

	CoinGeckoImporter importer;

	LevelUpTrader(Cryptocurrency cryptocurrency, double funds, double profitPercentage, double reinvestmentPercentage) : super(cryptocurrency, funds, profitPercentage, reinvestmentPercentage) {
		
		this.days=7;

		importer = CoinGeckoImporter(cryptocurrency, Currency.CHF);
		importer.getMarketChart(this.days).then((data) {
			train(data);
			run();
			});
  	}
	
	@override
  	void train(List<Price> data) {
		this.average=0;
		for (Price price in data) {
			this.average+=price.price;
		}
		this.average/=data.length;
		print("Moving average: "+this.average.toString());
  	}

	void run() async{
		while(true) {
			Price price = await importer.getCurrentPrice();
			print(price.price);	
			if(price.price<this.average&&!held) {
				held=buy(price);
				buyPrice=price;
			}
			if(held&&price.price>=buyPrice.price+(this.profitPercentage*buyPrice.price)) {
				sell(price);
				held=false;
			}
			await Future.delayed(Duration(seconds: 10));
			// sleep(Duration(seconds: 10));
		}
	}

	@override
  	bool buy(Price price) {
		ownedCurrency = (1/price.price)*this.funds;
		double profitMargin=(price.price+(this.profitPercentage*price.price));
		AnsiPen buy = AnsiPen()..white(bold: true)..yellow(bg: true);
		print(buy("BUY")+" | "+ownedCurrency.toString()+" "+cryptocurrency.name+" at "+price.price.toString());
		print("Waiting for: "+profitMargin.toString());
		
    	return true;
  	}

	@override
  	bool sell(Price price) {
		double revenue = ownedCurrency*price.price;
		double profit = revenue-funds;

		AnsiPen sell = AnsiPen()..white(bold: true)..green(bg: true);
		print(sell("SELL")+" | "+ownedCurrency.toString()+" "+cryptocurrency.name+" at "+price.price.toString()+" for a profit of "+profit.toString());
		funds=revenue*reinvestmentPercentage;
		heldFunds+=revenue*(1-reinvestmentPercentage);
		ownedCurrency=0;

		print("Reinvesting "+sell(funds.toString())+" and keeping "+sell(heldFunds.toString()));

		importer.getMarketChart(this.days).then((data) => train(data));

    	return true;
  	}
}