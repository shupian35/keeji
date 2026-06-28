// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Keeji';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get import => 'Import';

  @override
  String get importVideo => 'Import Video';

  @override
  String get importText => 'Import Text';

  @override
  String get batchExport => 'Batch Export';

  @override
  String get batchDelete => 'Batch Delete';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String selectedItems(Object count) {
    return 'Selected $count items';
  }

  @override
  String get exportNotes => 'Export Notes';

  @override
  String get exportTranscripts => 'Export Transcripts';

  @override
  String get exportAll => 'Export All';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get noVideos => 'No Videos';

  @override
  String get importVideosHint => 'Click + to import videos';

  @override
  String get pending => 'Pending';

  @override
  String processing(Object progress) {
    return 'Processing $progress%';
  }

  @override
  String get done => 'Done';

  @override
  String get failed => 'Failed';

  @override
  String get viewNotes => 'View Notes';

  @override
  String get updatePath => 'Update Path';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this video? Related notes will also be deleted.';

  @override
  String get confirmBatchDelete => 'Confirm Batch Delete';

  @override
  String confirmBatchDeleteMessage(Object count) {
    return 'Are you sure you want to delete $count selected videos? Related notes will also be deleted.';
  }

  @override
  String get pathUpdated => 'Path updated';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get retryFailed => 'Retry failed';

  @override
  String get asrSettings => 'Speech Recognition (ASR)';

  @override
  String get llmSettings => 'Note Generation (LLM)';

  @override
  String get otherSettings => 'Other Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get apiBaseUrl => 'API Base URL';

  @override
  String get model => 'Model';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get testing => 'Testing...';

  @override
  String get connectionSuccess => 'Connection successful';

  @override
  String get connectionFailed => 'Connection test failed';

  @override
  String get pleaseEnterApiKey => 'Please enter API Key';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get enableAudioChunking => 'Enable Audio Chunking';

  @override
  String get enableAudioChunkingHint =>
      'Automatically split long audio at silence points';

  @override
  String get appearance => 'Appearance';

  @override
  String get followSystem => 'Follow System';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get transcriptOriginal => 'Transcript';

  @override
  String get noTranscript => 'No transcript content';

  @override
  String get transcriptWillAppear =>
      'Transcript will appear after video processing';

  @override
  String get transcriptParseFailed => 'Transcript parse failed';

  @override
  String get copyNote => 'Copy Note';

  @override
  String get noteCopied => 'Note copied to clipboard';

  @override
  String get exportNote => 'Export Note';

  @override
  String get exportTranscript => 'Export Transcript';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get regenerateFailed => 'Regenerate failed';

  @override
  String get noteRegenerated => 'Note regenerated';

  @override
  String get generating => 'Generating...';

  @override
  String get generateNote => 'Generate Note';

  @override
  String get noNote => 'No Note';

  @override
  String get selectVideoFiles => 'Select Video Files';

  @override
  String get selectTextFiles => 'Select Text Files';

  @override
  String supportedFormats(Object formats) {
    return 'Supported: $formats';
  }

  @override
  String get selectFiles => 'Select Files';

  @override
  String selectedFiles(Object count) {
    return 'Selected $count files';
  }

  @override
  String get importAfterSelect => 'Start processing after import';

  @override
  String get importTextAfterSelect => 'Generate notes after import';

  @override
  String importVideos(Object count) {
    return 'Import $count videos';
  }

  @override
  String importTexts(Object count) {
    return 'Import $count texts';
  }

  @override
  String get importing => 'Importing...';

  @override
  String importSuccess(Object count) {
    return 'Successfully imported $count files';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get configIncomplete => 'Configuration Incomplete';

  @override
  String get asrConfigIncomplete => 'ASR API Key not configured';

  @override
  String get llmConfigIncomplete => 'LLM API Key not configured';

  @override
  String get importOnly => 'Import Only';

  @override
  String get importOnlyHint =>
      'API configuration is incomplete. Import without processing?';

  @override
  String get videoProcessorBusy => 'A video is already being processed';

  @override
  String get batchExportFailed => 'Batch export failed';

  @override
  String exportedTo(Object count, Object path) {
    return 'Exported $count files to: $path';
  }

  @override
  String get siliconflow => 'SiliconFlow';

  @override
  String get xiaomiMiMo => 'Xiaomi MiMo';

  @override
  String get openaiWhisper => 'OpenAI Whisper';

  @override
  String get custom => 'Custom';

  @override
  String get presetProvider => 'Provider Preset';

  @override
  String get asrPresetHint =>
      'Xiaomi MiMo ASR uses chat completions API with base64 audio';

  @override
  String get noNotesToExport => 'Selected videos have no notes';

  @override
  String get switchToTextImport => 'Switch to Text Import';

  @override
  String get switchToVideoImport => 'Switch to Video Import';

  @override
  String get selectExportContent => 'Select Export Content';

  @override
  String get exportNotesDesc => 'Export AI-generated Markdown notes';

  @override
  String get exportTranscriptsDesc => 'Export speech-to-text original content';

  @override
  String get exportAllDesc => 'Export both notes and transcripts';

  @override
  String get error => 'Error';

  @override
  String get networkError => 'Network connection failed';

  @override
  String get timeoutError => 'Request timeout';

  @override
  String get invalidApiKey => 'Invalid API Key';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get connectionTimeout => 'Connection timeout, check network';

  @override
  String get connectionError => 'Cannot connect to server, check API URL';

  @override
  String get htmlResponse => 'API returned HTML page, check API URL';

  @override
  String get checkConfig => 'Please check:';

  @override
  String get checkApiKey => 'API Key is correct';

  @override
  String get checkApiUrl => 'API URL format is correct';

  @override
  String get checkNetwork => 'Network connection is normal';

  @override
  String get currentConfig => 'Current configuration:';

  @override
  String get videoPlaybackError => 'Unable to play this video';
}
