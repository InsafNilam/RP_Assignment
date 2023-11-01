import 'package:chat_application/features/remainder/helper/db_helper.dart';
import 'package:chat_application/models/task.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  void delete(Task task) {
    DBHelper.delete(task);
    getTasks();
  }

  void updateTask(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

  void deleteAll() async {
    await DBHelper.deleteAll();
    getTasks();
  }
}
