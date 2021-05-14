import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../function.dart';
import '../logic.dart';
import 'forward_recentConItem.dart';

class ForwardMsgRecentCon extends StatelessWidget {
  final List data;

  final ParamSingleCallback itemClick;

  const ForwardMsgRecentCon({Key key, this.data, this.itemClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          /// 标题
          _buildTitle(),
          GetBuilder<ForwardMsgLogic>(
            id: 'conList',
              builder: (controller) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (controller.state.conList == null ||
                            controller.state.conList.isEmpty)
                        ? 0
                        : controller.state.conList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () =>
                            itemClick(controller.state.conList[index]),
                        child: ConversationForwardMessageItem(
                          conversation: controller.state.conList[index],
                        ),
                      );
                    });
          }),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Color(0xFFEEEEEE),
      height: 25,
      child: Padding(
        padding: const EdgeInsets.only(left: 18.5),
        child: Text(
          '最近聊天',
          style: TextStyle(color: Color(0xFF888787), fontSize: 14),
        ),
      ),
    );
  }
}
