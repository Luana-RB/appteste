import 'package:appteste/components/post_calendar.dart';
import 'package:appteste/components/post_picture.dart';
import 'package:appteste/components/profile_picture.dart';
import 'package:appteste/models/posts/post_generico.dart';
import 'package:appteste/models/user/user.dart';
import 'package:appteste/provider/users_provider.dart';
import 'package:appteste/views/posts_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  final String? idUsuario;
  const PostPage({
    super.key,
    required this.post,
    this.idUsuario,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final scrollController = ScrollController();

  bool isCurrentUserPostCreator() {
    return widget.post.creatorId == widget.idUsuario;
  }

//exemplo
  List<LoanData> loanDataList = [
    LoanData(DateTime(2023, 9, 10), DateTime(2023, 9, 15)),
    LoanData(DateTime(2023, 9, 20), null),
  ];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String status = widget.post.status.toString();
    Color colorName;
    switch (status) {
      case 'Solicitado':
        colorName = Colors.pinkAccent;
      case 'Emprestado':
        colorName = Colors.orangeAccent;
      case 'Devolvido':
        colorName = Colors.green;
        break;
      default:
        colorName = Colors.black;
    }

    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    //Find User
    final User? thisUser = usersProvider.findById(widget.idUsuario.toString());
    String userId = thisUser != null ? thisUser.id.toString() : 'null';

    //o creator é o user cujo id é igual ao id do criador do post, senão, é nulo
    final User? creator = usersProvider.all.isNotEmpty
        ? usersProvider.all.firstWhere(
            (user) => user.id == widget.post.creatorId,
            orElse: () => User(name: 'null', id: 'null'),
          )
        : null;
    String creatorId = creator != null ? creator.id.toString() : 'null';

    //o owner é o user cujo id é igual ao id do owner do post, senão, é nulo
    final User? owner = usersProvider.all.isNotEmpty
        ? usersProvider.all.firstWhere(
            (user) => user.id == widget.post.ownerId,
            orElse: () => User(name: '?', id: 'null'),
          )
        : null;
    String ownerName = owner != null ? owner.name.toString() : '?';
    String ownerId = owner != null ? owner.id.toString() : 'null';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorName,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.post.status.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
//Edit Button
          Visibility(
            visible: userId == creatorId,
            child: IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostsForm(idUsuario: userId.toString()),
                    settings: RouteSettings(
                      arguments: widget.post,
                    ),
                  ),
                );
              },
            ),
          ),
//Chat button
          Visibility(
            visible: userId != creatorId,
            child: IconButton(
              icon: const Icon(Icons.chat),
              color: Colors.white,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
//Header
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: colorName.withOpacity(0.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
//Title
                    Text(
                      widget.post.title.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorName,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
//Image
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: FittedBox(
                        fit: BoxFit.contain,
                        child: PostPicture(
                          postId: widget.post.id.toString(),
                          isSelect: true,
                          width: 0.9,
                          height: 0.4,
                        )),
                  ),
                ),
              ),
//Description
              SizedBox(
                width: 480,
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.post.description.toString(),
                        softWrap: true,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FittedBox(
                          fit: BoxFit.contain,
//Solicitant Image
                          child: ProfilePicture(
                            initials: creator!.name![0].toUpperCase(),
                            userId: creatorId,
                            color: colorName,
                            size: 0.13,
                            isSelect: false,
                          )),

                      const SizedBox(height: 10),
//Solicitant Name
                      SizedBox(
                        child: Text(
                          creator.name.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FittedBox(
                          fit: BoxFit.contain,

//Owner Image
                          child: ProfilePicture(
                            initials: ownerName[0].toUpperCase(),
                            userId: ownerId,
                            color: colorName,
                            size: 0.13,
                            isSelect: false,
                          )),
                      const SizedBox(height: 10),
//Owner Name
                      SizedBox(
                        child: Text(
                          ownerName,
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
//Dates
              PostCalendar(loanDate: widget.post.dateOfLending),
              const SizedBox(height: 20),
            ],
          )),
    );
  }
}
