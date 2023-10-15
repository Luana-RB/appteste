// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:appteste/models/posts/post_generico.dart';
import 'package:appteste/models/user/user.dart';
import 'package:appteste/provider/posts_provider.dart';
import 'package:appteste/provider/users_provider.dart';
import 'package:appteste/views/post_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostsForm extends StatefulWidget {
  const PostsForm({Key? key, required this.nomeUsuario}) : super(key: key);
  final String nomeUsuario;

  @override
  State<PostsForm> createState() => _PostsFormState();
}

class StatusButtonController {
  String selectedStatus = 'Solicitado';
}

class _PostsFormState extends State<PostsForm> {
  final _form = GlobalKey<FormState>();
  final Map<String, Object> _formData = {};
//Load Data
  void _loadFormaData(Post post) {
    _formData['id'] = post.id!;
    _formData['title'] = post.title!;
    _formData['status'] = post.status!;
    _formData['imageUrl'] = post.imageUrl!;
    _formData['description'] = post.description!;
    _formData['creatorName'] = post.creatorName!;
    //_formData['creatorProfileLink'] = post.creatorProfileLink!;
    // _formData['creatorImageUrl'] = post.creatorImageUrl!;
    // _formData['ownerName'] = post.ownerName!;
    //_formData['ownerProfileLink'] = post.ownerProfileLink!;
    //_formData['ownerImageUrl'] = post.ownerImageUrl!;
    _formData['dateOfLending'] = post.dateOfLending;
    //_formData['dateOfReturning'] = post.dateOfReturning!;
  }

// Status
  final StatusButtonController _statusButtonController =
      StatusButtonController();
  String selectedStatus = 'Solicitado';
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final post = ModalRoute.of(context)?.settings.arguments as Post?;
    if (post != null) {
      _loadFormaData(post);
      selectedStatus = _formData['status'].toString();
      selectedDate = post.dateOfLending;
    } else {
      selectedDate = DateTime.now();
    }
    super.didChangeDependencies();
  }
//Calendário

  Future<DateTime?> _selectDate(BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    ).then((value) {
      setState(() {
        selectedDate = value!;
      });
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Create a Post';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(title),
        centerTitle: true,
        actions: [
//Save Button
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final isValid = _form.currentState!.validate();
              if (isValid) {
                _form.currentState!.save();
//Find post ID

                final postProvider =
                    Provider.of<PostsProvider>(context, listen: false);
                final Post thisPost;
//Status Controller
                var selectedStatus = _statusButtonController.selectedStatus;
//Update post's data
                if (_formData['id'] != null) {
                  final existingPost =
                      postProvider.findById(_formData['id']!.toString());
                  selectedStatus = _formData['status'].toString();
                  //existingPost.setId = _formData['id']!.toString();
                  existingPost!.setTitle = _formData['title']!.toString();
                  existingPost.setStatus = selectedStatus;
                  existingPost.setImageUrl = _formData['imageUrl']!.toString();
                  existingPost.setDescription =
                      _formData['description']!.toString();
                  // existingPost.setOwnerName= _formData['ownerName']!.toString();
                  existingPost.setDateOfLending = selectedDate;

                  //existingPost.setDateOfReturning = _formData['dateOfReturning']!.toString();
                  postProvider.notifyListeners();
                  thisPost = existingPost;
                } else {
//if post doesn't exists yet, creat new post
                  selectedStatus = 'Solicitado';
                  final newPost = Post(
                    id: null,
                    title: _formData['title'].toString(),
                    status: selectedStatus,
                    imageUrl: _formData['imageUrl'].toString(),
                    description: _formData['description'].toString(),
                    creatorName: widget.nomeUsuario.toString(),
                    //ownerName: _formData['ownerName'].toString(),
                    dateOfLending: selectedDate,
                    //dateOfReturning: _formData['dateOfReturning'].toString(),
                  );
                  postProvider.put(newPost);
                  postProvider.notifyListeners();
                  thisPost = newPost;
                }
                final usersProvider =
                    Provider.of<UsersProvider>(context, listen: false);
                final User? thisCreator = usersProvider.all.isNotEmpty
                    ? usersProvider.all.firstWhere(
                        (user) => user.name == thisPost.creatorName,
                        orElse: () => User(name: 'null'),
                      )
                    : null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostPage(
                      post: thisPost,
                      creator: thisCreator,
                      nomeUsuario: widget.nomeUsuario,
                    ),
                  ),
                );
                // Navigator.pop(context);
              }
            },
          ),
        ],
      ),
//Form
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _form,
          child: Column(
            children: [
// //Id field
//               TextFormField(
//                 enabled: false,
//                 onSaved: (value) => _formData['id'] = value!,
//               ),
//Title field
              TextFormField(
                initialValue: _formData['title'] != null
                    ? _formData['title'].toString()
                    : '',
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ('Insert a valid title');
                  }
                  return null;
                },
                onSaved: (value) => _formData['title'] = value!,
              ),
//Status field
              DropdownButtonFormField<String>(
                value: selectedStatus,
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue!;
                  });
                },
                items: ['Solicitado', 'Emprestado', 'Devolvido']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onSaved: (value) => _formData['status'] = value!,
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
              ),
//Image field
              TextFormField(
                initialValue: _formData['imageUrl'] != null
                    ? _formData['imageUrl'].toString()
                    : '',
                decoration: const InputDecoration(labelText: 'image'),
                onSaved: (value) => _formData['imageUrl'] = value!,
              ),
//Description field
              TextFormField(
                initialValue: _formData['description'] != null
                    ? _formData['description'].toString()
                    : '',
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null,
                maxLength: 200,
                onSaved: (value) => _formData['description'] = value!,
              ),
              const SizedBox(height: 20),
//Date field
              TextButton(
                onPressed: () async {
                  _selectDate(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.pinkAccent), // Definindo a cor de fundo rosa
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                child: const Text(
                  'Selecionar Data de Empréstimo',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors
                          .white), // Defina a cor do texto como branco para melhor contraste
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
