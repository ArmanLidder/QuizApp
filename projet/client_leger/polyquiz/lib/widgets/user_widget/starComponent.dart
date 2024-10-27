import 'package:flutter/material.dart';

class StarCard extends StatelessWidget {
  final String label;
  final bool isDone;

  StarCard({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 120, // Increased height to accommodate longer text
          padding: const EdgeInsets.all(8.0), // Internal padding
          decoration: BoxDecoration(
            color: Colors.grey[300], // Light grey color for the background
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center elements vertically
            children: [
              Icon(
                isDone
                    ? Icons.star
                    : Icons
                        .star_border, // Filled star if done, otherwise outline
                size: 48,
                color: isDone
                    ? Color(0xFFFCDB03)
                    : Colors.black54, // Yellow color if done
              ),
              SizedBox(height: 8), // Space between icon and text
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center, // Center text
                  style: TextStyle(fontSize: 12), // Adjust font size if needed
                  overflow: TextOverflow.visible, // Allow text to wrap
                  maxLines: 3, // Limit the number of lines to avoid overflow
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StarCardGrid extends StatelessWidget {
  final List<String> labels;
  final List<num> achievementsList;

  StarCardGrid({required this.labels, required this.achievementsList});

  @override
  Widget build(BuildContext context) {
    // Determine how many cards can fit in a row
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = 100;
    final double horizontalMargin = 4.0;
    final double verticalMargin = 4.0;
    //L'algo qui suit a ete fait a 75% avec chatgpt et est donc pas tres lisible
    // si ca casse pinguez Maxime
    final int cardsPerRow = ((screenWidth - (horizontalMargin * 4)) /
            (cardWidth + horizontalMargin))
        .floor();

    List<Widget> rows = [];

    for (int i = 0; i < labels.length; i += cardsPerRow) {
      List<Widget> starCards = [];
      for (int j = 0; j < cardsPerRow; j++) {
        if (i + j < labels.length) {
          bool isDone = achievementsList.contains(i + j);
          starCards.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: StarCard(
                label: labels[i + j],
                isDone: isDone,
              ),
            ),
          );
        }
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: starCards,
      ));
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: verticalMargin),
        ),
      );
    }
    return Column(
      children: rows,
    );
  }
}
