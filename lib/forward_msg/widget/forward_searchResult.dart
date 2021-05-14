import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:get/get.dart';


import '../../function.dart';
import '../logic.dart';
import '../state.dart';

// ignore: must_be_immutable
class ForwardMsgSearchResult extends StatelessWidget {
  final ForwardMsgState state;
  final ParamSingleCallback userItemClick;
  final ParamSingleCallback groupItemClick;

  TextStyle _normalUserNameStyle = TextStyle(color: Colors.black, fontSize: 15);
  TextStyle _highlightUserNameStyle =
      TextStyle(color: Color(0xFF2982E5), fontSize: 15);

  ForwardMsgSearchResult({Key key, this.state, this.userItemClick, this.groupItemClick}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('ForwardMsgSearchResult---rebuild');
    return _buildBg(children: [
      /// 联系人
      _searchUserResult(itemBuilder: (item) {
        return _buildUserItemBg([
          /// 内容
          _buildItemContent(children: [
            /// 复选框
            _buildUserListCheckBox(item),
            /// 头像
            WidgetUtil.buildUserPortraitWithParm(item.portraitUrl,item.name),
            /// 用户名字
            _buildUserItemName(item),
            /// 公司名
            _buildUserCompanyName(item)
          ]),

          /// 下划线
          _buildBottomLine()
        ],item: item);
      }),

      /// 分隔符
      _buildSeparator(),

      /// 群组结果
      _buildSearchGroupBg(children: [
        /// 群组标题
        _buildGroupTitle(),
        /// 群组item
        _buildGroupList(itemBuilder: (item){
          return _buildGroupItemBg(
              groupInfo: item,
              children: [
            /// 群组内容
              _buildGroupContent(children: [
              /// 复选框
                _buildGroupListCheckBox(item),
              /// 群头像
                _buildGroupItemPortrait(item),
                _buildGroupNameAndUserName(children: [
                /// 群名称
                _buildGroupItemGroupName(item),
                /// 包含的群成员
                _buildGroupMember(item)
              ])
            ]),
            /// 下划线
            _buildBottomLine()
          ]);
        })

      ]),
    ]);
  }

  Widget _buildUserItemBg(List<Widget> children,{UserInfo item}) {
    return InkWell(
      onTap: ()=>userItemClick(item),
      child: Container(
        height: 60,
        color: Colors.white,
        width: ScreenUtil().screenWidth,
        padding: EdgeInsets.only(left: 20),
        child: Column(
          children: children,
        ),
      ),
    );
  }
  Widget _buildGroupItemBg({SearchGroupInfo groupInfo,List<Widget> children}) {
    return InkWell(
      onTap: ()=>groupItemClick(groupInfo),
      child: Container(
        height: 76,
        color: Colors.white,
        width: ScreenUtil().screenWidth,
        padding: EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
  Widget _buildGroupContent({List<Widget> children}){
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
  Widget _buildBg({List<Widget> children}) {
    return Column(
      children: children,
    );
  }

  Widget _buildSeparator() {
    return Container(height: 12, color: ColorManager.pageBGColor);
  }

  Widget _buildItemContent({List<Widget> children}) {
    return Expanded(
      child: Row(
        children: children,
      ),
    );
  }
  /// 用户列表可选框
  Widget _buildUserListCheckBox(SearchUserInfo userInfo){
    return Padding(
      padding: const EdgeInsets.only(right: 17),
      child: Obx(()=>Image.asset(
        userInfo.checked.value?'assets/images/contact_info_selected.png':'assets/images/contact_info_unselected.png',height: 24,width: 24,fit:BoxFit.fill ,)),
    );
  }
  Widget _buildGroupListCheckBox(SearchGroupInfo userInfo){
    return Padding(
      padding: const EdgeInsets.only(right: 17),
      child: Obx(()=>Image.asset(
        userInfo.checked.value?'assets/images/contact_info_selected.png':'assets/images/contact_info_unselected.png',height: 24,width: 24,fit:BoxFit.fill ,)),
    );
  }
  Widget _buildUserItemName(UserInfo item){
    return Padding(
        padding: EdgeInsets.only(left: 15, right: 7),
        child: _splitUserNameRichText(item.name));
  }
  Widget _buildUserCompanyName(UserInfo user){
    return Text(
      (user.companyName == null || user.companyName.isEmpty)
          ? ''
          : '@' + user.companyName,
      style: TextStyle(
          color: ColorManager.remarksBtnStokeColor,
          fontSize: fontManager.iconTitleFont),
    );
  }
  Widget _buildBottomLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 55),
      child: Container(
        height: 0.5,
        color: ColorManager.lineColor,
      ),
    );
  }

  ///联系人搜索结果
  Widget _searchUserResult({ForwardUserItemBuilder itemBuilder}) {
    return GetBuilder<ForwardMsgLogic>(
        id: 'userList',
        builder: (controller) {
      return controller.state.userList.length > 0
          ? ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.state.userList.length,
              itemBuilder: (context, index) => itemBuilder(controller.state.userList[index])
      )
          : Container();
    });
  }
  /// 搜索群组结果
  Widget _buildGroupList({ForwardGroupItemBuilder itemBuilder}){
    return GetBuilder<ForwardMsgLogic>(
        id: 'groupList',
        builder: (controller) {
      return controller.state.groupList.length > 0
          ? ListView.builder(
          // padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.state.groupList.length,
          itemBuilder: (context, index) => itemBuilder(controller.state.groupList[index]))
          : Container();
    });
}
  Widget _buildSearchGroupBg({List<Widget> children}) {
    return Column(
      children: children,
    );
  }

