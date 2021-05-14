import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:get/get.dart';
import '../../function.dart';
import '../logic.dart';
import '../model.dart';
import '../state.dart';

class ForwardChooseResult extends StatelessWidget {
  final ForwardMsgState state;
  final ParamSingleCallback closeClick;
  final ParamVoidCallback confirmSendClick;
  const ForwardChooseResult({Key key, this.state, this.closeClick, this.confirmSendClick}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _buildBg(children: [
      /// 列表
      _buildList(builder: (item) {
        return _buildItemContent(item: item,children: [
          _buildItemName(item),
          _buildCloseImg(),
        ]);
      }),
      Container(width: 10),
      /// 确定按钮
      _buildConfirmBtn()
    ]);
  }

  Widget _buildBg({List<Widget> children}) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 5, right: 10),
      height: 60 + ScreenUtil().bottomBarHeight,
      color: Color(0xfff5f5f5),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildList({ForwardChooseItemBuilder builder}) {
    return Expanded(
      child: GetBuilder<ForwardMsgLogic>(
          id: 'chooseSend',
          builder: (controller) {
            return Scrollbar(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.state.selectTotalList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return builder(controller.state.selectTotalList[index]);
                  }),
            );
          }),
    );
  }

  Widget _buildItemContent({item,List<Widget> children}) {
    return InkWell(
      onTap: ()=>closeClick(item),
      child: Stack(
        children: children,
      ),
    );
  }

  Widget _buildItemName(item) {
    String name = '';
    if (item is SearchGroupInfo) {
      name = item.groupName;
    }else{
      name = item.name;
    }
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 15, top: 10, bottom: 15),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xfffce1e0),
          ),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: Color(0xffe60039),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseImg() {
    return Positioned(
      child: Image.asset('assets/images/search_friend_cancel.png'),
      right: 0.0,
      top: 2.0,
    );
  }

  Widget _buildConfirmBtn(){
    return InkWell(
      onTap: ()=>confirmSendClick(),
      child: Container(
        height: 30,
        width: 70,
        margin: EdgeInsets.only(top: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xffe60039),
        ),
        alignment: Alignment.center,
        child: GetBuilder<ForwardMsgLogic>(
          id: 'totalCount',
          builder: (controller){
            return Text(
              '确定(${controller.state.selectTotalList.length})',
              style: TextStyle(
                color: Color(0xffffffff),
                fontSize: 14,
              ),
            );
          },

        ),
      ),
    );
  }
}
