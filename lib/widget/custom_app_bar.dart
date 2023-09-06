
import 'package:flutter/material.dart';

class CustomBarWidget extends StatelessWidget {

  String title;
  bool? showNavigationDrawer;
  Widget? actions;

  CustomBarWidget(this.title,{super.key, this.showNavigationDrawer = false,this.actions});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height*0.17,
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.blue,
            width: MediaQuery.of(context).size.width,
            height: 100.0,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
          Positioned(
            top: 80.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.0),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.5), width: 1.0),
                    color: Colors.white),
                child: Row(
                  children: [
                    showNavigationDrawer == true ?
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.blue,
                      ),
                      onPressed: () {

                      },
                    ):SizedBox(width:10,),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                        ),
                      ),
                    ),

                    actions != null? actions! : const SizedBox(width: 10,)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