  Widget _buildGroupTitle() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 21,top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '群组',
            style: TextStyle(
                color: ColorManager.graySmallColor,
                fontSize: fontManager.btnTextFont),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            color: ColorManager.lineColor,
            height: 0.5,
          ),
        ],
      ),
    );
  }
  Widget _buildGroupItemPortrait(GroupInfoUserList group){
    return  WidgetUtil.buildGroupPortraitIcon(group.groupType);
  }
  Widget _buildGroupNameAndUserName({List<Widget> children}){
    return Container(
      padding: EdgeInsets.only(left: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }
  Widget _buildGroupItemGroupName(GroupInfoUserList group){
    return Container(
        padding: group.userName.contains(state.searchQuery)
            ? const EdgeInsets.only(top: 15, bottom: 12)
            : const EdgeInsets.only(top: 25),
        child: _splitUserNameRichText(group.groupName));
  }
  Widget _buildGroupMember(GroupInfoUserList group){
    return Visibility(
      visible: group.userName.contains(state.searchQuery),
        child: Container(width: 200, child: _splitGroupMemberRichText(group.userName)));
  }
  Widget _splitUserNameRichText(String userName) {
    print(userName);
    List<TextSpan> spans = [];
    List<String> strs = userName?.split(state.searchQuery.value)??[];
    for (int i = 0; i < strs.length; i++) {
      if ((i % 2) == 1) {
        spans.add(TextSpan(
            text: state.searchQuery.value, style: _highlightUserNameStyle));
      }
      String val = strs[i];
      if (val != '' && val.length > 0) {
        spans.add(TextSpan(text: val, style: _normalUserNameStyle));
      }
    }
    return RichText(text: TextSpan(children: spans));
  }

  Widget _splitGroupMemberRichText(String memberName) {
    List<TextSpan> spans = [];
    List<String> strs = memberName.split(state.searchQuery.value);
    for (int i = 0; i < strs.length; i++) {
      if ((i % 2) == 1) {
        spans.add(TextSpan(
            text: state.searchQuery.value, style: _highlightUserNameStyle));
      }
      String val = strs[i];
      if (val != '' && val.length > 0) {
        spans.add(TextSpan(text: val, style: _normalUserNameStyle));
      }
    }
      return RichText(
          maxLines: 1,
          overflow: TextOverflow.clip,
          text: TextSpan(
              children: spans,
              text: '包含：',
              style: TextStyle(color: Color(0xFF868889), fontSize: 13)));

  }
}
