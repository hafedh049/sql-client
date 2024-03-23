import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';
import 'package:sql_client/utils/callbacks.dart';
import 'package:sql_client/utils/shared.dart';

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
      cells: <DataCell>[
        for (final String item in product.columns)
          DataCell(
            onTap: () async {
              Clipboard.setData(ClipboardData(text: item));
              showToast(context, "Data has been copied to clipboard", greenColor);
            },
            Tooltip(message: item, child: Text(item)),
          ),
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
