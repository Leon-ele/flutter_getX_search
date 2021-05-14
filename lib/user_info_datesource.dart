import 'package:flutter/cupertino.dart';


enum group_type {
  groupType_normal, // 普通群
  groupType_together, // 共建群
  groupType_work, // 服务商
  groupType_customer // 客户内部群
}

class BaseInfo {
  String id;
  String name;
  String portraitUrl;
  BaseInfo() {}

  BaseInfo.createItem(String userName, String path)
      : name = userName,
        portraitUrl = path;
}

class UserInfo extends BaseInfo {
  String companyName;
  int userType;
  String positionName;
  UserInfo() {}
  //开发者可以按需自行增加字段
  Map<String, dynamic> toMap() {
    return {
      'userId': id,
      'name': name,
      'portraitUrl': portraitUrl,
      'companyName': companyName,
      'userType': userType,
      'positionName': positionName
    };
  }

  UserInfo.fromMap(Map<String, dynamic> map) {
    this.id = map['userId'];
    this.name = map['name'];
    this.portraitUrl = map['portraitUrl'];
    this.companyName = map['companyName'];
    this.userType = map['userType'];
    this.positionName = map['positionName'];
  }
}

class GroupInfo extends BaseInfo {
  int groupType;
  String projectPhase; // 项目阶段
  String coScene; //共建场景
  String projectBudget; // 项目预算
  bool isChecked = false;
  // 客户排序
  int customerOrder;
  //开发者可以按需自行增加字段
  Map<String, dynamic> toMap() {
    return {
      'groupId': id,
      'name': name,
      'portraitUrl': portraitUrl,
      'groupType': groupType,
      'projectPhase': projectPhase,
      'coScene': coScene,
      'projectBudget': projectBudget,
      'customerOrder': customerOrder,
    };
  }

  GroupInfo() {}
  GroupInfo.fromJsonMap(Map<String, dynamic> json) {
    this.id = json['groupId'].toString() ?? '';
    this.name = json['groupName'] ?? '';
    this.groupType = json['groupType'] ?? 0;
    this.portraitUrl = json['portraitUrl'] ?? '';
    this.projectPhase = json['projectPhase'] ?? '';
    this.coScene = json['coScene'] ?? '';
    this.projectBudget = json['projectBudget'] ?? '';
    this.customerOrder = json['customerOrder'];
  }
  GroupInfo.fromDBJson(Map<String, dynamic> json) {
    this.id = json['groupId'].toString() ?? '';
    this.name = json['name'] ?? '';
    this.groupType = json['groupType'] ?? 0;
    this.portraitUrl = json['portraitUrl'] ?? '';
    this.projectPhase = json['projectPhase'] ?? '';
    this.coScene = json['coScene'] ?? '';
    this.projectBudget = json['projectBudget'] ?? '';
    this.customerOrder = json['customerOrder'];
  }
}

class UserInfoDataSource {
  static Map<String, UserInfo> cachedUserMap = new Map(); //保证同一 userId
  static Map<String, GroupInfo> cachedGroupMap = new Map(); //保证同一 groupId
  static UserInfoCacheListener cacheListener;
  // static User currentUserInfo; // 当前用户
  // 用来刷新用户信息，当有用户信息更新的时候
  static void setCacheUserInfo(UserInfo info) {
    if (info == null) {
      return;
    }
    cachedUserMap[info.id] = info;
  }

  // 用来刷新用户信息，当有用户信息更新的时候
  static void setUserInfo(UserInfo info) {
    if (info == null) {
      return;
    }
    cachedUserMap[info.id] = info;
    DbManager.instance.setUserInfo(info);
  }

  ///同步所有联系人
  static Future<void> syncContacts() async {
    // 解决切换账号后读取上一个账号的通讯录
    await DbManager.instance.clearContactList();
    List<ContactInfo> list = await ApiService.getContacts();
    DbManager.instance.syncAllContacts(list);
  }

  static void refreshUserInfoFromContact(List<ContactInfo> list) {
    list.forEach((element) async {
      var userInfo = await getUserInfo("${element.userId}");
      if (userInfo == null) {
        userInfo = UserInfo();
      }
      userInfo.id = "${element.userId}";
      userInfo.name = element.userName;
      userInfo.portraitUrl = element.portraitUrl;
      userInfo.companyName = element.companyName;
      userInfo.userType = element.userType;
      UserInfoDataSource.setUserInfo(userInfo);
    });
  }

// 获取用户信息
  static Future<UserInfo> getUserInfo(String userId) async {
    UserInfo cachedUserInfo = cachedUserMap[userId];
    if (cachedUserInfo != null) {
      return cachedUserInfo;
    } else {
      UserInfo info;
      List<UserInfo> infoList =
          await DbManager.instance.getUserInfo(userId: userId);
      if (infoList != null && infoList.length > 0) {
        info = infoList[0];
      }
      if (info == null) {
        if (cacheListener != null) {
          info = await cacheListener.getUserInfo(userId);
        }
        if (info != null) {
          DbManager.instance.setUserInfo(info);
        }
      }
      if (info != null) {
        cachedUserMap[info.id] = info;
      }

      if (info == null) {
        info = UserInfo();
      }
      return info;
    }
  }

//获取所有好友信息
  static Future<List<ContactInfo>> getContactsList() async {
    List<ContactInfo> list = [];
    if (cachedUserMap == null || cachedUserMap.isEmpty) {
      var list2 = await DbManager.instance.getUserInfo();
      list2.forEach((value) async {
        ContactInfo contactInfo = ContactInfo();
        UserInfo info = value;
        if (info == null) {
          if (cacheListener != null) {
            info = await cacheListener.getUserInfo(info.id);
          }
          if (info != null) {
            DbManager.instance.setUserInfo(info);
          }
        }
        if (info != null) {
          cachedUserMap[info.id] = info;
        }

        if (info == null) {
          info = UserInfo();
        }
        contactInfo.userName = value.name;
        contactInfo.userId = value.id;
        contactInfo.portraitUrl = value.portraitUrl;
        contactInfo.companyName = value.companyName;
        contactInfo.userType = value.userType;
        list.add(contactInfo);
      });
    } else {
      cachedUserMap.forEach((key, value) {
        ContactInfo contactInfo = ContactInfo();
        contactInfo.userName = value.name;
        contactInfo.userId = value.id;
        contactInfo.portraitUrl = value.portraitUrl;
        contactInfo.companyName = value.companyName;
        contactInfo.userType = value.userType;
        list.add(contactInfo);
      });
    }
    return list;
  }

