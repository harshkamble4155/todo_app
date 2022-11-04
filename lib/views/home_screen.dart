import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/apis/list_response.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/viewmodel/todo_view_model.dart';

enum Type { TODAY, TOMORROW, UPCOMING }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Widget listWidget(BuildContext context, ListResponse listResponse) {
    List<TodoModel>? todoModelList = listResponse.data as List<TodoModel>?;
    switch (listResponse.status) {
      case Status.LOADING:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case Status.COMPLETED:
        return Column(
          children: [
            clickOpenSheet(context),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: todoModelList!.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todoModelList[index].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(todoModelList[index].description ?? ''),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              final todoModel = TodoModel(
                                  id: todoModelList[index].id!,
                                  title: todoModelList[index].title,
                                  description: todoModelList[index].description,
                                  type: todoModelList[index].type);
                                  _titleCtrl.text = todoModel.title;
                    _descCtrl.text = todoModel.description == ''
                        ? ''
                        : todoModel.description!;
                              updateTodoList(context, todoModel);
                              setState(() {
                                
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.indigo,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Provider.of<TodoViewModel>(context, listen: false)
                                  .removeTodo(todoModelList[index].id!);
                            },
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ],
        );
      case Status.ERROR:
        return Column(
          children: [
            clickOpenSheet(context),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(listResponse.message.toString()),
              ),
            ),
          ],
        );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<TodoViewModel>(context, listen: false).addTodo();
    });
  }

  @override
  Widget build(BuildContext context) {
    ListResponse _listResponse = Provider.of<TodoViewModel>(context).response;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
      ),
      body: listWidget(context, _listResponse),
    );
  }

  clickOpenSheet(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.task_alt,
            color: Colors.green,
          ),
          title: const Text('Today'),
          trailing: IconButton(
            onPressed: () {
              addTodoList(context, Type.TODAY);
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.task_alt,
            color: Colors.yellow,
          ),
          title: const Text('Tomorrow'),
          trailing: IconButton(
            onPressed: () {
              addTodoList(context, Type.TOMORROW);
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.task_alt,
            color: Colors.red,
          ),
          title: const Text('Upcoming'),
          trailing: IconButton(
            onPressed: () {
              addTodoList(context, Type.UPCOMING);
            },
            icon: const Icon(Icons.add_box_outlined),
          ),
        ),
      ],
    );
  }

  updateTodoList(BuildContext context, TodoModel todoModel) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _titleCtrl.clear();
                    _descCtrl.clear();
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    final _todoModel = TodoModel(
                      title: _titleCtrl.text,
                      description: _descCtrl.text == '' ? '' : _descCtrl.text,
                      type: todoModel.type,
                    );
                    Provider.of<TodoViewModel>(context, listen: false)
                        .modifyTodo(_todoModel.toJson(), todoModel.id);
                    Navigator.of(context).pop();
                    _titleCtrl.clear();
                    _descCtrl.clear();
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Title',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Description(Optional)',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  addTodoList(BuildContext context, Type type) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _titleCtrl.clear();
                    _descCtrl.clear();
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    final todoModel = TodoModel(
                        title: _titleCtrl.text,
                        description: _descCtrl.text == '' ? '' : _descCtrl.text,
                        type: type.name);
                    Provider.of<TodoViewModel>(context, listen: false)
                        .insertTodo(todoModel);
                    Navigator.of(context).pop();
                    _titleCtrl.clear();
                    _descCtrl.clear();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Title',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter Description(Optional)',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
