import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'qarz_add.dart';
class QarzlarTab extends StatelessWidget{
  const QarzlarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Qarzlar'), Text('0 UZS')],
          ),
          const SizedBox(height: 8),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color:Colors.red[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.money_off,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Mening qarzlarim'), Text('0 UZS')],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(8),
              color: Colors.grey[400]!,
              dashPattern: const [10, 5],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QarzAdd()),
                    );
                  },
                  child: SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Center(child: Text('Qarz qo\'shish')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}