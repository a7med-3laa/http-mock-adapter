import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:http_mock_adapter/src/exceptions.dart';
import 'package:http_mock_adapter/src/response.dart';
import 'package:http_mock_adapter/src/types.dart';

/// Something that can respond to requests.
abstract class MockServer {
  void reply(
    int statusCode,
    dynamic data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  });

  void replyCallback(
    int statusCode,
    MockDataCallback data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  });

  void replyCallback2(
      MockStatusCodeCallback statusCode,
      MockDataCallback data, {
        Map<String, List<String>> headers = const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
        String? statusMessage,
        bool isRedirect = false,
        Duration? delay,
      });

  void replyCallbackAsync(
    int statusCode,
    MockDataCallbackAsync data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  });

  void throws(
    int statusCode,
    DioException dioError, {
    Duration? delay,
  });
}

/// The handler implements [MockServer] and
/// constructs the configured [MockResponse].
class RequestHandler implements MockServer {
  /// This is the response.
  late Future<MockResponse> Function(RequestOptions options) mockResponse;

  /// Stores [MockResponse] in [mockResponse].
  @override
  void reply(
    int statusCode,
    dynamic data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  }) {
    final isJsonContentType = headers[Headers.contentTypeHeader]?.contains(
          Headers.jsonContentType,
        ) ??
        false;

    mockResponse = (requestOptions) async {
      if (data is Uint8List) {
        return MockResponseBody.fromBytes(
          data,
          statusCode,
          headers: headers,
          statusMessage: statusMessage,
          isRedirect: isRedirect,
          delay: delay,
        );
      }
      var rawData = data;
      if (data is MockDataCallback) {
        rawData = data(requestOptions);
      }

      return MockResponseBody.from(
        isJsonContentType ? jsonEncode(rawData) : rawData,
        statusCode,
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );
    };
  }

  /// Stores [MockResponse] in [mockResponse].
  @override
  void replyCallback(
    int statusCode,
    MockDataCallback data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  }) {
    final isJsonContentType = headers[Headers.contentTypeHeader]?.contains(
          Headers.jsonContentType,
        ) ??
        false;

    mockResponse = (requestOptions) async {
      final rawData = data(requestOptions);

      return MockResponseBody.from(
        isJsonContentType ? jsonEncode(rawData) : rawData,
        statusCode,
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );
    };
  }

  /// Stores [MockResponse] in [mockResponse].
  @override
  void replyCallbackAsync(
    int statusCode,
    MockDataCallbackAsync data, {
    Map<String, List<String>> headers = const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
    String? statusMessage,
    bool isRedirect = false,
    Duration? delay,
  }) {
    final isJsonContentType = headers[Headers.contentTypeHeader]?.contains(
          Headers.jsonContentType,
        ) ??
        false;

    mockResponse = (requestOptions) async {
      final rawData = await data(requestOptions);

      return MockResponseBody.from(
        isJsonContentType ? jsonEncode(rawData) : rawData,
        statusCode,
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );
    };
  }

  /// Stores the [DioException] inside the [mockResponse].
  @override
  void throws(int statusCode, DioException dioError, {Duration? delay}) {
    mockResponse =
        (requestOptions) async => MockDioException.from(dioError, delay);
  }

  @override
  void replyCallback2(MockStatusCodeCallback statusCode, MockDataCallback data, {Map<String, List<String>> headers = const {Headers.contentTypeHeader : [Headers.jsonContentType]}, String? statusMessage, bool isRedirect = false, Duration? delay}) {
    final isJsonContentType = headers[Headers.contentTypeHeader]?.contains(
      Headers.jsonContentType,
    ) ??
        false;

    mockResponse = (requestOptions) async {
      final rawData = await data(requestOptions);

      return MockResponseBody.from(
        isJsonContentType ? jsonEncode(rawData) : rawData,
        statusCode(requestOptions),
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );
    };
  }
}
