import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import '../model.dart';

class ConversationForwardMessageItem extends StatefulWidget {
  final Conversation conversation;

  const ConversationForwardMessageItem({Key key, this.conversation})
      : super(key: key);

  @override
  _ConversationForwardMessageItemState createState() =>
      _ConversationForwardMessageItemState(this.conversation);
}

class _ConversationForwardMessageItemState
    extends State<ConversationForwardMessageItem> {
  final Conversation conversation;
  BaseInfo info;

  _ConversationForwardMessageItemState(this.conversation);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInfo();
  }

  setInfo() async {
    String targetId = conversation.targetId;
    if (conversation.conversationType == RCConversationType.Private) {
      setState(() {});
    } else {
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return _buildItem();
  }
  @override
  Widget _buildItem(){
    return Container(
      color: Colors.white,
      width: ScreenUtil().screenWidth,
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildContent(conversation),
          _buildBottomLine(),
        ],
      ),
    );
  }

  Widget _buildContent(Conversation item){
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 17.0),
        child: Row(
          children: [
            Image.asset('name'),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                info?.name ?? '',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLine(){
    return Padding(
      padding: const EdgeInsets.only(left: 17.0),
      child: Container(
        color: Color(0xffe6e6e6),
        height: 0.5,
      ),
    );
  }
}