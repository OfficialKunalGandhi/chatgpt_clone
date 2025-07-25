import 'package:dio/dio.dart';
import '../api_client.dart';
import '../api_response.dart';
import '../api_exceptions.dart';
import '../../models/message.dart';
import '../../models/conversation.dart';

class OpenAIService {
  final Dio _dio = ApiClient.getInstance().dio;
  final String _baseUrl = 'https://api.openai.com/v1';

  // Default model
  String _model = 'gpt-3.5-turbo';

  // API key should be stored securely, ideally fetched from environment variables
  // or a secure storage service
  String _apiKey = '';

  // Singleton pattern
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  String get currentModel => _model;

  void setModel(String model) {
    // Validate model
    if (['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'].contains(model)) {
      _model = model;
    } else {
      throw ApiException(
        message: 'Invalid model: $model. Supported models are: gpt-3.5-turbo, gpt-4, gpt-4-turbo',
        statusCode: 400,
      );
    }
  }

  Future<ApiResponse<Message>> sendMessage({
    required String userId,
    required String conversationId,
    required String content,
    String? model,
  }) async {
    try {
      // Use provided model or default
      final selectedModel = model ?? _model;

      // Create headers with API key
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Format request for OpenAI API
      final Map<String, dynamic> requestData = {
        'model': selectedModel,
        'messages': [
          {'role': 'user', 'content': content}
        ],
        'temperature': 0.7,
      };

      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        data: requestData,
        options: Options(headers: headers),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = response.data;
        final aiMessage = responseData['choices'][0]['message']['content'];

        // Create message object
        final message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          content: aiMessage,
          sender: 'assistant',
          timestamp: DateTime.now(),
        );

        return ApiResponse.success(
          data: message,
          statusCode: response.statusCode,
          message: 'Message sent successfully',
        );
      } else {
        throw ApiException(
          message: 'Failed to get response from OpenAI',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error sending message to OpenAI',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<String>> generateImage({
    required String prompt,
    String size = '1024x1024',
    int n = 1,
  }) async {
    try {
      // Create headers with API key
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      // Format request for OpenAI API
      final Map<String, dynamic> requestData = {
        'prompt': prompt,
        'n': n,
        'size': size,
      };

      final response = await _dio.post(
        '$_baseUrl/images/generations',
        data: requestData,
        options: Options(headers: headers),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = response.data;
        final imageUrl = responseData['data'][0]['url'];

        return ApiResponse.success(
          data: imageUrl,
          statusCode: response.statusCode,
          message: 'Image generated successfully',
        );
      } else {
        throw ApiException(
          message: 'Failed to generate image',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error generating image with OpenAI',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(
        message: e.toString(),
        statusCode: 500,
      );
    }
  }
}
