import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/products_model.dart';
import '../utils/helpers/data_sources.dart';
import '../utils/shared.dart';

class SQLTable extends StatefulWidget {
  const SQLTable({super.key});

  @override
  State<SQLTable> createState() => SQLTableState();
}

class SQLTableState extends State<SQLTable> with RestorationMixin {
  final RestorableProductSelections _productSelections = RestorableProductSelections();
  final RestorableInt _rowIndex = RestorableInt(0);
  final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage + 10);
  late ProductDataSource _productsDataSource;
  bool _initialized = false;
  final List<String> _columns = <String>[for (int index = 0; index < 10; index += 1) "C$index"];
  final GlobalKey<State> _pagerKey = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = <Product>[
    for (int index = 0; index < 100; index++) Product([for (int jndex = 0; jndex < 10; jndex += 1) "P$index$jndex"])
  ];

  @override
  String get restorationId => 'paginated_product_table';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_productSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');

    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, _products, true, true, true);
      _initialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, _products);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _productsDataSource.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text("Products", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: greyColor)),
            const Spacer(),
          ],
        ),
        Container(width: MediaQuery.sizeOf(context).width, height: .3, color: greyColor, margin: const EdgeInsets.symmetric(vertical: 20)),
        Expanded(
          child: ListView(
            restorationId: restorationId,
            children: <Widget>[
              StatefulBuilder(
                key: _pagerKey,
                builder: (BuildContext context, void Function(void Function()) _) {
                  return PaginatedDataTable(
                    showCheckboxColumn: false,
                    availableRowsPerPage: const <int>[20, 30],
                    arrowHeadColor: purpleColor,
                    rowsPerPage: _rowsPerPage.value,
                    onRowsPerPageChanged: (int? value) => _(() => _rowsPerPage.value = value!),
                    initialFirstRowIndex: _rowIndex.value,
                    onPageChanged: (int rowIndex) => _(() => _rowIndex.value = rowIndex),
                    columns: <DataColumn>[for (final String column in _columns) DataColumn(label: Text(column))],
                    source: _productsDataSource,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
