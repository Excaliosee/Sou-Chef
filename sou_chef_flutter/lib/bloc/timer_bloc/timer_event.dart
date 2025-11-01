part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable{
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends TimerEvent{
  final int duration;
  const StartTimer(this.duration);

  @override
  List<Object> get props => [duration];
}

class PauseTimer extends TimerEvent{
  const PauseTimer();
}

class ResetTimer extends TimerEvent{
  const ResetTimer();
}

class _TimerTicked extends TimerEvent{
  final int remainingTime;
  const _TimerTicked(this.remainingTime);

  @override
  List<Object> get props => [remainingTime];
}