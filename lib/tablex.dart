import 'package:flutter/material.dart';

class TTableX extends StatelessWidget {
  final Map<String, dynamic>? sg;
  TTableX({
    Key? key,
    required this.sg,
  }) : super(key: key);

  double defwid = 50;

  double defhet = 50;

  double weekhet = 20;

  TableRow buildRow(int nclass, Map<String, dynamic>? sg) {
    if (sg != null) {
      // && sg['1교시'] != null
      List<String> nclassdata =
          sg['${nclass.toString()}교시'].toString().split(',');
      return TableRow(
          children: nclassdata.map((cell) {
        return SizedBox(
          height: defhet,
          child: Center(child: Text(cell)),
        );
      }).toList());
    } else {
      List dummyRow = [1, 2, 3, 4, 5];
      return TableRow(
        children: dummyRow
            .map(
              (e) => SizedBox(
                width: defwid,
                height: defhet,
                child: const Center(child: Text('로딩중...')),
              ),
            )
            .toList(),
      );
    }
  }

  Table buildWeek() {
    List<String> Week = ['월', '화', '수', '목', '금'];
    return Table(
      defaultColumnWidth: FixedColumnWidth(defwid),
      children: [
        TableRow(
          children: Week.map((cell) {
            return SizedBox(
              height: weekhet,
              child: Center(child: Text(cell)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Column buildClassNum() => Column(
        children: ['1', '2', '3', '4', '5', '6', '7'].map((cell) {
          return SizedBox(
            width: weekhet,
            height: defhet,
            child: Center(child:Text(cell)),
          );
        }).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return sg?['1교시'] != null
        ? Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildClassNum(),
                Column(
                  children: [
                    buildWeek(),
                    Table(
                      defaultColumnWidth: FixedColumnWidth(defwid),
                      border: TableBorder.all(
                        color: const Color.fromRGBO(211, 211, 211, 1),
                      ),
                      children: [
                        buildRow(1, sg),
                        buildRow(2, sg),
                        buildRow(3, sg),
                        buildRow(4, sg),
                        buildRow(5, sg),
                        buildRow(6, sg),
                        buildRow(7, sg),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        : CircularProgressIndicator();
  }
}
