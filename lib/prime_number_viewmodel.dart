import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final findPrimeNumberViewModel =
    StateNotifierProvider<FindPrimeNumberViewModel, AsyncValue<List<int>>>(
        (ref) => FindPrimeNumberViewModel(const AsyncValue.data([])));

class FindPrimeNumberViewModel extends StateNotifier<AsyncValue<List<int>>> {
  FindPrimeNumberViewModel(super.state);

  Future<void> searchList(int maxNumber) async {
    state = const AsyncValue.loading();
    final responsePort = ReceivePort();

    final isolate =
        await Isolate.spawn(_findPrimeNumbersInIsolate, responsePort.sendPort);

    final sendPort = await responsePort.first as SendPort;
    final resultPort = ReceivePort();
    sendPort.send((maxNumber, resultPort.sendPort));

    resultPort.listen((message) {
      if (message is List<int>) {
        state = AsyncValue.data(message);
      } else if (message is String) {
        state = AsyncValue.error(message, StackTrace.current);
      }
      resultPort.close();
      isolate.kill();
    });
  }

  static void _findPrimeNumbersInIsolate(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.listen((message) {
      if (message is (int, SendPort)) {
        final (maxNumber, resultPort) = message;
        try {
          final primeNumbers = findPrimeNumbers(maxNumber);

          resultPort.send(primeNumbers);
        } catch (e) {
          resultPort.send('Error: $e');
        }
      }
    });
  }

  static List<int> findPrimeNumbers(int maxNumber) {
    List<int> primeNumbers = [];

    for (int i = 2; i <= maxNumber; i++) {
      if (_isPrimeNumber(i)) {
        primeNumbers.add(i);
      }
    }

    return primeNumbers;
  }

  static bool _isPrimeNumber(int number) {
    if (number < 2) return false;
    if (number == 2) return true;
    if (number % 2 == 0) return false;

    for (int divisor = 3; divisor * divisor <= number; divisor += 2) {
      if (number % divisor == 0) {
        return false;
      }
    }
    return true;
  }

  resetValue() {
    state = const AsyncValue.data([]);
  }
}
