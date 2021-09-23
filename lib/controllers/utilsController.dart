import 'package:get/get.dart';

class UtilsController extends GetxController {
  final _tabSelectedIndex = 0.obs;
  get tabSelectedIndex => this._tabSelectedIndex.value;
  set setTabIndex(index) => this._tabSelectedIndex.value = index;
}