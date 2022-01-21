// ignore_for_file: constant_identifier_names

import 'package:bloc/bloc.dart';
import 'package:clean_arch/core/errors/failures.dart';
import 'package:clean_arch/core/usecases/usecase.dart';
import 'package:clean_arch/core/utils/input_converter.dart';
import 'package:clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:equatable/equatable.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteTriviaUseCase;
  final GetRandomNumberTrivia getRandomTriviaUseCase;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteTriviaUseCase,
    required this.getRandomTriviaUseCase,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      inputEither.fold(
          (failure) =>
              emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE)),
          (integer) async => getConcreteTrivia(emit, integer));
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      await getTrivia(emit, () => getRandomTriviaUseCase(NoParams()));
    });
  }

  Future<void> getConcreteTrivia(
      Emitter<NumberTriviaState> emit, int integer) async {
    await getTrivia(
        emit, () => getConcreteTriviaUseCase(Params(number: integer)));
  }

  Future<void> getTrivia(Emitter<NumberTriviaState> emit, Function func) async {
    emit(Loading());
    final triviaOrFailure = await func();
    emit(triviaOrFailure.fold(
      (failure) => Error(message: mapFailureToMessage(failure)),
      (trivia) => Loaded(trivia: trivia),
    ));
  }

  String mapFailureToMessage(Failures failure) {
    failure is ServerFailure ? SERVER_FAILURE_MESSAGE : CACHE_FAILURE_MESSAGE;
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
