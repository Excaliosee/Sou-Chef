part of 'timer_bloc.dart';

abstract class TimerState extends Equatable{
  final int remainingTime;
  const TimerState(this.remainingTime);

  @override
  List<Object?> get props => [remainingTime];
}

class TimerInitial extends TimerState{
  const TimerInitial(super.duration);
}

class TimerRunning extends TimerState{
  const TimerRunning(super.remainingTime);
}

class TimerPaused extends TimerState{
  const TimerPaused(super.remainingTime);
}

class TimerFinished extends TimerState{
  const TimerFinished() : super(0);
}