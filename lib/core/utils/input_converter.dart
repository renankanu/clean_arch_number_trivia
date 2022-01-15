import 'package:clean_arch/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

class InputConverter {
  Either<Failures, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) {
        throw const FormatException();
      }
      return Right(integer);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}

class InvalidInputFailure extends Failures {
  @override
  List<Object?> get props => [];
}
