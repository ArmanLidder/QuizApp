import 'package:flutter/material.dart';
import 'package:polyquiz/services/translationService.dart';

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
  Map get languageText => TranslationService.instance.text;
  Map get avatarText => languageText['AVATAR_MODIFICATION'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(avatarText['CHOOSE_AVATAR']),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
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
                  child: Icon(Icons.camera_alt, size: 40),
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
