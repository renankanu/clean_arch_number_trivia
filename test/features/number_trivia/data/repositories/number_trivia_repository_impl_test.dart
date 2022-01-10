import 'package:clean_arch/core/platform/network_info.dart';
import 'package:clean_arch/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_arch/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_arch/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_arch/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([
  NumberTriviaLocalDataSource,
  NetworkInfo,
])
@GenerateMocks([], customMocks: [
  MockSpec<NumberTriviaRemoteDataSource>(returnNullOnMissingStub: true)
])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  const tNumber = 1;
  const tNumberTriviaModel =
      NumberTriviaModel(number: tNumber, text: 'test trivia');
  const NumberTrivia tNumberTrivia = tNumberTriviaModel;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });
  });

  group('device is online', () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(const Right(tNumberTrivia)));
      },
    );
  });
}
