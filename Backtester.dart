import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

import 'Cryptocurrency.dart';
import 'Importer.dart';
import 'Price.dart';
import 'Trader.dart';

abstract class BacktestTrader extends Trader {

	List<Price> trainingData;
	List<Price> testingData;
	List<Price> data;

	double funds;

	BacktestTrader(Cryptocurrency cryptocurrency, double funds, double profitPercentage, double reinvestmentPercentage, [File backtestFile]) : super(cryptocurrency, funds, profitPercentage, reinvestmentPercentage) {

		if(backtestFile!=null) {
			BacktestImporter backtestImporter = BacktestImporter(backtestFile);
			this.data = backtestImporter.getData();
		}
		this.trainingData = this.data.sublist(0,(this.data.length/2).round());
		this.testingData = this.data.sublist((this.data.length/2).round());
	}

	void train(List<Price> data);

	void run();

	bool buy(Price price);
	
	bool sell(Price price);
}

class LevelUpBacktestTrader extends BacktestTrader {

	double average;
	Price buyPrice;
	double ownedCurrency;

	double heldFunds;

  	LevelUpBacktestTrader(Cryptocurrency cryptocurrency, double funds, double profitPercentage, double reinvestmentPercentage, File backtestFile, ) : super(cryptocurrency, funds, profitPercentage, reinvestmentPercentage, backtestFile) {
		this.average=0;
		this.heldFunds=0;
		train(this.trainingData);
		run();
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
	
	@override
  	void run() {
    	for (Price price in testingData) {
			print(price.price);	
			if(price.price<this.average&&!held) {
				held=buy(price);
				buyPrice=price;
		  	}
			if(held&&price.price>=buyPrice.price+(this.profitPercentage*buyPrice.price)) {
				sell(price);
				held=false;
			}
		}
		AnsiPen fundColour = AnsiPen()..white(bold: true)..green(bg: true);
		print("Ended Backtracking at total funds funds "+fundColour(heldFunds.toString())+" with invested funds: "+fundColour(funds.toString()));
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

		int start = this.data.indexWhere((element) => element.time.isAfter(price.time.subtract(Duration(days: 7))));

		train(this.data.sublist(start, this.data.indexOf(price)));

    	return true;
  	}

}
