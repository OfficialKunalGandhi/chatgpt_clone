class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    this.data,
    this.message,
    this.success = true,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse(
      data: data,
      message: message,
      success: true,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse(
      data: null,
      message: message,
      success: false,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      data: json['data'],
      message: json['message'],
      success: json['success'] ?? true,
      statusCode: json['statusCode'],
      metadata: json['metadata'],
    );
  }
}
