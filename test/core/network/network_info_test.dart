import 'package:clean_arch/core/platform/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker dataConnectionChecker;

  setUp(() {
    dataConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(dataConnectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to DataConnectionChecker.hasConnection',
        () async {
      final tHasConnectionFuture = Future.value(true);
      when(dataConnectionChecker.hasConnection)
          .thenAnswer((_) => tHasConnectionFuture);
      final Future<bool> result = networkInfo.isConnected;

      verify(dataConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}
