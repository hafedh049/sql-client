import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final RestorableBool _sortAscending = RestorableBool(true);
  final RestorableIntN _sortColumnIndex = RestorableIntN(null);
  late ProductDataSource _productsDataSource;
  bool _initialized = false;
  final List<String> _columns = const <String>["Name", "Category", "Quantity", "Date", "Reference", "New Price"];
  final GlobalKey<State> _pagerKey = GlobalKey<State>();
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = <Product>[for (int index = 0; index < 100; index++) Product("P${index + 1}", "C${index + 1}", DateTime.now(), "Ref${index + 1}", 100, 150)];

  @override
  String get restorationId => 'paginated_product_table';
  late final Map<int, void Function()> _map;

  @override
  void initState() {
    _map = <int, void Function()>{
      0: () => _productsDataSource.sort<DateTime>((Product p) => p.date, _sortAscending.value),
      1: () => _productsDataSource.sort<String>((Product p) => p.reference, _sortAscending.value),
      2: () => _productsDataSource.sort<String>((Product p) => p.name, _sortAscending.value),
      3: () => _productsDataSource.sort<String>((Product p) => p.category, _sortAscending.value),
      4: () => _productsDataSource.sort<num>((Product p) => p.newPrice, _sortAscending.value),
      5: () => _productsDataSource.sort<num>((Product p) => p.quantity, _sortAscending.value),
    };
    super.initState();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_productSelections, 'selected_row_indices');
    registerForRestoration(_rowIndex, 'current_row_index');
    registerForRestoration(_rowsPerPage, 'rows_per_page');
    registerForRestoration(_sortAscending, 'sort_ascending');
    registerForRestoration(_sortColumnIndex, 'sort_column_index');

    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, _products, true, true, true, true);
      _initialized = true;
    }
    _map[_sortColumnIndex.value];
    _productsDataSource.updateSelectedProducts(_productSelections);
    _productsDataSource.addListener(_updateSelectedproductRowListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _productsDataSource = ProductDataSource(context, _products);
      _initialized = true;
    }
    _productsDataSource.addListener(_updateSelectedproductRowListener);
  }

  void _updateSelectedproductRowListener() {
    _productSelections.setProductSelections(_productsDataSource.products);
  }

  void sort<T>(Comparable<T> Function(Product p) getField, int columnIndex, bool ascending) {
    _productsDataSource.sort<T>(getField, ascending);
    _pagerKey.currentState!.setState(
      () {
        _sortColumnIndex.value = columnIndex;
        _sortAscending.value = ascending;
      },
    );
  }

  @override
  void dispose() {
    _rowsPerPage.dispose();
    _sortColumnIndex.dispose();
    _sortAscending.dispose();
    _productsDataSource.removeListener(_updateSelectedproductRowListener);
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Products", style: GoogleFonts.itim(fontSize: 22, fontWeight: FontWeight.w500, color: greyColor)),
                const SizedBox(height: 10),
                AnimatedButton(
                  width: 150,
                  height: 40,
                  text: 'UPDATE',
                  selectedTextColor: darkColor,
                  animatedOn: AnimatedOn.onHover,
                  animationDuration: 500.ms,
                  isReverse: true,
                  selectedBackgroundColor: greenColor,
                  backgroundColor: purpleColor,
                  transitionType: TransitionType.TOP_TO_BOTTOM,
                  textStyle: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: whiteColor),
                  onPress: () {
                    for (Product product in _productsDataSource.products) {
                      if (product.selected) {
                        product.quantity -= int.parse(product.cartController.text);
                        product.cartController.text = "0";
                        product.selected = false;
                      }
                    }
                    _productSelections.setProductSelections(_productsDataSource.products);
                    _productsDataSource.updateSelectedProducts(_productSelections);
                  },
                ),
              ],
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "Products", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: purpleColor)),
                  TextSpan(text: " / List Products", style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.w500, color: greyColor)),
                ],
              ),
            ),
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
                    sortColumnIndex: _sortColumnIndex.value,
                    sortAscending: _sortAscending.value,
                    columns: <DataColumn>[for (final String column in _columns) DataColumn(label: Text(column), onSort: (int columnIndex, bool ascending) => _map[columnIndex])],
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
