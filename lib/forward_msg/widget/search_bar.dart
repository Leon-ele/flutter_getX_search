import 'package:flutter/material.dart';

class ZYSearchWidget extends StatefulWidget implements PreferredSizeWidget {
  ZYSearchWidget(
      {Key key,
        this.autoFocus = false,
        this.focusNode,
        this.controller,
        this.value,
        this.leading,
        this.suffix,
        this.actions = const [],
        this.hintText,
        this.onTap,
        this.onClear,
        this.onCancel,
        this.onChanged,
        this.onSearch,
        this.backgroundColor = Colors.white,
        this.textFieldColor = const Color(0xFFF6F6F6), this.onEditingComplete})
      : super(key: key);
  final bool autoFocus;
  final FocusNode focusNode;
  final TextEditingController controller;

  // 默认值
  final String value;
  // 背景色
  final Color backgroundColor;
  // 背景色
  final Color textFieldColor;

  // 最前面的组件
  final Widget leading;

  // 搜索框后缀组件
  final Widget suffix;
  final List<Widget> actions;

  // 提示文字
  final String hintText;

  // 输入框点击
  final VoidCallback onTap;

  // 单独清除输入框内容
  final VoidCallback onClear;

  // 清除输入框内容并取消输入
  final VoidCallback onCancel;

  // 输入框内容改变
  final ValueChanged onChanged;

  // 输入完成
  final VoidCallback onEditingComplete;

  // 点击键盘搜索
  final ValueChanged onSearch;

  @override
  _ZYSearchState createState() => _ZYSearchState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
class _ZYSearchState extends State<ZYSearchWidget> {
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.value != null) _controller.text = widget.value;
    super.initState();
  }

  // 清除输入框内容
  void _onClearInput() {
    setState(() {
      _controller.clear();
    });
    if (widget.onClear != null) widget.onClear();
  }

  // 取消输入框编辑
  void _onCancelInput() {
    setState(() {
      _controller.clear();
      _focusNode.unfocus();
    });
    if (widget.onCancel != null) widget.onCancel();
  }

  void _onInputChanged(String value) {
    setState(() {});
    if (widget.onChanged != null) widget.onChanged(value);
  }
  void _onEditingComplete() {
    setState(() {});
    if (widget.onEditingComplete != null) widget.onEditingComplete();
  }

  Widget _suffix() {
    if (_controller.text.isNotEmpty) {
      return GestureDetector(
        onTap: _onClearInput,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.cancel,
            size: 22,
            color: Color(0xFF999999),
          ),
        ),
      );
    }
    return widget.suffix ?? SizedBox();
  }

  List<Widget> _actions() {
    List<Widget> list = [];
    if (_controller.text.isNotEmpty) {
      list.add(GestureDetector(
        onTap: _onCancelInput,
        child: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '取消',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ),
      ));
    } else if (widget.actions.isNotEmpty) {
      list.addAll(widget.actions);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);
    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    double left = 0;
    double right = 0;
    if (!canPop && !hasDrawer && widget.leading == null) left = 15;
    if (_controller.text.isEmpty && widget.actions.isEmpty) right = 15;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: widget.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              height: 30,
              // width: 300,
              // margin: EdgeInsets.only(right: 18, left: 18),
              decoration: BoxDecoration(
                color: widget.textFieldColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      color: widget.textFieldColor,
                      margin: EdgeInsets.only(right: 10),
                      // padding: EdgeInsets.only(top: 10),
                      child: TextField(
                        autofocus: widget.autoFocus,
                        focusNode: _focusNode,
                        controller: _controller,
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                          // isDense: true,
                          hintText: widget.hintText ?? '请输入关键字',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            textBaseline: TextBaseline.alphabetic),
                        textInputAction: TextInputAction.search,
                        onTap: widget.onTap,
                        onChanged: _onInputChanged,
                        onEditingComplete: _onEditingComplete,
                        onSubmitted: widget.onSearch,
                        // onEditingComplete: widget.onSearch,
                      ),
                    ),
                  ),
                  _suffix(),
                ],
              ),
            ),
          ),
          Row(
            children: _actions(),
          )
        ],
      ),
    );
    // actions: _actions(),
  }
}