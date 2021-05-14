import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

typedef ForwardUserItemBuilder = Widget Function(UserInfo item);
typedef ForwardGroupItemBuilder = Widget Function(GroupInfoUserList item);
typedef ForwardChooseItemBuilder = Widget Function(dynamic item);
class ForwardMsgState {
  ///最近会话数据源
  List conList = [];
  /// 联系人列表
  List<SearchUserInfo> userList = [];
  /// 群列表
  List<SearchGroupInfo> groupList = [];
  /// 是否显示最近聊天
  // RxBool showRecentList = true.obs;
  /// 搜索内容
  RxString searchQuery = ''.obs;
  /// 选中的用户列表
  List selectUserList = [];
  /// 选中的群组列表
  List selectGroupList = [];
  /// 用户列表 + 群组列表
  List selectTotalList = [];
  /// 展示多选
  RxBool showSend = false.obs;
}

