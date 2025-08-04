import 'package:flutter/material.dart';


import '../app_constants/colors.dart';

import 'app_text.dart';
import 'notification_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout; // Callback for logout action
  final bool isTitle;
  final String?title;
  CustomAppBar({required this.onLogout,this.title,this.isTitle=false});

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Container(
      height: 160, // Set the desired height
      decoration: BoxDecoration(
        color: AppColors.champagnePink, // Use your custom color
        //borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding if needed
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Container(
                //   height: 35,
                //   width: 35,
                //   child: SVGWidget(
                //
                //     assetName: ImagePath.logo_svg_white,
                //   )
                // ),
               Container(
                 width:size.width*0.45 ,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     NotificationIconWithBadge(notificationCount: 1), // Use the custom notification icon

                     IconButton(
                       icon: Icon(Icons.logout, color: Colors.white),
                       onPressed: onLogout, // Use the callback
                     ),
                   ],
                 ),
               ),


              ],
            ),
            isTitle==true?AppText(text: "$title",fontSize: 22,color: Colors.white,):SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(150); // Set the height for the AppBar
}
