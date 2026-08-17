class MedicineModel {
  final int id;
  final String brandName;
  final String? brandNameBn;
  final String genericName;
  final String? genericNameBn;
  final String? manufacturer;
  final String? dosageForm;
  final String? strength;
  final double? unitPrice;
  final String? category;
  final String? indications;
  final String? indicationsBn;
  final String? composition;
  final String? compositionBn;
  final String? sideEffects;
  final String? instructions;

  MedicineModel({
    required this.id,
    required this.brandName,
    this.brandNameBn,
    required this.genericName,
    this.genericNameBn,
    this.manufacturer,
    this.dosageForm,
    this.strength,
    this.unitPrice,
    this.category,
    this.indications,
    this.indicationsBn,
    this.composition,
    this.compositionBn,
    this.sideEffects,
    this.instructions,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? 0,
      brandName: json['brand_name'] ?? '',
      brandNameBn: json['brand_name_bn'],
      genericName: json['generic_name'] ?? '',
      genericNameBn: json['generic_name_bn'],
      manufacturer: json['manufacturer'],
      dosageForm: json['dosage_form'],
      strength: json['strength'],
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,
      category: json['category'],
      indications: json['indications'],
      indicationsBn: json['indications_bn'],
      composition: json['composition'],
      compositionBn: json['composition_bn'],
      sideEffects: json['side_effects'],
      instructions: json['instructions'],
    );
  }
}
