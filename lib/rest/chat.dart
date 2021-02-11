part of rest;

abstract class _ClientChatMixin implements _ClientWrapper {
  Future<List<Message>> getRoomDiscussions(String roomId) {
    Completer<List<Message>> completer = Completer();
    http.get('${_getUrl()}/chat.getDiscussions?roomId=${roomId}', headers: {
      'X-User-Id': _auth._id,
      'X-Auth-Token': _auth._token,
    }).then((response) {
      _hackResponseHeader(response);
      final rawRoomsList = (json.decode(response.body)['messages'] ?? []) as List;
      final rooms = <Message>[];
      for (var raw in rawRoomsList) {
        rooms.add(Message.fromJson(raw));
      }
      completer.complete(rooms);
    }).catchError((error) => completer.completeError(error));
    return completer.future;
  }

  Future<Message> sendMessage(Message message) {
    Completer<Message> completer = Completer();
    http
        .post('${_getUrl()}/chat.sendMessage',
            headers: {
              'X-User-Id': _auth._id,
              'X-Auth-Token': _auth._token,
              'Content-Type': 'application/json',
            },
            body: json.encode(<String, dynamic>{
              'message': message,
            }))
        .then((response) {
      _hackResponseHeader(response);
      final raw = json.decode(response.body)['message'];
      completer.complete(Message.fromJson(raw));
    }).catchError((error) => completer.completeError(error));
    return completer.future;
  }

  Future<void> reactMessage(String messageId, String emoji,
      [bool shouldReact]) {
    Completer<void> completer = Completer();
    final body = json.encode(<String, dynamic>{
      'messageId': messageId,
      'emoji': emoji,
      'shouldReact': shouldReact,
    });
    final headers = <String, String>{
      'X-User-Id': _auth._id,
      'X-Auth-Token': _auth._token,
      'Content-Type': 'application/json',
    };
    http
        .post('${_getUrl()}/chat.react', headers: headers, body: body)
        .then((response) => completer.complete(null))
        .catchError((error) => completer.completeError(error));
    return completer.future;
  }
}
