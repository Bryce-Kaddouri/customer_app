/*
import 'package:add_2_calendar/add_2_calendar.dart';
*/
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/helper/date_helper.dart';
import '../../data/model/order_model.dart';
import '../provider/order_provider.dart';
import '../widget/order_item_view_by_status_widget.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  final DateTime orderDate;

  const OrderDetailScreen({super.key, required this.orderId, required this.orderDate});

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
      appBar: material.AppBar(
        leading: material.BackButton(
          onPressed: () async {
            context.pop();
          },
        ),
        centerTitle: true,
        shadowColor: FluentTheme.of(context).shadowColor,
        surfaceTintColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        backgroundColor: FluentTheme.of(context).navigationPaneTheme.backgroundColor,
        elevation: 4,
        title: Text('Order #${orderId}'),
      ),
      body: FutureBuilder<OrderModel?>(
        future: context.read<OrderProvider>().getOrderDetail(orderId, orderDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: ProgressRing(),
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.hasData) {
            print(snapshot.data);
            OrderModel orderModel = snapshot.data!;
            print(orderModel.status.toJson());

            return Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                    padding: EdgeInsets.only(bottom: 50, left: 20, right: 20, top: 20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Card(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                      FluentIcons.event_date,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text('${DateHelper.getFormattedDateWithoutTime(orderModel!.date)}'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Card(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                      FluentIcons.clock,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text('${DateHelper.get24HourTime(orderModel!.time)}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Card(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                      FluentIcons.contact,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text('${orderModel!.customer.fName} ${orderModel!.customer.lName}'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Card(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    /* decoration: BoxDecoration(
                                    // rounded rectanmgle
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    color: FluentTheme.of(context).scaffoldBackgroundColor,
                                  ),*/
                                    child: Icon(
                                      FluentIcons.phone,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('${orderModel!.customer.countryCode}${orderModel!.customer.phoneNumber}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Card(
                                  padding: EdgeInsets.all(0),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Icon(
                                      FluentIcons.circle_dollar,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(text: '${orderModel.paidAmount}', style: TextStyle(fontWeight: FontWeight.bold, color: FluentTheme.of(context).typography.subtitle!.color)),
                                          TextSpan(text: ' / ', style: TextStyle(color: FluentTheme.of(context).typography.subtitle!.color)),
                                          TextSpan(text: '${orderModel.totalAmount}', style: TextStyle(color: FluentTheme.of(context).typography.subtitle!.color)),
                                        ])),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          height: 16,
                                          width: 16,
                                          decoration: BoxDecoration(
                                            // rounded rectanmgle
                                            shape: BoxShape.circle,
                                            color: orderModel.paidAmount == orderModel.totalAmount ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: /*Text(
                                          '(${orderModel.paidAmount == orderModel.totalAmount ? 'Paid' : 'Unpaid: ${orderModel.totalAmount - orderModel.paidAmount} left'})'),*/
                                          RichText(
                                              text: TextSpan(children: [
                                        TextSpan(
                                          text: '(${orderModel.paidAmount == orderModel.totalAmount ? 'Paid' : 'Unpaid: '}',
                                          style: TextStyle(color: FluentTheme.of(context).typography.subtitle!.color),
                                        ),
                                        if (orderModel.paidAmount != orderModel.totalAmount) TextSpan(text: '${orderModel.totalAmount - orderModel.paidAmount}', style: TextStyle(fontWeight: FontWeight.bold, color: FluentTheme.of(context).typography.subtitle!.color)),
                                        TextSpan(text: ' left)', style: TextStyle(color: FluentTheme.of(context).typography.subtitle!.color)),
                                      ])),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: StatusWidget(status: orderModel.status.name)),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Items', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        children: List.generate(orderModel.cart.length, (index) {
                          return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: Container(
                                  child: Image(
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox();
                                    },
                                    image: NetworkImage(orderModel!.cart[index].product.imageUrl),
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                title: Text('${orderModel!.cart[index].product.name}'),
                                subtitle: Text('${orderModel!.cart[index].product.price}'),
                                trailing: Text(orderModel!.cart[index].quantity.toString()),
                              ));
                        }),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.lighter,
                                  ),
                                  height: 40,
                                  width: 40,
                                  child: Icon(FluentIcons.check_mark, color: Colors.white, size: 24),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  child: StatusWidget(status: 'pending'),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 44,
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    child: Column(
                                      children: List.generate(
                                        orderModel.status.step > 1 ? 1 : 11,
                                        (index) => Container(
                                          alignment: Alignment.centerLeft,
                                          height: orderModel.status.step > 1 ? 44 : 4,
                                          width: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: orderModel.status.step > 1
                                                  ? Colors.green.lighter
                                                  : index.isEven
                                                      ? index < 6
                                                          ? Colors.green.lighter
                                                          : Colors.grey[30]
                                                      : Colors.transparent,
                                            ),
                                            height: 44,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('${DateHelper.getFormattedDate(orderModel.createdAt)} at ${DateHelper.get24HourTime(material.TimeOfDay(hour: orderModel.createdAt.hour, minute: orderModel.createdAt.minute))}'),
                                ],
                              ),
                            ),
                            if (orderModel.status.step >= 1)
                              Row(
                                children: [
                                  if (orderModel.status.step <= 1)
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[30],
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: Text("2", style: FluentTheme.of(context).typography.subtitle!.copyWith(color: Colors.grey[100])),
                                    )
                                  else
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.lighter,
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: Icon(FluentIcons.check_mark, color: Colors.white, size: 24),
                                    ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: StatusWidget(status: 'inProgress'),
                                  ),
                                ],
                              ),
                            if (orderModel.status.step > 1)
                              Container(
                                width: double.infinity,
                                height: 44,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      child: Column(
                                        children: List.generate(
                                          orderModel.status.step > 2 ? 1 : 11,
                                          (index) => Container(
                                            alignment: Alignment.centerLeft,
                                            height: orderModel.status.step > 2 ? 44 : 4,
                                            width: 2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: orderModel.status.step > 2
                                                    ? Colors.green.lighter
                                                    : index.isEven
                                                        ? index < 6
                                                            ? Colors.green.lighter
                                                            : Colors.grey[30]
                                                        : Colors.transparent,
                                              ),
                                              height: 44,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('${DateHelper.getFormattedDate(orderModel.createdAt)} at ${DateHelper.get24HourTime(material.TimeOfDay(hour: orderModel.createdAt.hour, minute: orderModel.createdAt.minute))}'),
                                  ],
                                ),
                              ),
                            if (orderModel.status.step >= 2)
                              Row(
                                children: [
                                  if (orderModel.status.step <= 2)
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[30],
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: Text("3", style: FluentTheme.of(context).typography.subtitle!.copyWith(color: Colors.grey[100])),
                                    )
                                  else
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.lighter,
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: Icon(FluentIcons.check_mark, color: Colors.white, size: 24),
                                    ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: StatusWidget(status: 'completed'),
                                  ),
                                ],
                              ),
                            if (orderModel.status.step >= 3)
                              Container(
                                width: double.infinity,
                                height: 44,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      child: Column(
                                        children: List.generate(
                                          orderModel.status.step > 3 ? 1 : 11,
                                          (index) => Container(
                                            alignment: Alignment.centerLeft,
                                            height: orderModel.status.step > 3 ? 44 : 4,
                                            width: 2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: orderModel.status.step > 3
                                                    ? Colors.green.lighter
                                                    : index.isEven
                                                        ? index < 6
                                                            ? Colors.green.lighter
                                                            : Colors.grey[30]
                                                        : Colors.transparent,
                                              ),
                                              height: 44,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('${DateHelper.getFormattedDate(orderModel.createdAt)} at ${DateHelper.get24HourTime(material.TimeOfDay(hour: orderModel.createdAt.hour, minute: orderModel.createdAt.minute))}'),
                                  ],
                                ),
                              ),
                            if (orderModel.status.step >= 3)
                              Row(
                                children: [
                                  if (orderModel.status.step < 4)
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[30]),
                                      height: 40,
                                      width: 40,
                                      child: Text("4", style: FluentTheme.of(context).typography.subtitle!.copyWith(color: Colors.grey[100])),
                                    )
                                  else
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.lighter,
                                      ),
                                      height: 40,
                                      width: 40,
                                      child: Icon(FluentIcons.check_mark, color: Colors.white, size: 24),
                                    ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: StatusWidget(status: 'collected'),
                                  ),
                                ],
                              ),
                            if (orderModel.status.step > 3)
                              Container(
                                padding: EdgeInsets.only(left: 19),
                                width: double.infinity,
                                height: 40,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 50,
                                        width: 2,
                                        child: Container(
                                          height: 50,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('${DateHelper.getFormattedDate(orderModel.collectedAt!)} at ${DateHelper.get24HourTime(material.TimeOfDay(hour: orderModel.collectedAt!.hour, minute: orderModel.collectedAt!.minute))}'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: Card(
                      padding: EdgeInsets.all(5),
                      child: FilledButton(
                        child: Text('Add To Calendar'),
                        onPressed: () async {
                          context.push(
                            '/reminder/add',
                            extra: {
                              'order_id': '${orderModel.id}',
                              'order_date': '${orderModel.date}',
                              'order_time': '${orderModel.time.hour}:${orderModel.time.minute}',
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text('No data found'),
            );
          }
        },
      ),
    );
  }
}
