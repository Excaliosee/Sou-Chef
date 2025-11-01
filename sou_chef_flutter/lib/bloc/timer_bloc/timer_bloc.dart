import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState>{
  StreamSubscription<int>? _tickerSubscription;

  int _originalDuration = 0;

  TimerBloc() : super(TimerInitial(0)) {
    on<StartTimer>(_onTimerStarted);
    on<PauseTimer>(_onTimerPaused);
    on<ResetTimer>(_onTimerReset);
    on<_TimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onTimerStarted(StartTimer event, Emitter<TimerState> emit) {
    _originalDuration = event.duration;
    emit(TimerRunning(event.duration));

    _tickerSubscription?.cancel();

    _tickerSubscription = _ticker(event.duration).listen(
      (remainingTime) => add(_TimerTicked(remainingTime))
    );
  }

  void _onTimerPaused(PauseTimer event, Emitter<TimerState> emit) {
    if (state is TimerRunning) {
      _tickerSubscription?.pause();
      emit(TimerPaused(state.remainingTime));
    }
  }

  void _onTimerReset(ResetTimer event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_originalDuration));
  }

  void _onTimerTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.remainingTime > 0) {
      emit(TimerRunning(event.remainingTime));
    }
    else {
      emit(const TimerFinished());
    }
  }

  Stream<int> _ticker(int duration) {
    return Stream.periodic(const Duration(seconds: 1), (x) {
      return duration - 1 - x;
    }).take(duration);
  }
}