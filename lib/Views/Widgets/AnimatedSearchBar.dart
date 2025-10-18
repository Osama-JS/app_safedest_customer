import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Globals/global_methods.dart' as global_methods;

typedef QueryListItemBuilder<T> = Widget Function(T item);
typedef OnItemSelected<T> = void Function(T item);
typedef QueryBuilder<T> = List<T> Function(
    String query,
    List<T> list,
    );
enum AnimationAlignment { left, right }

class AnimatedSearchBar<T> extends StatefulWidget {
  const AnimatedSearchBar(
      {required this.searchList,
        required this.overlaySearchListItemBuilder,
        required this.searchQueryBuilder,
        required this.buttonIcon,
        required this.submitIcon,
        required this.onSubmit,
        this.onChanged,
        this.onFieldSubmitted,
        super.key,
        this.width,
        this.hintText,
        this.duration,
        this.failMessage,
        this.shadow,
        this.textController,
        this.animationAlignment,
        this.onItemSelected,
        this.hideSearchBoxWhenItemSelected = false,
        this.overlaySearchListHeight,
        this.noItemsFoundWidget,
        this.backgroundColor,
        this.buttonBackgroundColor,
        this.submitButtonBackgroundColor,
        this.searchBoxInputDecoration,
        this.buttonColor,
        this.textStyle,
        this.submitButtonColor});

  final List<T> searchList;
  final QueryListItemBuilder<T> overlaySearchListItemBuilder;
  final bool hideSearchBoxWhenItemSelected;
  final double? overlaySearchListHeight;
  final QueryBuilder<T> searchQueryBuilder;
  final Widget? noItemsFoundWidget;
  final OnItemSelected<T>? onItemSelected;
  final InputDecoration? searchBoxInputDecoration;
  final TextEditingController? textController;
  final double? width;
  final Color? backgroundColor;
  final Color? buttonBackgroundColor;
  final Color? submitButtonBackgroundColor;
  final Function onSubmit;
  final Function? onChanged;
  final Function? onFieldSubmitted;


  final List<BoxShadow>? shadow;
  final Widget buttonIcon;
  final Widget submitIcon;
  final String? hintText;
  final Duration? duration;
  final Color? buttonColor;
  final Color? submitButtonColor;
  final TextStyle? textStyle;
  final AnimationAlignment? animationAlignment;
  final String? failMessage;

  @override
  _AnimatedSearchBarStateone<T> createState() => _AnimatedSearchBarStateone<T>();
}

