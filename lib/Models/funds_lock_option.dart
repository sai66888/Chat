import 'package:flutter/cupertino.dart';

class FundsLockOption{
  /*
  * Our safe lock duration
  10 - 30 days (6%) p.a
  31 - 60 days (7%) p.a
  61 - 90 days (9%) p.a
  91 - 364 days (10%) p.a
  1 - 2 years (12.5%) p.a
  Over 2 years (26% - 36%) p.a
  * */
  String? description;
  int? fromDay;
  int? toDay;
  double? interestRate;
  FundsLockOption({this.description, this.fromDay, this.toDay, this.interestRate });
}