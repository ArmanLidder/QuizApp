import 'package:flutter/material.dart';

import '../../services/logged_in_user_service.dart';

class ImageSelectionPopup extends StatelessWidget {
  final List<String> imageUrls;
  //final Function onImageSelected;
  final VoidCallback onPlusButtonPressed;

  ImageSelectionPopup({
    required this.imageUrls,
    required this.onPlusButtonPressed,
  });
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Choose Profile Picture'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, //TODO: change peut-etre?
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: imageUrls.length + 1,
          itemBuilder: (context, index) {
            if (index == imageUrls.length) {
              return GestureDetector(
                onTap: onPlusButtonPressed,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, size: 40),
                ),
              );
            }

            // Display each image URL in the grid
            return GestureDetector(
              onTap: () async {
                await loggedInUserService.chooseNewProfilePicture(imageUrls[index]);
                Navigator.of(context).pop(); // Close the popup after selecting the image
              },
              child: Container(
                width:50,
                height:50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
