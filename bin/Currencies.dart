enum Currency {
	CHF,
	USD,
}

String convertCurrencyToString(Currency currency) {
	switch (currency) {
	  case Currency.USD:
		return "USD";
		break;
	  default:
		return "CHF";
	}
}