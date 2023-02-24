import 'package:flutter/material.dart';

class TimeTable extends StatefulWidget {
  final Map<String, dynamic>? sg;
  const TimeTable({Key? key, required this.sg}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  double defwid = 20;

  double defhet = 50;

  @override
  Widget build(BuildContext context) {
    print('line11:');
    print(widget.sg);
    return Column(
      children: [
        Row(
          children: const [
            Text(
              '시간표',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.transparent,
            border: Border.all(
              width: 1,
              color: const Color.fromRGBO(211, 211, 211, 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Table(
                // border: TableBorder.all(
                //   color: Color.fromRGBO(211, 211, 211, 1),
                //   borderRadius: BorderRadius.circular(10),
                // ),
                defaultColumnWidth: const FixedColumnWidth(50),
                columnWidths: const {
                  0: FixedColumnWidth(20),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: const [
                  TableRow(
                    children: [
                      Center(),
                      Center(
                        child: Text(
                          '월',
                          style: TextStyle(
                            color: Color.fromRGBO(158, 158, 158, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '화',
                          style: TextStyle(
                            color: Color.fromRGBO(158, 158, 158, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '수',
                          style: TextStyle(
                            color: Color.fromRGBO(158, 158, 158, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '목',
                          style: TextStyle(
                            color: Color.fromRGBO(158, 158, 158, 1),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                          child: Text(
                        '금',
                        style: TextStyle(
                          color: Color.fromRGBO(158, 158, 158, 1),
                          fontSize: 16,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '4',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '5',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '6',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: defwid,
                        height: defhet,
                        child: const Center(
                          child: Text(
                            '7',
                            style: TextStyle(
                              color: Color.fromRGBO(158, 158, 158, 1),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 250,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 7,
                      itemBuilder: (context, clindex) {
                        return SizedBox(
                          height: 50,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              int a = clindex + 1;
                              List? p = widget.sg?['${a.toString()}교시']
                                  .toString()
                                  .split(',');
                              if (index == 4 && clindex != 6) {
                                return Container(
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      left: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      right: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(p != null? p![index] : ""),
                                  ),
                                );
                              }
                              if (clindex == 6 && index != 4) {
                                return Container(
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      left: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      bottom: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(p != null? p![index] : ""),
                                  ),
                                );
                              }
                              if (index == 4 && clindex == 6) {
                                return Container(
                                  width: 50,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      left: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      right: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                      bottom: BorderSide(
                                        width: 1,
                                        color: const Color.fromRGBO(
                                            211, 211, 211, 1),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(p != null ? p![index] : ""),
                                  ),
                                );
                              }
                              return Container(
                                width: 50,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      width: 1,
                                      color: const Color.fromRGBO(
                                          211, 211, 211, 1),
                                    ),
                                    left: BorderSide(
                                      width: 1,
                                      color: const Color.fromRGBO(
                                          211, 211, 211, 1),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(p != null ? p![index] : ""),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
