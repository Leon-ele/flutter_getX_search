import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:ruijie_im/entity/contact_info.dart';
import 'package:ruijie_im/entity/group_info_entity.dart';
import 'package:ruijie_im/page/IM/database/user_info_datesource.dart';
import 'package:ruijie_im/ui/res/resources.dart';
import 'package:sqflite/sqflite.dart';

class DbManager {
  static const String dbName = 'UserInfoCache.db';
  static const String userTableName = 'users';
  static const String groupTableName = 'groups';
  static const String groupCacheTableName = 'groupCaches';
  static const String contactTableName = 'zy_contacts';
  static const String groupMemberTableName = 'zy_groupMember';

  final String dropTableUser = "DROP TABLE IF EXISTS $userTableName";
  final String createTableUser =
      "CREATE TABLE $userTableName(userId TEXT PRIMARY KEY, name TEXT, portraitUrl TEXT, companyName TEXT, userType INTEGER,positionName TEXT)";

  final String dropTableGroups = "DROP TABLE IF EXISTS $groupTableName";
  final String createTableGroups =
      "CREATE TABLE $groupTableName(groupId TEXT PRIMARY KEY, name TEXT, portraitUrl TEXT"
      ",companyName TEXT, groupType INTEGER, projectPhase TEXT,coScene TEXT,projectBudget TEXT,customerOrder INTEGER)";

  final String dropTableGroupCaches =
      "DROP TABLE IF EXISTS $groupCacheTableName";
  final String createTableGroupCaches =
      "CREATE TABLE $groupCacheTableName(groupId TEXT PRIMARY KEY, name TEXT, portraitUrl TEXT"
      ",companyName TEXT, groupType INTEGER, projectPhase TEXT,coScene TEXT,projectBudget TEXT,customerOrder INTEGER)";

  final String dropTableContacts = "DROP TABLE IF EXISTS $contactTableName";
  final String createTableContacts =
      "CREATE TABLE $contactTableName(userId TEXT PRIMARY KEY, name TEXT"
      ",portraitUrl TEXT, companyName TEXT, userType INTEGER,positionName TEXT) ";

  final String dropTableGroupMember =
      "DROP TABLE IF EXISTS $groupMemberTableName";
  final String createTableGroupMember =
      "CREATE TABLE $groupMemberTableName(groupId TEXT, groupName TEXT,groupType INTEGER"
      ",userId TEXT,userName TEXT,portraitUrl TEXT, companyName TEXT,role INTEGER,disableSendMsg INTEGER)";

  factory DbManager() => _getInstance();

  static DbManager get instance => _getInstance();
  static DbManager _instance;
  static Database database;
  static const NEW_DB_VERSION = 10; //升级后的版本号

  DbManager._internal() {
    // 初始化
    openDb();
    print('leon---version--$database.getVersion()');
  }

  static void clearAllUserInfo() async {
    getDatabasesPath().then((value) =>
        {debugPrint(value), deleteDatabase(value).then((value) => {})});
  }

  static DbManager _getInstance() {
    if (_instance == null) {
      _instance = new DbManager._internal();
    }
    return _instance;
  }

  Future<void> openDb() async {
    database = await openDatabase(join(await getDatabasesPath(), dbName),
        onCreate: _onCreate,
        version: NEW_DB_VERSION,
        onUpgrade: _updateDB,
        onDowngrade: _downDbVersion);
    int version = await database.getVersion();
    print('leon---version--$database.getVersion()');
  }

