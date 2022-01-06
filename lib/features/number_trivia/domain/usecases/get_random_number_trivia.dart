import 'package:clean_arch/core/errors/failures.dart';
import 'package:clean_arch/core/usecases/usecase.dart';
import 'package:clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

class GetRandomNumberTrivia extends Usecase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failures, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}
