import 'package:flutter/material.dart';
import 'package:todo_app/apis/list_response.dart';
import 'package:todo_app/database/db_helper.dart';
import 'package:todo_app/models/todo_model.dart';

class TodoViewModel extends ChangeNotifier {
  TodoModel? _todoModel;
  final dbHelper = DbHelper.instance;

  ListResponse _listResponse = ListResponse.error('Add New Data');

  ListResponse get response {
    return _listResponse;
  }

  TodoModel get todo {
    return _todoModel!;
  }

  Future addTodo() async {
    _listResponse = ListResponse.loading('Loading...');
    notifyListeners();
    try {
      final mapData = await dbHelper.fetchTodo();
      List<TodoModel> listModel =
          mapData.map((e) => TodoModel.fromJson(e)).toList();
      print('Length: ${listModel.length}');
      if (listModel.isNotEmpty) {
        _listResponse = ListResponse.completed(listModel);
      } else {
        _listResponse = ListResponse.error('No data');
      }
    } on Exception catch (e) {
      _listResponse = ListResponse.error(e.toString());
    }
    notifyListeners();
  }

  Future insertTodo(TodoModel todoModel) async {
    _listResponse = ListResponse.loading('Loading...');
    notifyListeners();
    try {
      int value = await dbHelper.insertTodo(todoModel);
      print('Updated: $value');
      final newMapData = await dbHelper.fetchTodo();
      print('Updated Value: $newMapData');
      List<TodoModel> listModel =
          newMapData.map((e) => TodoModel.fromJson(e)).toList();
      _listResponse = ListResponse.completed(listModel);
    } on Exception catch (e) {
      _listResponse = ListResponse.error(e.toString());
    }
    notifyListeners();
  }

  Future modifyTodo(TodoModel row) async {
    _listResponse = ListResponse.loading('Loading...');
    notifyListeners();
    print('first update: ${[row.title, row.description, row.type, row.id]}');
    try {
      await dbHelper.updateTodo(row).then((value) async {
        print(value);
        final newMapData = await dbHelper.fetchTodo();
        List<TodoModel> listModel =
            newMapData.map((e) => TodoModel.fromJson(e)).toList();
        _listResponse = ListResponse.completed(listModel);
      });
    } on Exception catch (e) {
      _listResponse = ListResponse.error(e.toString());
    }
    notifyListeners();
  }

  Future removeTodo(int id) async {
    _listResponse = ListResponse.loading('Loading...');
    notifyListeners();
    try {
      int value = await dbHelper.deleteTodo(id);
      final newMapData = await dbHelper.fetchTodo();
      List<TodoModel> listModel =
          newMapData.map((e) => TodoModel.fromJson(e)).toList();
      _listResponse = ListResponse.completed(listModel);
    } on Exception catch (e) {
      _listResponse = ListResponse.error(e.toString());
    }
    notifyListeners();
  }
}
