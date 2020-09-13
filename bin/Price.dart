class Price {

	double price;
	DateTime time;

	Price(double price, int time) {
		this.price=price;
		this.time=DateTime.fromMicrosecondsSinceEpoch(time);
	}
}