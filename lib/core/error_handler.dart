import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, dynamic error, {String? title}) {
    final message = _getErrorMessage(error);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: Text(title ?? '错误'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  static void showErrorWithRetry(
    BuildContext context,
    dynamic error, {
    String? title,
    required VoidCallback onRetry,
  }) {
    final message = _getErrorMessage(error);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: Text(title ?? '错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  static String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    
    final errorStr = error.toString();
    
    // 提取更友好的错误信息
    if (errorStr.contains('KeejiException:')) {
      return errorStr.split('KeejiException:').last.trim();
    }
    if (errorStr.contains('ASRException:')) {
      return '语音转写错误: ${errorStr.split('ASRException:').last.trim()}';
    }
    if (errorStr.contains('LLMException:')) {
      return '笔记生成错误: ${errorStr.split('LLMException:').last.trim()}';
    }
    if (errorStr.contains('FFmpegException:')) {
      return '音频处理错误: ${errorStr.split('FFmpegException:').last.trim()}';
    }
    if (errorStr.contains('SocketException')) {
      return '网络连接失败，请检查网络设置';
    }
    if (errorStr.contains('TimeoutException')) {
      return '请求超时，请稍后重试';
    }
    
    return errorStr;
  }
}
