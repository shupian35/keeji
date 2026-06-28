import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'课记'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @import.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import;

  /// No description provided for @importVideo.
  ///
  /// In zh, this message translates to:
  /// **'导入视频'**
  String get importVideo;

  /// No description provided for @importText.
  ///
  /// In zh, this message translates to:
  /// **'导入原文'**
  String get importText;

  /// No description provided for @batchExport.
  ///
  /// In zh, this message translates to:
  /// **'批量导出'**
  String get batchExport;

  /// No description provided for @batchDelete.
  ///
  /// In zh, this message translates to:
  /// **'批量删除'**
  String get batchDelete;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @selectedItems.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 项'**
  String selectedItems(Object count);

  /// No description provided for @exportNotes.
  ///
  /// In zh, this message translates to:
  /// **'导出笔记'**
  String get exportNotes;

  /// No description provided for @exportTranscripts.
  ///
  /// In zh, this message translates to:
  /// **'导出转写原文'**
  String get exportTranscripts;

  /// No description provided for @exportAll.
  ///
  /// In zh, this message translates to:
  /// **'全部导出'**
  String get exportAll;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @noVideos.
  ///
  /// In zh, this message translates to:
  /// **'暂无视频'**
  String get noVideos;

  /// No description provided for @importVideosHint.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角 + 导入视频'**
  String get importVideosHint;

  /// No description provided for @pending.
  ///
  /// In zh, this message translates to:
  /// **'等待处理'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In zh, this message translates to:
  /// **'处理中 {progress}%'**
  String processing(Object progress);

  /// No description provided for @done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @failed.
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failed;

  /// No description provided for @viewNotes.
  ///
  /// In zh, this message translates to:
  /// **'查看笔记'**
  String get viewNotes;

  /// No description provided for @updatePath.
  ///
  /// In zh, this message translates to:
  /// **'更新路径'**
  String get updatePath;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个视频吗？相关的笔记也会被删除。'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmBatchDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认批量删除'**
  String get confirmBatchDelete;

  /// No description provided for @confirmBatchDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 个视频吗？相关的笔记也会被删除。'**
  String confirmBatchDeleteMessage(Object count);

  /// No description provided for @pathUpdated.
  ///
  /// In zh, this message translates to:
  /// **'路径已更新'**
  String get pathUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败'**
  String get updateFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get deleteFailed;

  /// No description provided for @retryFailed.
  ///
  /// In zh, this message translates to:
  /// **'重试失败'**
  String get retryFailed;

  /// No description provided for @asrSettings.
  ///
  /// In zh, this message translates to:
  /// **'语音转写 (ASR)'**
  String get asrSettings;

  /// No description provided for @llmSettings.
  ///
  /// In zh, this message translates to:
  /// **'笔记生成 (LLM)'**
  String get llmSettings;

  /// No description provided for @otherSettings.
  ///
  /// In zh, this message translates to:
  /// **'其他设置'**
  String get otherSettings;

  /// No description provided for @apiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @apiBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'API 地址'**
  String get apiBaseUrl;

  /// No description provided for @model.
  ///
  /// In zh, this message translates to:
  /// **'模型'**
  String get model;

  /// No description provided for @saveSettings.
  ///
  /// In zh, this message translates to:
  /// **'保存设置'**
  String get saveSettings;

  /// No description provided for @testConnection.
  ///
  /// In zh, this message translates to:
  /// **'测试连接'**
  String get testConnection;

  /// No description provided for @testing.
  ///
  /// In zh, this message translates to:
  /// **'测试中...'**
  String get testing;

  /// No description provided for @connectionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'连接成功'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接测试失败'**
  String get connectionFailed;

  /// No description provided for @pleaseEnterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'请先输入 API Key'**
  String get pleaseEnterApiKey;

  /// No description provided for @settingsSaved.
  ///
  /// In zh, this message translates to:
  /// **'设置已保存'**
  String get settingsSaved;

  /// No description provided for @enableAudioChunking.
  ///
  /// In zh, this message translates to:
  /// **'启用长音频分段'**
  String get enableAudioChunking;

  /// No description provided for @enableAudioChunkingHint.
  ///
  /// In zh, this message translates to:
  /// **'长音频自动在静音处切分后转写'**
  String get enableAudioChunkingHint;

  /// No description provided for @appearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearance;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get darkMode;

  /// No description provided for @transcriptOriginal.
  ///
  /// In zh, this message translates to:
  /// **'转写原文'**
  String get transcriptOriginal;

  /// No description provided for @noTranscript.
  ///
  /// In zh, this message translates to:
  /// **'暂无转写内容'**
  String get noTranscript;

  /// No description provided for @transcriptWillAppear.
  ///
  /// In zh, this message translates to:
  /// **'视频处理完成后会显示转写原文'**
  String get transcriptWillAppear;

  /// No description provided for @transcriptParseFailed.
  ///
  /// In zh, this message translates to:
  /// **'转写内容解析失败'**
  String get transcriptParseFailed;

  /// No description provided for @copyNote.
  ///
  /// In zh, this message translates to:
  /// **'复制笔记'**
  String get copyNote;

  /// No description provided for @noteCopied.
  ///
  /// In zh, this message translates to:
  /// **'笔记已复制到剪贴板'**
  String get noteCopied;

  /// No description provided for @exportNote.
  ///
  /// In zh, this message translates to:
  /// **'导出笔记'**
  String get exportNote;

  /// No description provided for @exportTranscript.
  ///
  /// In zh, this message translates to:
  /// **'导出转写'**
  String get exportTranscript;

  /// No description provided for @regenerate.
  ///
  /// In zh, this message translates to:
  /// **'重新生成'**
  String get regenerate;

  /// No description provided for @exportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get exportFailed;

  /// No description provided for @regenerateFailed.
  ///
  /// In zh, this message translates to:
  /// **'重新生成失败'**
  String get regenerateFailed;

  /// No description provided for @noteRegenerated.
  ///
  /// In zh, this message translates to:
  /// **'笔记已重新生成'**
  String get noteRegenerated;

  /// No description provided for @generating.
  ///
  /// In zh, this message translates to:
  /// **'生成中...'**
  String get generating;

  /// No description provided for @generateNote.
  ///
  /// In zh, this message translates to:
  /// **'生成笔记'**
  String get generateNote;

  /// No description provided for @noNote.
  ///
  /// In zh, this message translates to:
  /// **'暂无笔记'**
  String get noNote;

  /// No description provided for @selectVideoFiles.
  ///
  /// In zh, this message translates to:
  /// **'选择视频文件'**
  String get selectVideoFiles;

  /// No description provided for @selectTextFiles.
  ///
  /// In zh, this message translates to:
  /// **'选择原文文件'**
  String get selectTextFiles;

  /// No description provided for @supportedFormats.
  ///
  /// In zh, this message translates to:
  /// **'支持 {formats}'**
  String supportedFormats(Object formats);

  /// No description provided for @selectFiles.
  ///
  /// In zh, this message translates to:
  /// **'选择文件'**
  String get selectFiles;

  /// No description provided for @selectedFiles.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个文件'**
  String selectedFiles(Object count);

  /// No description provided for @importAfterSelect.
  ///
  /// In zh, this message translates to:
  /// **'导入后立即开始处理'**
  String get importAfterSelect;

  /// No description provided for @importTextAfterSelect.
  ///
  /// In zh, this message translates to:
  /// **'导入后立即生成笔记'**
  String get importTextAfterSelect;

  /// No description provided for @importVideos.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 个视频'**
  String importVideos(Object count);

  /// No description provided for @importTexts.
  ///
  /// In zh, this message translates to:
  /// **'导入 {count} 个原文'**
  String importTexts(Object count);

  /// No description provided for @importing.
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get importing;

  /// No description provided for @importSuccess.
  ///
  /// In zh, this message translates to:
  /// **'成功导入 {count} 个文件'**
  String importSuccess(Object count);

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailed;

  /// No description provided for @configIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'配置不完整'**
  String get configIncomplete;

  /// No description provided for @asrConfigIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'ASR API Key 未配置'**
  String get asrConfigIncomplete;

  /// No description provided for @llmConfigIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'LLM API Key 未配置'**
  String get llmConfigIncomplete;

  /// No description provided for @importOnly.
  ///
  /// In zh, this message translates to:
  /// **'只导入'**
  String get importOnly;

  /// No description provided for @importOnlyHint.
  ///
  /// In zh, this message translates to:
  /// **'API 配置不完整，无法自动处理。是否只导入？'**
  String get importOnlyHint;

  /// No description provided for @videoProcessorBusy.
  ///
  /// In zh, this message translates to:
  /// **'已有视频正在处理中'**
  String get videoProcessorBusy;

  /// No description provided for @batchExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量导出失败'**
  String get batchExportFailed;

  /// No description provided for @exportedTo.
  ///
  /// In zh, this message translates to:
  /// **'已导出 {count} 个文件到: {path}'**
  String exportedTo(Object count, Object path);

  /// No description provided for @siliconflow.
  ///
  /// In zh, this message translates to:
  /// **'SiliconFlow'**
  String get siliconflow;

  /// No description provided for @xiaomiMiMo.
  ///
  /// In zh, this message translates to:
  /// **'小米 MiMo'**
  String get xiaomiMiMo;

  /// No description provided for @openaiWhisper.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI Whisper'**
  String get openaiWhisper;

  /// No description provided for @custom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get custom;

  /// No description provided for @presetProvider.
  ///
  /// In zh, this message translates to:
  /// **'服务商预设'**
  String get presetProvider;

  /// No description provided for @asrPresetHint.
  ///
  /// In zh, this message translates to:
  /// **'小米 MiMo ASR 使用 chat completions 接口，音频会自动转为 base64'**
  String get asrPresetHint;

  /// No description provided for @noNotesToExport.
  ///
  /// In zh, this message translates to:
  /// **'选中的视频没有笔记'**
  String get noNotesToExport;

  /// No description provided for @switchToTextImport.
  ///
  /// In zh, this message translates to:
  /// **'切换到导入原文'**
  String get switchToTextImport;

  /// No description provided for @switchToVideoImport.
  ///
  /// In zh, this message translates to:
  /// **'切换到导入视频'**
  String get switchToVideoImport;

  /// No description provided for @selectExportContent.
  ///
  /// In zh, this message translates to:
  /// **'选择导出内容'**
  String get selectExportContent;

  /// No description provided for @exportNotesDesc.
  ///
  /// In zh, this message translates to:
  /// **'导出 AI 生成的 Markdown 笔记'**
  String get exportNotesDesc;

  /// No description provided for @exportTranscriptsDesc.
  ///
  /// In zh, this message translates to:
  /// **'导出语音转写的原始文本'**
  String get exportTranscriptsDesc;

  /// No description provided for @exportAllDesc.
  ///
  /// In zh, this message translates to:
  /// **'同时导出笔记和转写原文'**
  String get exportAllDesc;

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// No description provided for @networkError.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In zh, this message translates to:
  /// **'请求超时'**
  String get timeoutError;

  /// No description provided for @invalidApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key 无效'**
  String get invalidApiKey;

  /// No description provided for @permissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'权限不足'**
  String get permissionDenied;

  /// No description provided for @connectionTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接超时，请检查网络'**
  String get connectionTimeout;

  /// No description provided for @connectionError.
  ///
  /// In zh, this message translates to:
  /// **'无法连接到服务器，请检查 API 地址'**
  String get connectionError;

  /// No description provided for @htmlResponse.
  ///
  /// In zh, this message translates to:
  /// **'API 返回了 HTML 页面，请检查 API 地址'**
  String get htmlResponse;

  /// No description provided for @checkConfig.
  ///
  /// In zh, this message translates to:
  /// **'请检查：'**
  String get checkConfig;

  /// No description provided for @checkApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key 是否正确'**
  String get checkApiKey;

  /// No description provided for @checkApiUrl.
  ///
  /// In zh, this message translates to:
  /// **'API 地址格式是否正确'**
  String get checkApiUrl;

  /// No description provided for @checkNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络连接是否正常'**
  String get checkNetwork;

  /// No description provided for @currentConfig.
  ///
  /// In zh, this message translates to:
  /// **'当前配置：'**
  String get currentConfig;

  /// No description provided for @videoPlaybackError.
  ///
  /// In zh, this message translates to:
  /// **'无法播放此视频'**
  String get videoPlaybackError;

  /// No description provided for @playbackSpeed.
  ///
  /// In zh, this message translates to:
  /// **'播放速度'**
  String get playbackSpeed;

  /// No description provided for @speed05x.
  ///
  /// In zh, this message translates to:
  /// **'0.5x'**
  String get speed05x;

  /// No description provided for @speed075x.
  ///
  /// In zh, this message translates to:
  /// **'0.75x'**
  String get speed075x;

  /// No description provided for @speed1x.
  ///
  /// In zh, this message translates to:
  /// **'1x'**
  String get speed1x;

  /// No description provided for @speed125x.
  ///
  /// In zh, this message translates to:
  /// **'1.25x'**
  String get speed125x;

  /// No description provided for @speed15x.
  ///
  /// In zh, this message translates to:
  /// **'1.5x'**
  String get speed15x;

  /// No description provided for @speed2x.
  ///
  /// In zh, this message translates to:
  /// **'2x'**
  String get speed2x;

  /// No description provided for @volume.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volume;

  /// No description provided for @fullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In zh, this message translates to:
  /// **'退出全屏'**
  String get exitFullscreen;

  /// No description provided for @buffering.
  ///
  /// In zh, this message translates to:
  /// **'缓冲中...'**
  String get buffering;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
