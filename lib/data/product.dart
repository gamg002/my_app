class Product {
  String? prouctName;
  String? price;
  String? priceTax;
  String? lite;

  Product({this.prouctName, this.price, this.priceTax, this.lite});

  Product.fromJson(Map<String, dynamic> json) {
    prouctName = json['ชื่อสินค้า'].toString();
    price = json['ราคาขายปลีกแนะนำ'].toString();
    priceTax = json['ภาษีตามปริมาณ'].toString();
    lite = json['จำนวนลิตร'].toString();
  }
}
