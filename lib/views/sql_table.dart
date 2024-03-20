import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sql_client/views/auth/sign_in.dart';
import 'package:sql_client/views/settings.dart';
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
  final RestorableInt _rowsPerPage = RestorableInt(PaginatedDataTable.defaultRowsPerPage + 40);
  late ProductDataSource _productsDataSource;
  bool _initialized = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  String get restorationId => 'paginated_product_table';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_productSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');

    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, products, true, true, true);
      _initialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, products);
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
            Image.asset("assets/images/logo.png", scale: 6),
            const Spacer(),
            Tooltip(
              message: "Salida",
              child: IconButton(
                onPressed: () {
                  userData!.put("login", "");
                  userData!.put("pwd", "");
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const SignIn()));
                },
                icon: const Icon(FontAwesome.door_closed_solid, color: blueColor, size: 25),
              ),
            ),
            Tooltip(
              message: "Ajustes",
              child: IconButton(
                onPressed: () => showDialog(context: context, builder: (BuildContext context) => const AlertDialog(content: Settings())),
                icon: const Icon(FontAwesome.gears_solid, color: blueColor, size: 25),
              ),
            ),
          ],
        ),
        Container(width: MediaQuery.sizeOf(context).width, height: .3, color: darkColor, margin: const EdgeInsets.symmetric(vertical: 20)),
        Expanded(
          child: ListView(
            restorationId: restorationId,
            children: <Widget>[
              StatefulBuilder(
                key: pagerKey,
                builder: (BuildContext context, void Function(void Function()) _) {
                  _productsDataSource = ProductDataSource(context, products, true, true, true);
                  return PaginatedDataTable(
                    showCheckboxColumn: false,
                    availableRowsPerPage: const <int>[50, 100, 200, 500, 1000],
                    arrowHeadColor: blueColor,
                    rowsPerPage: _rowsPerPage.value,
                    onRowsPerPageChanged: (int? value) => _(() => _rowsPerPage.value = value!),
                    initialFirstRowIndex: _rowIndex.value,
                    onPageChanged: (int rowIndex) => _(() => _rowIndex.value = rowIndex),
                    columns: <DataColumn>[for (final String column in columns) DataColumn(label: Text(column))],
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