class _AnimatedSearchBarStateone<T> extends State<AnimatedSearchBar<T?>>
    with SingleTickerProviderStateMixin {
  bool toggle = false;
  late List<T> _list;
  late List<T?> _searchList;
  bool? isFocused;
  late FocusNode _focusNode;
  late ValueNotifier<T?> notifier;
  bool? isRequiredCheckFailed;
  Widget? searchBox;
  OverlayEntry? overlaySearchList;
  bool showTextBox = false;
  double? overlaySearchListHeight;
  final LayerLink _layerLink = LayerLink();
  final double textBoxHeight = 30;
  TextEditingController textController = TextEditingController();
  bool isSearchBoxSelected = false;
  late AnimationController _animationController;
  late List<BoxShadow> shadow;
  late String _hintText;
  late Duration duration;

  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    overlaySearchList?.remove();
    super.dispose();
  }
  void init() {
    _hintText = widget.hintText ?? "search".tr;
    duration = widget.duration ?? const Duration(seconds: 1);
    _searchList = <T>[];
    textController = widget.textController ?? textController;
    notifier = ValueNotifier(null);
    _focusNode = FocusNode();
    isFocused = false;
    _list = List<T>.from(widget.searchList);
  //  _searchList.addAll(_list);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        overlaySearchList?.remove();
        overlaySearchList = null;
      } else {
        _searchList
          ..clear()
          ..addAll(_list);
        if (overlaySearchList == null) {
        } else {}
      }
    });
    textController.addListener(() {
      final text = textController.text;
      if (text.trim().isNotEmpty) {
        _searchList.clear();

        final List<T?> filterList =
        widget.searchQueryBuilder(text, widget.searchList);
        _searchList.addAll(filterList);
        if (overlaySearchList == null) {
        } else {
       //   overlaySearchList?.markNeedsBuild();
        }
      } else {
        _searchList
          ..clear()
          ..addAll(_list);
        if (overlaySearchList == null) {
        } else {
        //  overlaySearchList?.markNeedsBuild();
        }
      }
    });
   _animationController = AnimationController(vsync: this, duration: duration);
  }

  @override
  void didUpdateWidget(AnimatedSearchBar oldWidget) {


    super.didUpdateWidget(oldWidget as AnimatedSearchBar<T>);
  }

  void onSearchListItemSelected(T? item) {
    overlaySearchList?.remove();

    overlaySearchList = null;
    _focusNode.unfocus();
    setState(() {
      notifier.value = item;
      isFocused = false;
      isRequiredCheckFailed = false;
      isSearchBoxSelected = false;
    });
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(item);
    }
  }

  void onTextFieldFocus() {
    setState(() {
      isSearchBoxSelected = true;
    });
   // overlaySearchList?.markNeedsBuild();
    final RenderBox searchBoxRenderBox =
    context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    final width = searchBoxRenderBox.size.width * 0.8;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        searchBoxRenderBox.localToGlobal(
          searchBoxRenderBox.size.topLeft(Offset.zero),
          ancestor: overlay,
        ),
        searchBoxRenderBox.localToGlobal(
          searchBoxRenderBox.size.topRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
   // Overlay.of(context)?.insert(overlaySearchList!);
  }

  @override
  Widget build(BuildContext context) {
    overlaySearchListHeight = widget.overlaySearchListHeight ??
        MediaQuery.of(context).size.height / 4;
    double? width = widget.width != null
        ? (widget.width! < 200)
        ? 200
        : widget.width
        : 300;

    searchBox = Container(
      margin: const EdgeInsets.only(right: 80),
      child: TextFormField(
        onChanged: (value) {
          widget.onChanged!(value);
          if (overlaySearchList == null) {
            onTextFieldFocus();
          } else {
            overlaySearchList?.markNeedsBuild();
          }
        },
        onFieldSubmitted: (text){
          widget.onFieldSubmitted!(text);

        },
        controller: textController,
        focusNode: _focusNode,
        style: widget.textStyle ??
            const TextStyle(fontSize: 16, color: Colors.black),
        decoration: widget.searchBoxInputDecoration ??
            InputDecoration(

              // enabledBorder: const OutlineInputBorder(
              //   borderSide: BorderSide.,
              // ),
              focusedBorder:
              const OutlineInputBorder(borderSide: BorderSide.none),
              border: InputBorder.none,
              hintText: 'search'.tr,


              hintStyle: global_methods.textInput(),

              contentPadding: const EdgeInsets.only(
                left: 16,
                right: 20,
                top: 14,
                bottom: 14,
              ),
            ),
      ),
    );

    final searchBoxBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.hideSearchBoxWhenItemSelected && notifier.value != null)
          const SizedBox(height: 0)
        else
          CompositedTransformTarget(
            link: _layerLink,
            child: searchBox,
          ),
      ],
    );

    return Container(


      alignment: widget.animationAlignment != null &&
          widget.animationAlignment == AnimationAlignment.right
          ? const Alignment(1, 0)
          : const Alignment(-1, 0),
      child: AnimatedContainer(
        duration: duration,
        height: 50,
        width: toggle ? width : 50,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.blue,
          borderRadius:  const BorderRadius.all(Radius.circular(20) ),
          boxShadow: widget.shadow,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              top: 1,
              bottom: 1,
              right: widget.animationAlignment != null &&
                  widget.animationAlignment == AnimationAlignment.left
                  ? 1
                  : null,
              left: widget.animationAlignment != null &&
                  widget.animationAlignment == AnimationAlignment.right
                  ? 1
                  : null,
              curve: Curves.easeOut,
              duration: duration,
              child: AnimatedOpacity(
                opacity: toggle ? 1 : 0,
                duration: duration,
                child: AnimatedBuilder(

                  builder: (context, widget) {
                    return Transform.rotate(
                      angle: _animationController.value * pi * 2,
                      child: widget,
                    );
                  },
                  animation: _animationController,
                ),
              ),
            ),
            AnimatedPositioned(
              left: toggle ? 45 : 10,
              duration: duration,
              child: AnimatedOpacity(
                opacity: toggle ? 1 : 0,
                duration: duration,
                child: SizedBox(
                  width: width! - 60,
                  child: searchBoxBody,
                ),
              ),
            ),
            Positioned(
              top: 1,
              bottom: 1,
              right: widget.animationAlignment != null &&
                  widget.animationAlignment == AnimationAlignment.right
                  ? 1
                  : null,
              left: widget.animationAlignment != null &&
                  widget.animationAlignment == AnimationAlignment.left
                  ? 1
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.buttonBackgroundColor ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  iconSize: 30,
                  color: widget.buttonColor ?? Colors.black,
                  onPressed: () {
                    textController.clear();
                    setState(() {
                      if (toggle) {
                        _animationController.reverse();
                      } else {
                        _animationController.forward();
                      }
                      toggle = !toggle;
                    });
                  },
                  icon: widget.buttonIcon,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}
