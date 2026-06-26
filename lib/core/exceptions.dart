class KeejiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const KeejiException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => 'KeejiException: $message';
}

class FFmpegException extends KeejiException {
  const FFmpegException(super.message, {super.code, super.originalError});
}

class ASRException extends KeejiException {
  const ASRException(super.message, {super.code, super.originalError});
}

class LLMException extends KeejiException {
  const LLMException(super.message, {super.code, super.originalError});
}

class DatabaseException extends KeejiException {
  const DatabaseException(super.message, {super.code, super.originalError});
}
