import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class RoomListPage extends StatefulWidget {
  @override
  _RoomListPageState createState() => _RoomListPageState();
}

class _RoomListPageState extends State<RoomListPage> {
  final RoomService roomService = RoomService();
  List<Room> rooms = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      List<Room> fetchedRooms = await roomService.fetchRooms();
      setState(() {
        rooms = fetchedRooms;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      child: ListTile(
                        title: Text('Room Code: ${room.code}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: room.players
                              .map((player) => Text(player.name))
                              .toList(),
                        ),
                        onTap: () {
                          // Handle room selection here
                        },
                      ),
                    );
                  },
                ),
    );
  }
}