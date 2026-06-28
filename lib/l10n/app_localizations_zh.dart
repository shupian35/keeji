// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '课记';

  @override
  String get home => '主页';

  @override
  String get settings => '设置';

  @override
  String get import => '导入';

  @override
  String get importVideo => '导入视频';

  @override
  String get importText => '导入原文';

  @override
  String get batchExport => '批量导出';

  @override
  String get batchDelete => '批量删除';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String selectedItems(Object count) {
    return '已选择 $count 项';
  }

  @override
  String get exportNotes => '导出笔记';

  @override
  String get exportTranscripts => '导出转写原文';

  @override
  String get exportAll => '全部导出';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get save => '保存';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get noVideos => '暂无视频';

  @override
  String get importVideosHint => '点击右上角 + 导入视频';

  @override
  String get pending => '等待处理';

  @override
  String processing(Object progress) {
    return '处理中 $progress%';
  }

  @override
  String get done => '完成';

  @override
  String get failed => '失败';

  @override
  String get viewNotes => '查看笔记';

  @override
  String get updatePath => '更新路径';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get confirmDeleteMessage => '确定要删除这个视频吗？相关的笔记也会被删除。';

  @override
  String get confirmBatchDelete => '确认批量删除';

  @override
  String confirmBatchDeleteMessage(Object count) {
    return '确定要删除选中的 $count 个视频吗？相关的笔记也会被删除。';
  }

  @override
  String get pathUpdated => '路径已更新';

  @override
  String get updateFailed => '更新失败';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get retryFailed => '重试失败';

  @override
  String get asrSettings => '语音转写 (ASR)';

  @override
  String get llmSettings => '笔记生成 (LLM)';

  @override
  String get otherSettings => '其他设置';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiBaseUrl => 'API 地址';

  @override
  String get model => '模型';

  @override
  String get saveSettings => '保存设置';

  @override
  String get testConnection => '测试连接';

  @override
  String get testing => '测试中...';

  @override
  String get connectionSuccess => '连接成功';

  @override
  String get connectionFailed => '连接测试失败';

  @override
  String get pleaseEnterApiKey => '请先输入 API Key';

  @override
  String get settingsSaved => '设置已保存';

  @override
  String get enableAudioChunking => '启用长音频分段';

  @override
  String get enableAudioChunkingHint => '长音频自动在静音处切分后转写';

  @override
  String get appearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get lightMode => '浅色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get transcriptOriginal => '转写原文';

  @override
  String get noTranscript => '暂无转写内容';

  @override
  String get transcriptWillAppear => '视频处理完成后会显示转写原文';

  @override
  String get transcriptParseFailed => '转写内容解析失败';

  @override
  String get copyNote => '复制笔记';

  @override
  String get noteCopied => '笔记已复制到剪贴板';

  @override
  String get exportNote => '导出笔记';

  @override
  String get exportTranscript => '导出转写';

  @override
  String get regenerate => '重新生成';

  @override
  String get exportFailed => '导出失败';

  @override
  String get regenerateFailed => '重新生成失败';

  @override
  String get noteRegenerated => '笔记已重新生成';

  @override
  String get generating => '生成中...';

  @override
  String get generateNote => '生成笔记';

  @override
  String get noNote => '暂无笔记';

  @override
  String get selectVideoFiles => '选择视频文件';

  @override
  String get selectTextFiles => '选择原文文件';

  @override
  String supportedFormats(Object formats) {
    return '支持 $formats';
  }

  @override
  String get selectFiles => '选择文件';

  @override
  String selectedFiles(Object count) {
    return '已选择 $count 个文件';
  }

  @override
  String get importAfterSelect => '导入后立即开始处理';

  @override
  String get importTextAfterSelect => '导入后立即生成笔记';

  @override
  String importVideos(Object count) {
    return '导入 $count 个视频';
  }

  @override
  String importTexts(Object count) {
    return '导入 $count 个原文';
  }

  @override
  String get importing => '导入中...';

  @override
  String importSuccess(Object count) {
    return '成功导入 $count 个文件';
  }

  @override
  String get importFailed => '导入失败';

  @override
  String get configIncomplete => '配置不完整';

  @override
  String get asrConfigIncomplete => 'ASR API Key 未配置';

  @override
  String get llmConfigIncomplete => 'LLM API Key 未配置';

  @override
  String get importOnly => '只导入';

  @override
  String get importOnlyHint => 'API 配置不完整，无法自动处理。是否只导入？';

  @override
  String get videoProcessorBusy => '已有视频正在处理中';

  @override
  String get batchExportFailed => '批量导出失败';

  @override
  String exportedTo(Object count, Object path) {
    return '已导出 $count 个文件到: $path';
  }

  @override
  String get siliconflow => 'SiliconFlow';

  @override
  String get xiaomiMiMo => '小米 MiMo';

  @override
  String get openaiWhisper => 'OpenAI Whisper';

  @override
  String get custom => '自定义';

  @override
  String get presetProvider => '服务商预设';

  @override
  String get asrPresetHint =>
      '小米 MiMo ASR 使用 chat completions 接口，音频会自动转为 base64';

  @override
  String get noNotesToExport => '选中的视频没有笔记';

  @override
  String get switchToTextImport => '切换到导入原文';

  @override
  String get switchToVideoImport => '切换到导入视频';

  @override
  String get selectExportContent => '选择导出内容';

  @override
  String get exportNotesDesc => '导出 AI 生成的 Markdown 笔记';

  @override
  String get exportTranscriptsDesc => '导出语音转写的原始文本';

  @override
  String get exportAllDesc => '同时导出笔记和转写原文';

  @override
  String get error => '错误';

  @override
  String get networkError => '网络连接失败';

  @override
  String get timeoutError => '请求超时';

  @override
  String get invalidApiKey => 'API Key 无效';

  @override
  String get permissionDenied => '权限不足';

  @override
  String get connectionTimeout => '连接超时，请检查网络';

  @override
  String get connectionError => '无法连接到服务器，请检查 API 地址';

  @override
  String get htmlResponse => 'API 返回了 HTML 页面，请检查 API 地址';

  @override
  String get checkConfig => '请检查：';

  @override
  String get checkApiKey => 'API Key 是否正确';

  @override
  String get checkApiUrl => 'API 地址格式是否正确';

  @override
  String get checkNetwork => '网络连接是否正常';

  @override
  String get currentConfig => '当前配置：';

  @override
  String get videoPlaybackError => '无法播放此视频';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => '課記';

  @override
  String get home => '主頁';

  @override
  String get settings => '設定';

  @override
  String get import => '匯入';

  @override
  String get importVideo => '匯入影片';

  @override
  String get importText => '匯入原文';

  @override
  String get batchExport => '批次匯出';

  @override
  String get batchDelete => '批次刪除';

  @override
  String get selectAll => '全選';

  @override
  String get deselectAll => '取消全選';

  @override
  String selectedItems(Object count) {
    return '已選擇 $count 項';
  }

  @override
  String get exportNotes => '匯出筆記';

  @override
  String get exportTranscripts => '匯出轉寫原文';

  @override
  String get exportAll => '全部匯出';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確定';

  @override
  String get save => '儲存';

  @override
  String get retry => '重試';

  @override
  String get close => '關閉';

  @override
  String get noVideos => '暫無影片';

  @override
  String get importVideosHint => '點擊右上角 + 匯入影片';

  @override
  String get pending => '等待處理';

  @override
  String processing(Object progress) {
    return '處理中 $progress%';
  }

  @override
  String get done => '完成';

  @override
  String get failed => '失敗';

  @override
  String get viewNotes => '檢視筆記';

  @override
  String get updatePath => '更新路徑';

  @override
  String get confirmDelete => '確認刪除';

  @override
  String get confirmDeleteMessage => '確定要刪除這個影片嗎？相關的筆記也會被刪除。';

  @override
  String get confirmBatchDelete => '確認批次刪除';

  @override
  String confirmBatchDeleteMessage(Object count) {
    return '確定要刪除選中的 $count 個影片嗎？相關的筆記也會被刪除。';
  }

  @override
  String get pathUpdated => '路徑已更新';

  @override
  String get updateFailed => '更新失敗';

  @override
  String get deleteFailed => '刪除失敗';

  @override
  String get retryFailed => '重試失敗';

  @override
  String get asrSettings => '語音轉寫 (ASR)';

  @override
  String get llmSettings => '筆記生成 (LLM)';

  @override
  String get otherSettings => '其他設定';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiBaseUrl => 'API 位址';

  @override
  String get model => '模型';

  @override
  String get saveSettings => '儲存設定';

  @override
  String get testConnection => '測試連線';

  @override
  String get testing => '測試中...';

  @override
  String get connectionSuccess => '連線成功';

  @override
  String get connectionFailed => '連線測試失敗';

  @override
  String get pleaseEnterApiKey => '請先輸入 API Key';

  @override
  String get settingsSaved => '設定已儲存';

  @override
  String get enableAudioChunking => '啟用長音訊分段';

  @override
  String get enableAudioChunkingHint => '長音訊自動在靜音處切分後轉寫';

  @override
  String get appearance => '外觀';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get lightMode => '淺色模式';

  @override
  String get darkMode => '深色模式';

  @override
  String get transcriptOriginal => '轉寫原文';

  @override
  String get noTranscript => '暫無轉寫內容';

  @override
  String get transcriptWillAppear => '影片處理完成後會顯示轉寫原文';

  @override
  String get transcriptParseFailed => '轉寫內容解析失敗';

  @override
  String get copyNote => '複製筆記';

  @override
  String get noteCopied => '筆記已複製到剪貼簿';

  @override
  String get exportNote => '匯出筆記';

  @override
  String get exportTranscript => '匯出轉寫';

  @override
  String get regenerate => '重新生成';

  @override
  String get exportFailed => '匯出失敗';

  @override
  String get regenerateFailed => '重新生成失敗';

  @override
  String get noteRegenerated => '筆記已重新生成';

  @override
  String get generating => '生成中...';

  @override
  String get generateNote => '生成筆記';

  @override
  String get noNote => '暫無筆記';

  @override
  String get selectVideoFiles => '選擇影片檔案';

  @override
  String get selectTextFiles => '選擇原文檔案';

  @override
  String supportedFormats(Object formats) {
    return '支援 $formats';
  }

  @override
  String get selectFiles => '選擇檔案';

  @override
  String selectedFiles(Object count) {
    return '已選擇 $count 個檔案';
  }

  @override
  String get importAfterSelect => '匯入後立即開始處理';

  @override
  String get importTextAfterSelect => '匯入後立即生成筆記';

  @override
  String importVideos(Object count) {
    return '匯入 $count 個影片';
  }

  @override
  String importTexts(Object count) {
    return '匯入 $count 個原文';
  }

  @override
  String get importing => '匯入中...';

  @override
  String importSuccess(Object count) {
    return '成功匯入 $count 個檔案';
  }

  @override
  String get importFailed => '匯入失敗';

  @override
  String get configIncomplete => '設定不完整';

  @override
  String get asrConfigIncomplete => 'ASR API Key 未設定';

  @override
  String get llmConfigIncomplete => 'LLM API Key 未設定';

  @override
  String get importOnly => '只匯入';

  @override
  String get importOnlyHint => 'API 設定不完整，無法自動處理。是否只匯入？';

  @override
  String get videoProcessorBusy => '已有影片正在處理中';

  @override
  String get batchExportFailed => '批次匯出失敗';

  @override
  String exportedTo(Object count, Object path) {
    return '已匯出 $count 個檔案到: $path';
  }

  @override
  String get siliconflow => 'SiliconFlow';

  @override
  String get xiaomiMiMo => '小米 MiMo';

  @override
  String get openaiWhisper => 'OpenAI Whisper';

  @override
  String get custom => '自訂';

  @override
  String get presetProvider => '服務商預設';

  @override
  String get asrPresetHint =>
      '小米 MiMo ASR 使用 chat completions 介面，音訊會自動轉為 base64';

  @override
  String get noNotesToExport => '選中的影片沒有筆記';

  @override
  String get switchToTextImport => '切換到匯入原文';

  @override
  String get switchToVideoImport => '切換到匯入影片';

  @override
  String get selectExportContent => '選擇匯出內容';

  @override
  String get exportNotesDesc => '匯出 AI 生成的 Markdown 筆記';

  @override
  String get exportTranscriptsDesc => '匯出語音轉寫的原始文字';

  @override
  String get exportAllDesc => '同時匯出筆記和轉寫原文';

  @override
  String get error => '錯誤';

  @override
  String get networkError => '網路連線失敗';

  @override
  String get timeoutError => '請求逾時';

  @override
  String get invalidApiKey => 'API Key 無效';

  @override
  String get permissionDenied => '權限不足';

  @override
  String get connectionTimeout => '連線逾時，請檢查網路';

  @override
  String get connectionError => '無法連線到伺服器，請檢查 API 位址';

  @override
  String get htmlResponse => 'API 回傳了 HTML 頁面，請檢查 API 位址';

  @override
  String get checkConfig => '請檢查：';

  @override
  String get checkApiKey => 'API Key 是否正確';

  @override
  String get checkApiUrl => 'API 位址格式是否正確';

  @override
  String get checkNetwork => '網路連線是否正常';

  @override
  String get currentConfig => '當前設定：';

  @override
  String get videoPlaybackError => '無法播放此影片';
}
