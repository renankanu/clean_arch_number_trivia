import 'package:clean_arch/core/errors/failures.dart';
import 'package:clean_arch/core/usecases/usecase.dart';
import 'package:clean_arch/core/utils/input_converter.dart';
import 'package:clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late GetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late GetRandomNumberTrivia mockGetRandomNumberTrivia;
  late InputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
        getConcreteTriviaUseCase: mockGetConcreteNumberTrivia,
        getRandomTriviaUseCase: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial test should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test');

    void setupMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(const Right(tNumberParsed));
    }

    test(
        'should call the InputConverter to validate and convert string to unsigned int',
        () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString));
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Left(InvalidInputFailure()));

      expectLater(bloc.stream,
          emitsInOrder([const Error(message: INVALID_INPUT_FAILURE_MESSAGE)]));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get the data from the concrete use case', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
              mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .timeout(const Duration(seconds: 5));

      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      expectLater(bloc.stream,
          emitsInOrder([Loading(), const Loaded(trivia: tNumberTrivia)]));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data failed', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => Left(ServerFailure()));

      expectLater(
          bloc.stream,
          emitsInOrder(
              [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)]));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading, Error] with a proper message when getting data fails',
        () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((_) async => Left(CacheFailure()));

      expectLater(
          bloc.stream,
          emitsInOrder(
              [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)]));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test');

    test('should get the data from the random use case', () async {
      when(mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(NoParams()))
          .timeout(const Duration(seconds: 5));

      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      when(mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      expectLater(bloc.stream,
          emitsInOrder([Loading(), const Loaded(trivia: tNumberTrivia)]));
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data failed', () async {
      when(mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(ServerFailure()));

      expectLater(
          bloc.stream,
          emitsInOrder(
              [Loading(), const Error(message: SERVER_FAILURE_MESSAGE)]));
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with a proper message when getting data fails',
        () async {
      when(mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Left(CacheFailure()));

      expectLater(
          bloc.stream,
          emitsInOrder(
              [Loading(), const Error(message: CACHE_FAILURE_MESSAGE)]));
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
