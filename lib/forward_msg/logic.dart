import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'state.dart';


class ForwardMsgLogic extends GetxController {
  final state = ForwardMsgState();
  int forwardTotalCount = 0;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();

    ///防DDos - 每当用户停止输入1秒时调用，例如。
    debounce(state.searchQuery, (value) => loadDataFormDB(value));
    updateConversationList();
  }

  updateConversationList() async {
    List list = await RongIMClient.getConversationList(
        [RCConversationType.Private, RCConversationType.Group]);
    state.conList.addAll(list);
    update(['conList']);
  }

  void recentConItemClick(Conversation conversation) {}
  void onSearch(msg) {
    loadDataFormDB(msg);
  }

  void onSearchCancle() {
    _clearSearchList();
  }

  void onSearchClear() {
    // _clearSearchList();
  }

  void onSearchValueChange(query) {
    state.searchQuery.value = query;
  }
  void _clearSearchList(){
    state.searchQuery.value = '';
    state.selectUserList.clear();
    state.selectGroupList.clear();
    state.selectTotalList.clear();
    _showSend();
  }
  void loadDataFormDB(query) async {
    print('query----rebuild');
    state.userList.clear();
    state.groupList.clear();
    List<userdb.UserInfo> userlist =
        await DbManager.instance.getUserInfoWithUserName(query);
    if (userlist != null && userlist.isNotEmpty) {
      List<SearchUserInfo> searchUserList = [];
      userlist.forEach((element) {
        SearchUserInfo searchUserInfo = SearchUserInfo.formUserInfo(element);
        // 根据已选择的是否包含 初始化可选状态
        state.selectUserList.forEach((element) {
          if (element.id == searchUserInfo.id) {
            searchUserInfo.checked.value = true;
          }
        });
        searchUserList.add(searchUserInfo);
      });
      state.userList.assignAll(searchUserList);
    }
    update(['userList']);

    List<GroupInfoUserList> grouplist =
        await DbManager.instance.getGroupInfoWithGroupName(query);
    if (grouplist != null && grouplist.isNotEmpty) {
      List<SearchGroupInfo> searchGroupList = [];
      grouplist.forEach((element) {
        SearchGroupInfo searchGroupInfo =
            SearchGroupInfo.formGroupInfo(element);
        // 根据已选择的是否包含 初始化可选状态
        state.selectGroupList.forEach((element) {
          if (element.id == searchGroupInfo.id) {
            searchGroupInfo.checked.value = true;
          }
        });
        searchGroupList.add(searchGroupInfo);
      });
      state.groupList.assignAll(searchGroupList);
    }
    update(['groupList']);
  }


  /// 联系人点击
  void userItemClick(SearchUserInfo item) {
    item.checked.value = !item.checked.value;
    if (item.checked.value) {
      bool exist = state.selectUserList.any((element) => element.id == item.id);
      if (!exist) {
        state.selectUserList.add(item);
        state.selectTotalList.add(item);
      }
    } else {
      state.selectUserList.removeWhere((element) => element.id == item.id);
      state.selectTotalList.removeWhere((element) => element.id == item.id);
    }
    print('leon----selectUserList---${state.selectUserList.length}');

    _showSend();
  }

  /// 群列表点击
  void groupItemClick(SearchGroupInfo item) {
    item.checked.value = !item.checked.value;
    if (item.checked.value) {
      bool exist =
          state.selectGroupList.any((element) => element.id == item.id);
      if (!exist) {
        state.selectGroupList.addIf(item.checked.value, item);
        state.selectTotalList.addIf(item.checked.value, item);
      }
    } else {
      state.selectGroupList.removeWhere((element) => element.id == item.id);
      state.selectTotalList.removeWhere((element) => element.id == item.id);
    }
    print('leon----selectGroupList---${state.selectGroupList.length}');
    _showSend();
  }

  void _showSend() {
    update(['chooseSend', 'totalCount']);
    state.showSend.value = state.selectTotalList.isNotEmpty;
  }

  void closeBtnClick(item) {
    state.selectTotalList.remove(item);
    update(['chooseSend', 'totalCount']);
    _showSend();

    if (item is SearchUserInfo) {
      state.selectUserList.removeWhere((element) => element.id == item.id);
      state.userList.forEach((element) {
        if (element.id == item.id) {
          element.checked.value = false;
        }
      });
    }

    if (item is SearchGroupInfo) {
      state.selectGroupList.removeWhere((element) => element.id == item.id);
      state.groupList.forEach((element) {
        if (element.id == item.id) {
          element.checked.value = false;
        }
      });
    }
  }

  /// 确定按钮 发送
  void confirmSendClick(Message forwardMsg,{VoidCallback completeHandler}) {
    EasyLoading.show(status: '转发中...');
    if (state.selectUserList.isNotEmpty) {
      forwardHandle(state.selectUserList,forwardMsg,RCConversationType.Private,completeHandler);
    }
    if (state.selectGroupList.isNotEmpty) {
      forwardHandle(state.selectGroupList,forwardMsg,RCConversationType.Group,completeHandler);
    }
  }

  void sendMsg(
      Message forwardMsg, Conversation conversation, BuildContext context) {
    try {
      RongClientUtil.sendMessage(conversation.conversationType,
          conversation.targetId, forwardMsg.content);
      EasyLoading.showToast('发送成功');
      Navigator.pop(context);
      Navigator.pop(context);
      EventBus.instance.commit(EventKeys.RefreshConversationList, null);
      Get.delete<ForwardMsgLogic>();
    } catch (e) {
      EasyLoading.showToast('发送失败');
      Navigator.pop(context);
      Navigator.pop(context);
      Get.delete<ForwardMsgLogic>();
    }
  }
  /// 系统相册转发
  void sendIntentMsg(List<SharedMediaFile> sharedFiles,Conversation conversation, BuildContext context){
    try {
      if (sharedFiles.isNotEmpty) {
        for (int i = 0;i < sharedFiles.length; i++) {
          EasyLoading.show(status: '转发中');
          Timer(Duration(milliseconds: 300), (){
            SharedMediaFile element = sharedFiles[i];
            if (element.type == SharedMediaType.IMAGE) {
              ImageMessage imgMessage = new ImageMessage();
              if (TargetPlatform.android == defaultTargetPlatform) {
                imgMessage.localPath = "file://" + element.path;
              } else {
                imgMessage.localPath = element.path;
              }
              RongClientUtil.sendMessage(conversation.conversationType,
                  conversation.targetId, imgMessage);
            }
            if (i== sharedFiles.length-1) {
              EasyLoading.dismiss();
              EasyLoading.showToast('发送成功');
              EventBus.instance.commit(EventKeys.RefreshConversationList, null);
              Get.delete<ForwardMsgLogic>();
              Navigator.pop(context);
              Navigator.pop(context);
            }
          });
        }
      }

    } catch (e) {
      EasyLoading.showToast('发送失败');
      // Get.delete<ForwardMsgLogic>();
      // Navigator.pop(context);
    }
  }
  /// 系统相册多选发送
  void intentConfirmSend(List<SharedMediaFile> sharedFiles,{VoidCallback completeHandler}){
    EasyLoading.show(status: '转发中...');

    if (state.selectUserList.isNotEmpty) {
      intentForwardHandle(state.selectUserList,sharedFiles,RCConversationType.Private,completeHandler);
    }
    if (state.selectGroupList.isNotEmpty) {
      intentForwardHandle(state.selectGroupList,sharedFiles,RCConversationType.Group,completeHandler);
    }
  }
  // void intentForwardHandle(List dataSource,List<SharedMediaFile> sharedFiles,int conversationType,VoidCallback completeHandler){
  //   int count = dataSource.length;
  //   for (int i = 0; i < dataSource.length; i++) {
  //       var info = dataSource[i];
  //       if (sharedFiles.isNotEmpty) {
  //
  //         for (int i = 0;i < sharedFiles.length; i++) {
  //           Timer(Duration(milliseconds: 300), (){
  //             forwardTotalCount++;
  //             SharedMediaFile element = sharedFiles[i];
  //             if (element.type == SharedMediaType.IMAGE) {
  //               ImageMessage imgMessage = new ImageMessage();
  //               if (TargetPlatform.android == defaultTargetPlatform) {
  //                 imgMessage.localPath = "file://" + element.path;
  //               } else {
  //                 imgMessage.localPath = element.path;
  //               }
  //               RongClientUtil.sendMessage(conversationType,
  //                   info.id, imgMessage);
  //             }
  //
  //             if (forwardTotalCount == state.selectTotalList.length) {
  //               EasyLoading.dismiss();
  //               EasyLoading.showToast('发送成功');
  //               EventBus.instance.commit(EventKeys.RefreshConversationList, null);
  //               completeHandler();
  //             }
  //
  //           });
  //         }
  //       }
  //       count--;
  //   };
  // }
  // void forwardHandle(List dataSource,Message forwardMsg,int conversationType,VoidCallback completeHandler) {
  //   int count = dataSource.length;
  //   for (int i = 0; i < dataSource.length; i++) {
  //     Timer(Duration(milliseconds: 300 * i), () {
  //      var info = dataSource[i];
  //       RongClientUtil.sendMessage(
  //           conversationType, info.id, forwardMsg.content);
  //       count--;
  //       if (count == 0) {
  //         EasyLoading.dismiss();
  //         EasyLoading.showToast('发送成功');
  //         EventBus.instance.commit(EventKeys.RefreshConversationList, null);
  //         completeHandler();
  //       }
  //     });
  //   };
  // }
}


class SearchUserInfo extends userdb.UserInfo {
  RxBool checked = false.obs;
  SearchUserInfo.formUserInfo(userdb.UserInfo userInfo) {
    this.companyName = userInfo.companyName;
    this.id = userInfo.id;
    this.name = userInfo.name;
  }
}

class SearchGroupInfo extends GroupInfoUserList {
  RxBool checked = false.obs;
  String id;
  SearchGroupInfo.formGroupInfo(GroupInfoUserList groupInfo) {
    this.userName = groupInfo.userName;
    this.id = groupInfo.groupId;
    this.groupName = groupInfo.groupName;
    this.portraitUrl = groupInfo.portraitUrl;
    this.groupType = groupInfo.groupType;
  }
}
