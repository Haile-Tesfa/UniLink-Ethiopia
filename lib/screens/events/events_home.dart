import 'package:flutter/material.dart';
import 'event_details_screen.dart';
import '../../utils/colors.dart';

class EventsHome extends StatefulWidget {
  const EventsHome({super.key});

  @override
  State<EventsHome> createState() => _EventsHomeState();
}

class _EventsHomeState extends State<EventsHome> {
  final List<Map<String, dynamic>> _events = [
    {
      'id': '1',
      'title': 'Robotics Club Workshop',
      'description': 'Learn Arduino and basic robotics',
      'date': 'Dec 31, 2025',
      'time': '10:00 AM',
      'location': 'University Innovation Lab',
      'image': 'assets/images/home/post_0.jpg',
      'organizer': 'Robotics Club',
      'attendees': 45,
    },
    {
      'id': '2',
      'title': 'Career Fair 2024',
      'description': 'Meet top employers and companies',
      'date': 'Jan 15, 2024',
      'time': '9:00 AM',
      'location': 'Main Auditorium',
      'image': 'assets/images/home/post_1.jpg',
      'organizer': 'Career Center',
      'attendees': 120,
    },
    {
      'id': '3',
      'title': 'Cultural Festival',
      'description': 'Celebrate diversity with food and performances',
      'date': 'Jan 20, 2024',
      'time': '4:00 PM',
      'location': 'University Grounds',
      'image': 'assets/images/profile/prof_1.jpg',
      'organizer': 'Student Union',
      'attendees': 200,
    },
  ];

  final List<Map<String, dynamic>> _clubs = [
    {
      'id': '1',
      'name': 'Robotics Club',
      'members': 85,
      'category': 'Technology',
      'image': 'assets/images/profile/prof_2.jpg',
    },
    {
      'id': '2',
      'name': 'Debate Society',
      'members': 120,
      'category': 'Academics',
      'image': 'assets/images/profile/prof_3.jpg',
    },
    {
      'id': '3',
      'name': 'Arts & Culture',
      'members': 65,
      'category': 'Arts',
      'image': 'assets/images/profile/prof_1.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events & Clubs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Events'),
              Tab(text: 'Clubs'),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Events Tab
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create-event');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._events.map((event) => _EventCard(
                    event: event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                  )).toList(),
                ],
              ),
            ),
            
            // Clubs Tab
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'University Clubs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                          label: const Text('Explore'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._clubs.map((club) => _ClubCard(club: club)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  event['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['description'],
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text('${event['date']} • ${event['time']}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Text(event['location']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final Map<String, dynamic> club;

  const _ClubCard({
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(club['image']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club['category'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14),
                      const SizedBox(width: 4),
                      Text('${club['members']} members'),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}