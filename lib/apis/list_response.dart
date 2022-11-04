class ListResponse<T> {
  String? message;
  T? data;
  Status status;

  ListResponse.loading(this.message) : status = Status.LOADING;

  ListResponse.completed(this.data) : status = Status.COMPLETED;

  ListResponse.error(this.message) : status = Status.ERROR;
}

enum Status { LOADING, COMPLETED, ERROR }
