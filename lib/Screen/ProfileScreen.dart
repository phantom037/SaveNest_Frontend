import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../Modal/LeaderboardDetail.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // late SharedPreferences preference;
  // String id = "";
  List<LeaderboardDetail> leaderboard = [
    LeaderboardDetail(
      image: "https://images.wsj.net/im-688273/?width=1278&size=1",
      name: 'Lionel Messi',
      rank: "0",
      point: 1010.10,
    ),
    LeaderboardDetail(
      image: "https://s.yimg.com/ny/api/res/1.2/YrTWB9STLHg0L_mA3qxdRg--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MA--/https://s.yimg.com/os/en-AU/homerun/y7.beau/bc1e7a06d1a0afa8038ff11561fcb0c1",
      name: 'Donald Trump',
      rank: "0",
      point: 278193.59,
    ),
    LeaderboardDetail(
      image: "https://i.pinimg.com/736x/4b/a5/22/4ba522cabd2e8325b4148c048ca8572a.jpg",
      name: 'Mickey & Minnie',
      rank: "0",
      point: 74902.08,
    ),
    LeaderboardDetail(
      image: "https://i.pinimg.com/originals/d6/bd/42/d6bd42571171a3340ba616b673d16d21.gif",
      name: 'Tom',
      rank: "0",
      point: 19.73,
    ),
    LeaderboardDetail(
      image: "https://i.pinimg.com/originals/59/30/74/593074c302700c41ae6fdfeca3d51563.gif",
      name: 'Doraemon',
      rank: "0",
      point: 9876.54,
    ),
    LeaderboardDetail(
      image: "https://pbs.twimg.com/profile_images/1796919846695026688/k1TPW6l__400x400.jpg",
      name: 'Hong Hae In',
      rank: "0",
      point: 1000000,
    ),
    LeaderboardDetail(
      image: "https://comicvine.gamespot.com/a/uploads/scale_medium/13/135098/7497077-0133622621-931f3.jpg",
      name: 'Jack Dawnson',
      rank: "0",
      point: -120.28,
    ),
    LeaderboardDetail(
      image: "https://cdn.24.co.za/files/Cms/General/d/11197/7a87fad25eb94e3ab5bd3653fddf40f0.jpg",
      name: 'Vincenzo',
      rank: "0",
      point: 28000.20,
    ),
    LeaderboardDetail(
      image: "https://64.media.tumblr.com/c06b42732d48cc58a2ab8b84cc2f5483/376e89fb95e86e07-a0/s400x600/be52aaf4657225c8f5725df5a5f87853da0c6371.gif",
      name: 'Han So Hee',
      rank: "0",
      point: 1234.4,
    ),
    LeaderboardDetail(
      image: "https://i.pinimg.com/originals/f7/45/a8/f745a8e650e3dd8cbc6ce8ce5c8ce07d.gif",
      name: 'Minami Hamabe',
      rank: "0",
      point: 97128.76,
    ),
    LeaderboardDetail(
      image: "https://img.koreatimes.co.kr/upload/thumbnailV2/144f20c34ec04c9fa1617f8458bc92eb.jpg",
      name: 'Baek Hyun Woo',
      rank: "0",
      point: 168971.11,
    ),
  ];
  @override
  void initState(){
    fetchData();
  }

  void fetchData() async {
    final QuerySnapshot resultQuery = await FirebaseFirestore.instance
      .collection("user")
      .get();
    final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;
    for(var item in documentSnapshots){
      //print("Name: ${item["name"]} Balance: ${item["balance"]}");
      leaderboard.add(LeaderboardDetail(
        image: item["photoUrl"],
        name: item["name"],
        rank: "0",
        point: 0.0 + item["balance"],
      ));
    }
    setState(() {
      leaderboard.sort((a, b) => b.point.compareTo(a.point));
    });

    for (int i = 0; i < leaderboard.length; i++) {
      setState(() {
        leaderboard[i].rank = (i + 1).toString();
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                child: Column(
                  children: [
                    Image.network(
                      "https://github.com/acrosshorizon/images/blob/main/Designer-4.png?raw=true",
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 25,
                      child: Image.network(
                        "https://github.com/Nabinji/100-DaysOf-Futter/blob/main/leaderboard/Images/line.png?raw=true",
                        fit: BoxFit.fill,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 2.2,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final items = leaderboard[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                          right: 20, left: 20, bottom: 15),
                      child: Row(
                        children: [
                          Text(
                            items.rank,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(items.image),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            items.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          //const Spacer(),
                          SizedBox(width: 20,),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Container(
                              padding: EdgeInsets.only(right: 10),
                              // height: 25,
                              // width: 70,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const RotatedBox(
                                    quarterTurns: 1,
                                    child: Icon(
                                      Icons.back_hand,
                                      color: Color.fromARGB(255, 255, 187, 0),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    items.point.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ),

          // Rank 1st
        ],
      ),
    );
  }

  Column rank({
    required double radius,
    required double height,
    required String image,
    required String name,
    required String point,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: AssetImage(image),
        ),
        SizedBox(
          height: height,
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: height,
        ),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.black54, borderRadius: BorderRadius.circular(50)),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(
                Icons.back_hand,
                color: Color.fromARGB(255, 255, 187, 0),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                point,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}