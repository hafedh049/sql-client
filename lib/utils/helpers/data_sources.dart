import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../models/products_model.dart';

class RestorableProductSelections extends RestorableProperty<Set<int>> {
  Set<int> _productSelections = <int>{};

  bool isSelected(int index) => _productSelections.contains(index);

  @override
  Set<int> createDefaultValue() => _productSelections;

  @override
  Set<int> fromPrimitives(Object? data) {
    final selectedItemIndices = data as List<dynamic>;
    _productSelections = <int>{...selectedItemIndices.map<int>((dynamic id) => id as int)};
    return _productSelections;
  }

  @override
  void initWithValue(Set<int> value) {
    _productSelections = value;
  }

  @override
  Object toPrimitives() => _productSelections.toList();
}

class ProductDataSource extends DataTableSource {
  ProductDataSource.empty(this.context) {
    products = <Product>[];
  }

  ProductDataSource(this.context, this.products, [this.hasRowTaps = true, this.hasRowHeightOverrides = true, this.hasZebraStripes = true]);

  final BuildContext context;
  late List<Product> products;
  bool hasRowTaps = true;
  bool hasRowHeightOverrides = true;
  bool hasZebraStripes = true;

  @override
  DataRow2 getRow(int index, [Color? color]) {
    assert(index >= 0);
    if (index >= products.length) throw 'index > _products.length';
    final Product product = products[index];
    return DataRow2.byIndex(
      index: index,
      color: color != null ? MaterialStateProperty.all(color) : (hasZebraStripes && index.isEven ? MaterialStateProperty.all(Theme.of(context).highlightColor) : null),
      onTap: hasRowTaps ? () => _showSnackbar(context, 'Tapped on row') : null,
      cells: <DataCell>[
        for (final String item in product.columns) DataCell(Text(item)),
      ],
    );
  }

  @override
  int get rowCount => products.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => products.length;
}

_showSnackbar(BuildContext context, String text, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: color, duration: 1.seconds, content: Text(text)));
}