  Future<FutureOr<void>> _downDbVersion(
      Database db, int oldVersion, int newVersion) async {
    db.setVersion(3);
    print('leon---version--$database.getVersion()');
  }

//创建表，只回调一次
  Future<FutureOr<void>> _onCreate(Database db, int version) async {
    print("_onCreate newVersion:$version");
    var batch = db.batch();

    batch.execute(dropTableUser);
    batch.execute(createTableUser);

    batch.execute(dropTableGroups);
    batch.execute(createTableGroups);

    batch.execute(dropTableContacts);
    batch.execute(createTableContacts);

    batch.execute(dropTableGroupMember);
    batch.execute(createTableGroupMember);

    batch.execute(dropTableGroupCaches);
    batch.execute(createTableGroupCaches);

    await batch.commit();
  }

//数据库升级,只回调一次
  FutureOr<void> _updateDB(Database db, int oldVersion, int newVersion) async {
    print("_onUpgrade oldVersion:$oldVersion");
    print("_onUpgrade newVersion:$newVersion");
    await db.transaction((txn) async {
      var batch = txn.batch();

      batch.execute(dropTableUser);
      batch.execute(createTableUser);

      batch.execute(dropTableGroups);
      batch.execute(createTableGroups);

      batch.execute(dropTableContacts);
      batch.execute(createTableContacts);

      batch.execute(dropTableGroupMember);
      batch.execute(createTableGroupMember);

      batch.execute(dropTableGroupCaches);
      batch.execute(createTableGroupCaches);

      await batch.commit();
    });

    // var batch = db.batch();
    //
    // switch (oldVersion) {
    //   // 1 > 2 增加好友表
    //   case 1:
    //     {
    //       batch.execute(dropTableContacts);
    //       batch.execute(createTableContacts);
    //     }
    //     continue through;
    //   through:
    //   case 2:
    //     {
    //       batch.execute(updateTableGroup);
    //       await batch.commit();
    //     }
    //     // break;
    //     continue through3;
    //   through3:
    //   case 3:
    //     {
    //       batch.execute(dropTableGroupMember);
    //       batch.execute(createTableGroupMember);
    //     }
    //     break;
    //
    //   default:
    //     {
    //       await batch.commit();
    //     }
    // }
  }

// 用户信息
  Future<void> setUserInfo(UserInfo info) async {
    if (database == null) {
      print("重新打开");
      await openDb();
    }

    await database.transaction((txn) async {
      var batch = txn.batch();
      batch.insert(userTableName, info.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await batch.commit(noResult: true);
      // await txn.insert(userTableName, info.toMap(),
      // conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> clearUserInfoList() async {
    if (database == null) {
      print("重新打开");
      await openDb();
    }
    await database.transaction((txn) async {
      await txn.execute('DELETE FROM $userTableName');
    });
  }

  // 搜索联系人
  Future<List<UserInfo>> getUserInfoWithUserName(String userName) async {
    List<Map<String, dynamic>> maps = [];
    if (database == null) {
      await openDb();
    }

    if (userName != null && userName.isNotEmpty) {
      List<UserInfo> infoList = [];
      await database.transaction((txn) async {
        maps = await txn.query(contactTableName,
            where: 'name LIKE ?', whereArgs: ['%$userName%']);

        if (maps.length > 0) {
          infoList = List.generate(maps.length, (i) {
            return UserInfo.fromMap(maps[i]);
          });
        }
      });
      return infoList;
    } else {
      return null;
    }
  }

  Future<List<UserInfo>> getUserInfo({String userId}) async {
    List<Map<String, dynamic>> maps = List();
    if (database == null) {
      await openDb();
    }
    await database.transaction((txn)async{

      if (userId == null || userId.isEmpty) {
        maps = await txn.query(userTableName);
      } else {
        maps = await txn.query(userTableName, where: 'userId = ?', whereArgs: [userId]);
      }
    });

    List<UserInfo> infoList = List();
    if (maps.length > 0) {
      infoList = List.generate(maps.length, (i) {
        UserInfo info = UserInfo();
        info.id = maps[i]['userId'];
        info.name = maps[i]['name'];
        info.companyName = maps[i]['companyName'];
        info.portraitUrl = maps[i]['portraitUrl'];
        info.userType = maps[i]['userType'];
        return info;
      });
    }

    return infoList;
  }

// 群组信息

// 同步群组
  Future syncGroupList(List<GroupInfo> groups) async {
    if (database == null) {
      await openDb();
    }
    await database.delete(groupTableName);
    await database.transaction((txn) async {
      if (groups.length > 0 && groups != null) {
        var batch = txn.batch();
        groups.forEach((group) {
          batch.insert(groupTableName, group.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          // 此表只插入不删除
          batch.insert(groupCacheTableName, group.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
      }
    });
  }

// 同步群成员
  Future clearGroupMember() async {
    if (database == null) {
      await openDb();
    }
    await database.transaction((txn) async {
      await txn.execute('DELETE FROM $groupMemberTableName');
    });
  }

  Future syncGroupMember(GroupMemberInfo groupInfo) async {
    if (database == null) {
      await openDb();
    }
    if (groupInfo.userList.isNotEmpty) {
      // 群成员list
      groupInfo.userList.forEach((groupUserInfo) {
        groupUserInfo.groupId = groupInfo.groupId.toString();
        groupUserInfo.groupName = groupInfo.groupName;
        groupUserInfo.portraitUrl = groupInfo.portraitUrl;
        groupUserInfo.groupType = groupInfo.groupType;
      });

      await database.transaction((txn) async {
        ///批量往表中加数据
        var batch = txn.batch();
        groupInfo.userList.forEach((groupUserInfo) {
          batch.insert(groupMemberTableName, groupUserInfo.toDBMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit(noResult: true);
      });
    }
  }

  Future updateGroupMember(GroupMemberInfo groupInfo) async {
    if (database == null) {
      await openDb();
    }
    if (groupInfo.userList.isNotEmpty) {
      // 群成员list
      groupInfo.userList.forEach((groupUserInfo) {
        groupUserInfo.groupId = groupInfo.groupId.toString();
        groupUserInfo.groupName = groupInfo.groupName;
        groupUserInfo.portraitUrl = groupInfo.portraitUrl;
        groupUserInfo.groupType = groupInfo.groupType;
      });
      await database.transaction((txn) async {
        ///批量往表中加数据
        var batch = txn.batch();
        batch.delete(groupMemberTableName,
            where: 'groupId = ?', whereArgs: [groupInfo.groupId]);
        groupInfo.userList.forEach((groupUserInfo) {
          batch.insert(groupMemberTableName, groupUserInfo.toDBMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        });
        await batch.commit();
      });
    }
  }

  Future<List<GroupInfoUserList>> getGroupMemberInfo(String groupId,
      {String userId}) async {
    if (database == null) {
      await openDb();
    }

    List<Map<String, dynamic>> maps;
    if (userId != null && userId.isNotEmpty) {
      maps = await database.query(groupMemberTableName,
          where: 'userId = ? AND groupId = ?', whereArgs: [userId, groupId]);
    } else {
      maps = await database.query(groupMemberTableName,
          where: 'groupId = ?', whereArgs: [groupId]);
    }

    List<GroupInfoUserList> memberList = List();
    if (maps.length > 0) {
      memberList = List.generate(maps.length, (i) {
        return GroupInfoUserList.fromJsonMap(maps[i]);
      });
    }
    return memberList;
  }

  Future<void> setGroupInfo(GroupInfo info) async {
    if (database == null) {
      await openDb();
    }
    if (info != null && info.name.isNotEmpty) {
      await database.transaction((txn) async {
        await txn.insert(groupTableName, info.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await txn.insert(groupCacheTableName, info.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
  }

  Future<void> kickedGroupMember(String groupId, String memberId) async {
    if (database == null) {
      await openDb();
    }
    var batch = database.batch();
    batch.delete(groupMemberTableName,
        where: 'groupId = ? AND userId = ?', whereArgs: [groupId, memberId]);
    await batch.commit();
  }

  Future<void> updateGroupInfoWithGroupName(
      String groupId, String groupName) async {
    if (database == null) {
      await openDb();
    }
    if (groupId != null &&
        groupId.isNotEmpty &&
        groupName != null &&
        groupName.isNotEmpty) {
      var batch = database.batch();
      batch.update(groupTableName, {'name': groupName},
          where: 'groupId = ?', whereArgs: [groupId]);
      batch.update(groupCacheTableName, {'name': groupName},
          where: 'groupId = ?', whereArgs: [groupId]);
      await batch.commit();
    }
  }

  Future<List<GroupInfo>> getMyGroupList() async {
    List<Map<String, dynamic>> maps = List();
    if (database == null) {
      await openDb();
    }
    await database.transaction((txn) async {
      maps = await txn.query(groupTableName);
    });

    List<GroupInfo> infoList = List();
    if (maps.length > 0) {
      infoList = List.generate(maps.length, (i) {
        return GroupInfo.fromDBJson(maps[i]);
      });
    }
    return infoList;
  }

  Future<List<GroupInfo>> getGroupInfo({@required String groupId}) async {
    List<Map<String, dynamic>> maps = [];
    if (database == null) {
      await openDb();
    }
    maps = await database
        ?.query(groupTableName, where: 'groupId = ?', whereArgs: [groupId]);

    List<GroupInfo> infoList = [];
    if (maps.length > 0) {
      infoList = List.generate(maps.length, (i) {
        return GroupInfo.fromDBJson(maps[i]);
      });
    } else {
      // 我的群组里没有 去 群组cache 去取
      maps = await database?.query(groupCacheTableName,
          where: 'groupId = ?', whereArgs: [groupId]);
      if (maps.length > 0) {
        infoList = List.generate(maps.length, (i) {
          return GroupInfo.fromDBJson(maps[i]);
        });
      }
    }
    return infoList;
  }

  // 搜索群
  Future<List<GroupInfoUserList>> getGroupInfoWithGroupName(
      String userName) async {
    List<Map<String, dynamic>> maps = List();
    if (database == null) {
      await openDb();
    }
    if (userName == null || userName.isEmpty) {
      return null;
    }
    List<Map<String, dynamic>> users = await database?.query(
        groupMemberTableName,
        where: 'userName LIKE ?',
        whereArgs: ['%$userName%']);
    List<Map<String, dynamic>> groupNames = await database?.query(
        groupMemberTableName,
        distinct: true,
        where: 'groupName LIKE ?',
        whereArgs: ['%$userName%']);
    List<Map<String, dynamic>> groupNameSet = [];
    if (groupNames != null && groupNames.isNotEmpty) {
      // 去重
      Map<String, dynamic> tempMap = Map();
      groupNames.forEach((element) {
        if (tempMap['groupId'] != element['groupId']) {
          tempMap = element;
          groupNameSet.add(tempMap);
        }
      });
    }
    List<Map<String, dynamic>> tempMaps = List();
    tempMaps.addAll(users);
    tempMaps.addAll(groupNameSet);
    if (tempMaps != null && tempMaps.isNotEmpty) {
      // 去重
      List<String> groupIds = [];
      tempMaps.forEach((element) {
        if (!groupIds.contains(element['groupId'])) {
          groupIds.add(element['groupId']);
          maps.add(element);
        }
      });
    }
    List<GroupInfoUserList> infoList = List();
    if (maps.length > 0) {
      infoList = List.generate(maps.length, (i) {
        return GroupInfoUserList.fromJsonMap(maps[i]);
      });
    }

    return infoList;
  }

// 通讯录信息
  Future<void> clearContactList() async {
    if (database == null) {
      print("重新打开");
      await openDb();
    }

    await database.execute('DELETE FROM $contactTableName');
  }

  Future<void> syncAllContacts(List<ContactInfo> list) async {
    if (database == null) {
      print("重新打开");
      await openDb();
    }
    if (list.length > 0) {
      await database.transaction((txn) async {
        var batch = txn.batch();
        for (int i = 0; i < list.length; i++) {
          UserInfo info = UserInfo();
          info.id = list[i].userId.toString();
          info.name = list[i].userName ?? '';
          info.portraitUrl =
              list[i].portraitUrl ?? LocalDrawable.default_portrait;
          info.companyName = list[i].companyName;
          info.userType = list[i].userType;
          info.positionName = list[i].positionName;

          // batch
          UserInfoDataSource.setCacheUserInfo(info);
          batch.insert(userTableName, info.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          batch.insert(contactTableName, list[i].toMapDB(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      });
    }
  }

  Future<void> setContactInfo(ContactInfo info) async {
    if (database == null) {
      print("重新打开");
      await openDb();
    }
    await database.transaction((txn) async {
      await txn.insert(contactTableName, info.toMapDB(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<ContactInfo>> getContactInfo({String userId}) async {
    List<Map<String, dynamic>> maps = List();
    if (database == null) {
      await openDb();
    }
    if (userId == null || userId.isEmpty) {
      maps = await database?.query(contactTableName);
    } else {
      maps = await database
          ?.query(contactTableName, where: 'userId = ?', whereArgs: [userId]);
    }
    List<ContactInfo> infoList = List();
    if (maps.length > 0) {
      infoList = List.generate(maps.length, (i) {
        ContactInfo info = ContactInfo();
        info.userId = maps[i]['userId'];
        info.userName = maps[i]['name'];
        info.companyName = maps[i]['companyName'];
        info.portraitUrl = maps[i]['portraitUrl'];
        info.userType = maps[i]['userType'];
        return info;
      });
    }

    return infoList;
  }

  //清空数据
  Future<int> clear() async {
    print("清空数据库");
    var dbClient = await database;
    return await dbClient.delete(userTableName);
  }

  //关闭
  Future close() async {
    var dbClient = await database;
    print("关闭数据库");
    return dbClient.close();
  }
}
