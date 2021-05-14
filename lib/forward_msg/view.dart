import 'package:flutter/material.dart';
import 'package:flutter_search_multiselect/forward_msg/widget/forward_chooseSend.dart';
import 'package:flutter_search_multiselect/forward_msg/widget/forward_function.dart';
import 'package:flutter_search_multiselect/forward_msg/widget/forward_recentCon.dart';
import 'package:flutter_search_multiselect/forward_msg/widget/forward_searchResult.dart';
import 'package:flutter_search_multiselect/forward_msg/widget/search_bar.dart';
import 'package:get/get.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';


import 'logic.dart';
import 'state.dart';

class ForwardMsgPage extends StatelessWidget {
  final Message forwardMsg;
  final ForwardMsgLogic logic = Get.put(ForwardMsgLogic());
  final ForwardMsgState state = Get.find<ForwardMsgLogic>().state;

  ForwardMsgPage({Key key, this.forwardMsg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return forwardBuildBg(context, backFunc: () {
      Get.delete<ForwardMsgLogic>();
      Navigator.pop(context);
    }, children: [
      ZYSearchWidget(
          hintText: '搜索',
          onSearch: logic.onSearch,
          onCancel: () => logic.onSearchCancle(),
          onClear: () => logic.onSearchClear(),
          onChanged: logic.onSearchValueChange
          // onEditingComplete: () =>logic.onSearchValueChange(''),
          ),

      buildUserAndGroupList(
        /// 滑动取消键盘
          gesturePanDownCallback: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          children: [
            /// 聊天列表
            Obx(() => Visibility(
                visible: state.searchQuery.value.isEmpty,
                child: ForwardMsgRecentCon(
                  data: state.conList,
                  itemClick: (value) => showAlert(context,
                      determine: () =>
                          logic.sendMsg(forwardMsg, value, context)),
                ))),

            /// 联系人 群组列表
            Obx(() => Visibility(
                visible: state.searchQuery.value.isNotEmpty,
                child: ForwardMsgSearchResult(
                  state: state,
                  userItemClick: (userInfo) => logic.userItemClick(userInfo),
                  groupItemClick: (groupInfo) => logic.groupItemClick(groupInfo),
                  // itemClick: (value) => showAlert(context,
                  //     determine: () => logic.sendMsg(forwardMsg, value, context)),
                ))),
          ]),

      /// 多选列表
      Obx(() => Visibility(
          visible: state.showSend.value,
          child: ForwardChooseResult(
            state: state,
            closeClick: (item)=>logic.closeBtnClick(item),
            confirmSendClick:()=> logic.confirmSendClick(forwardMsg,completeHandler: (){
              Get.delete<ForwardMsgLogic>();
              Navigator.pop(context);
            }),
          )))
    ]);
  }
}
