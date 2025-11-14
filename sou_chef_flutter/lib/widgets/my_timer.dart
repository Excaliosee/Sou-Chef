import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sou_chef_flutter/bloc/timer_bloc/timer_bloc.dart';

class MyTimer extends StatelessWidget {
  final int initialDuration;
  const MyTimer({super.key, this.initialDuration = 300});

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$remainingSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Recipe Timer',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 16,),

          BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              final displayTime = _formatDuration(state.remainingTime);
              return Text(
                displayTime,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          ),

          const SizedBox(height: 16),

          BlocBuilder<TimerBloc, TimerState>(
            builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state is TimerInitial || state is TimerPaused) 
                    FloatingActionButton(
                      heroTag: 'timer_start_pause',
                      child: const Icon(Icons.play_arrow),
                      onPressed: () {
                        final duration = state.remainingTime > 0 ? state.remainingTime : initialDuration;
                        context.read<TimerBloc>().add(StartTimer(duration));
                      }
                    ),
                  
                  if (state is TimerRunning) 
                    FloatingActionButton(
                      heroTag: 'timer_start_pause',
                      child: Icon(Icons.pause),
                      onPressed: () {
                        context.read<TimerBloc>().add(const PauseTimer());
                      }
                    ),

                  if (state is! TimerInitial) 
                    FloatingActionButton(
                      heroTag: 'timer_reset',
                      backgroundColor: Colors.red.shade700,
                      child: Icon(Icons.replay),
                      onPressed: () {
                        context.read<TimerBloc>().add(const ResetTimer());
                      }
                    ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}