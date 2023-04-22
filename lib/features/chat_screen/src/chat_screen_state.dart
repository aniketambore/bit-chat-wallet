part of 'chat_screen_cubit.dart';

abstract class ChatScreenState extends Equatable {
  const ChatScreenState();
}

class ChatScreenInProgress extends ChatScreenState {
  const ChatScreenInProgress();

  @override
  List<Object?> get props => [];
}

class ChatScreenSuccess extends ChatScreenState {
  const ChatScreenSuccess({
    required this.myPrivKey,
    required this.myPubKey,
    this.syncStatus = SyncStatus.success,
  });

  final String myPrivKey;
  final String myPubKey;
  final SyncStatus syncStatus;

  @override
  List<Object?> get props => [
        myPrivKey,
        myPubKey,
        syncStatus,
      ];
}

class ChatScreenFailure extends ChatScreenState {
  const ChatScreenFailure();

  @override
  List<Object?> get props => [];
}

enum SyncStatus {
  idle,
  inProgress,
  success,
  error,
}