  static Future<UserInfo> generateUserInfo(String userId) async {
    User user = await ApiService.getUserInfoById(userId);
    if (user != null) {
      return UserInfo()
        ..companyName = user.companyName
        ..id = user.userId
        ..name = user.userName
        ..portraitUrl = user.avatar
        ..userType = user.userType
        ..positionName = user.positionName;
    } else {
      return null;
    }
  }

// **************************** 群相关 *****************************

  static Future<GroupInfo> generateGroupInfo(String groupId) async {
    var group = await ApiService.getGroupInfo(groupId);
    if (group != null) {
      return GroupInfo()
        ..name = group.groupName
        ..id = group.groupId?.toString()
        ..groupType = group.groupType
        ..portraitUrl = group.portraitUrl;
    } else {
      return null;
    }
  }

  static syncGroupList() async {
    try {
      List<GroupInfo> groups = await ApiService.getGroupList();
      await DbManager.instance.syncGroupList(groups);
    } catch (e) {}
  }

  static syncGroupMember() async {
    DbManager.instance.clearGroupMember();
    List<GroupMemberInfo> groups = await ApiService.getGroupAllMember();
    if (groups != null) {
      if (groups.isNotEmpty) {
        groups.forEach((element) {
          DbManager.instance.syncGroupMember(element);
        });
      }
    }
  }

  static Future<GroupInfoUserList> getGroupMember(
      String userId, String groupId) async {
    List<GroupInfoUserList> members =
        await DbManager.instance.getGroupMemberInfo(groupId, userId: userId);
    if (members.length > 0) {
      return members.first;
    } else {
      GroupInfoEntity groupInfo = await ApiService.getGroupInfo(groupId);
      if (groupInfo != null) {
        if (groupInfo.userList.isNotEmpty) {
          GroupInfoUserList memberInfo;
          for (GroupInfoUserList userInfo in groupInfo.userList) {
            if (userInfo.userId == userId) {
              memberInfo = userInfo;
              break;
            }
          }
          return memberInfo;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  static void setGroupInfo(GroupInfo info) {
    if (info != null && info.name.isNotEmpty) {
      cachedGroupMap[info.id] = info;
      DbManager.instance.setGroupInfo(info);
    }
  }

  static void updateGroupInfoWithGroupName(
      String groupId, String groupName) async {
    if (groupId != null &&
        groupId.isNotEmpty &&
        groupName != null &&
        groupName.isNotEmpty) {
      GroupInfo info = cachedGroupMap[groupId];
      info.name = groupName;
      cachedGroupMap[groupId] = info;
      await DbManager.instance.updateGroupInfoWithGroupName(groupId, groupName);
    }
  }

  static Future<void> addGroupMember(String targetId) async {
    GroupInfoEntity _groupInfo = await ApiService.getGroupInfo(targetId);
    if (_groupInfo != null) {
      GroupMemberInfo memberInfo =
          GroupMemberInfo.fromJson(_groupInfo.toJson());
      DbManager.instance.updateGroupMember(memberInfo);
    }
  }

  static Future<void> KickedGroupMember(String groupId, String memberId) async {
    if (groupId != null &&
        groupId.isNotEmpty &&
        memberId != null &&
        memberId.isNotEmpty) {
      await DbManager.instance.kickedGroupMember(groupId, memberId);
    }
  }

// 群组信息
  //是否在群组中
  static Future<bool> isInGroup(String groupId) async {
    var group = await ApiService.getGroupInfo(groupId);
    return group == null ? false : true;
  }

  static Future<GroupInfo> getGroupInfo(String groupId) async {
    GroupInfo cachedGroupInfo = cachedGroupMap[groupId];
    if (cachedGroupInfo != null) {
      return cachedGroupInfo;
    } else {
      GroupInfo info;
      List<GroupInfo> infoList =
          await DbManager.instance.getGroupInfo(groupId: groupId);
      if (infoList != null && infoList.length > 0) {
        info = infoList[0];
      }
      if (info == null) {
        if (cacheListener != null) {
          info = await cacheListener.getGroupInfo(groupId);
        }
        if (info != null && info.name.isNotEmpty) {
          DbManager.instance.setGroupInfo(info);
        }
      }
      if (info != null) {
        cachedGroupMap[info.id] = info;
      }

      if (info == null) {
        info = GroupInfo();
      }
      return info;
    }
  }

  static void setCacheListener(UserInfoCacheListener listener) {
    cacheListener = listener;
  }
}

class UserInfoCacheListener {
  Future<UserInfo> Function(String userId) getUserInfo;
  Future<GroupInfo> Function(String groupId) getGroupInfo;
  void Function(UserInfo info) onUserInfoUpdated;
}
