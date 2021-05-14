import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
Widget forwardBuildBg(BuildContext context,{List<Widget> children,VoidCallback backFunc}){
   return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
              child: Container(
                  child: Text(
                    '关闭',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.normal),
                  )),
              onTap: backFunc
     ),
          Expanded(
            child: Center(
              child: Text(
                '选择一个聊天',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    ),
     body: _buildContentBg(
       children: children,
     ),
  );
}

 Widget buildUserAndGroupList({VoidCallback gesturePanDownCallback,List<Widget> children}){
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
          onPanDown: (_){
          gesturePanDownCallback();
},
        child: SingleChildScrollView(
          child: Column(
            children: children,
          ),
        ),
      ),
    );
 }
 Widget _buildContentBg({List<Widget> children}){
  return Column(
    children: children,
  );
 }

 showAlert(BuildContext context,{VoidCallback determine}) {
  showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            '确定发送？',
            style: TextStyle(
                fontSize: 17,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('取消',
                  style: TextStyle(
                      fontSize: 17.0,
                      color: Color(0xffe60039))),
            ),
            CupertinoDialogAction(
              onPressed: () => determine(),
              child: Text('确定',
                  style: TextStyle(
                      fontSize: 17.0,
                      color:Color(0xffe60039))),
            ),
          ],
        );
      });
}

