//
//  ASRViewController.m
//  SDKTester
//
//  Created by baidu on 16/1/27.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "AIRobotManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSWakeupDefines.h"
#import "BDSWakeupParameters.h"
#import "BDSEventManager.h"
#import "BDRecognizerViewController.h"
#import "BDVRSettings.h"
#import "fcntl.h"
#import "AudioInputStream.h"


//#error "请在官网新建应用，配置包名，并在此填写应用的 api key, secret key, appid(即appcode)"
const NSString* API_KEY = @"7u3j3436jyLcmGvYiuMs2eu0";
const NSString* SECRET_KEY = @"WB51ljf7ddZpN1bvTGv7SULvDZvcsPNh";
const NSString* APP_ID = @"15950856";

static AIRobotManager* _instance = nil;

@interface AIRobotManager () <BDSClientASRDelegate, BDSClientWakeupDelegate, BDRecognizerViewDelegate>

@property (nonatomic, strong) BDSEventManager *asrEventManager;
@property (nonatomic, strong) BDSEventManager *wakeupEventManager;
@property (nonatomic, strong) UIActionSheet *moreActionSheet;

@property (nonatomic, assign) BOOL continueToVR;
@property (nonatomic, strong) NSFileHandle *fileHandler;
@property (nonatomic, strong) BDRecognizerViewController *recognizerViewController;
@property (nonatomic, assign) TBDVoiceRecognitionOfflineEngineType curOfflineEngineType;

@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, assign) BOOL longPressFlag;
@property (nonatomic, assign) BOOL touchUpFlag;
@property (nonatomic, assign) BOOL longSpeechFlag;

//是否唤醒
@property (nonatomic,assign) __block BOOL isWakeUp;

@end

@implementation AIRobotManager

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        [_instance initManager];//初始化
    }) ;
    return _instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [AIRobotManager shareInstance] ;
}

-(id) copyWithZone:(NSZone *)zone
{
    return [AIRobotManager shareInstance] ;//return _instance;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [AIRobotManager shareInstance] ;
}

-(void)initManager{
    self.isWakeUp = NO;
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    self.wakeupEventManager = [BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME];

    NSLog(@"Current SDK version: %@", [self.asrEventManager libver]);

    self.continueToVR = NO;
    [[BDVRSettings getInstance] configBDVRClient];
    [self configVoiceRecognitionClient];
    [self loadOfflineEngine];
    [self startWakeup];

}

#pragma mark - UI Button

- (void)longPressTimerTriggered
{
    if (!self.touchUpFlag) {
        self.longPressFlag = YES;
        [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_VAD_ENABLE_LONG_PRESS];
    }
    [self.longPressTimer invalidate];
}

- (void)fileRecognition
{
    [self cleanLogUI];
    NSString* testFile = [[NSBundle mainBundle] pathForResource:@"16k_test" ofType:@"pcm"];
    [self.asrEventManager setParameter:testFile forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}

- (void)sdkUI
{
    [self cleanLogUI];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self configFileHandler];
    [self configRecognizerViewController];
    [self.recognizerViewController startVoiceRecognition];
}

- (void)startWakeup
{
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self cleanLogUI];
    [self configWakeupClient];
    [self.wakeupEventManager setParameter:nil forKey:BDS_WAKEUP_AUDIO_FILE_PATH];
    [self.wakeupEventManager setParameter:nil forKey:BDS_WAKEUP_AUDIO_INPUT_STREAM];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_LOAD_ENGINE];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_START];
}

- (void)stopWakeup
{
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_STOP];
    [self.wakeupEventManager sendCommand:BDS_WP_CMD_UNLOAD_ENGINE];
}

- (void)loadOfflineEngine
{
    [self cleanLogUI];
    [self configOfflineClient];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_LOAD_ENGINE];
}

- (void)unLoadOfflineEngine
{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_UNLOAD_ENGINE];
}

- (void)audioStreamRecognition
{
    [self cleanLogUI];
    AudioInputStream *stream = [[AudioInputStream alloc] init];
    [self.asrEventManager setParameter:stream forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    [self onInitializing];
}

- (void)longSpeechRecognition
{
    [self cleanLogUI];
    self.longSpeechFlag = YES;
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    [self voiceRecogButtonHelper];
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"map_startRecord" object:nil];
   
}

#pragma mark - UI Button Helper

- (void)cleanLogUI{
    
}

- (void)onInitializing
{
    
}

- (void)onStartWorking
{
    
}

- (void)onEnd
{
    self.longSpeechFlag = NO;
}

- (void)voiceRecogButtonHelper
{
    [self configFileHandler];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    [self onInitializing];
}

#pragma mark - MVoiceRecognitionClientDelegate

- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj {
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            [self.fileHandler writeData:(NSData *)aObj];
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: start vr, log: %@\n", logDic]];
            [self onStartWorking];
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            [self printLogTextView:@"CALLBACK: detect voice start point.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            [self printLogTextView:@"CALLBACK: detect voice end point.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
//            [SVProgressHUD showWithStatus:@"正在识别"];
//            [SVProgressHUD dismissWithDelay:5];
//            [self handleTempRegisitionWith:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: partial result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            if ([aObj isKindOfClass:[NSDictionary class]]) {
                [self handleTempRegisitionWith:aObj];
                
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"map_finishedRecord" object:nil];
            [self closeAction];
            if (!self.longSpeechFlag) {
                [self onEnd];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            [self printLogTextView:@"CALLBACK: user press cancel.\n"];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"EVoiceRecognitionClientWorkStatusError" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
            [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
            [self longSpeechRecognition];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            [self onEnd];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            
            [self printLogTextView:@"CALLBACK: offline engine loaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            [self printLogTextView:@"CALLBACK: offline engine unLoaded.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk 3-party data length: %lu\n", (unsigned long)[(NSData *)aObj length]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
            NSString *nlu = [[NSString alloc] initWithData:(NSData *)aObj encoding:NSUTF8StringEncoding];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk NLU data: %@\n", nlu]];
            NSLog(@"%@", nlu);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk end, sn: %@.\n", aObj]];
            if (!self.longSpeechFlag) {
                [self onEnd];
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK Feedback: %@\n", logDic]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            [self printLogTextView:@"CALLBACK: recorder closed.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"EVoiceRecognitionClientWorkStatusLongSpeechEnd" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
            [self printLogTextView:@"CALLBACK: Long Speech end.\n"];
            [self onEnd];
            break;
        }
        default:
            break;
    }
}

- (void)WakeupClientWorkStatus:(int)workStatus obj:(id)aObj
{
    switch (workStatus) {
        case EWakeupEngineWorkStatusStarted: {
            [self printLogTextView:@"WAKEUP CALLBACK: Started.\n"];
            break;
        }
        case EWakeupEngineWorkStatusStopped: {
            
            [self printLogTextView:@"WAKEUP CALLBACK: Stopped.\n"];
            break;
        }
        case EWakeupEngineWorkStatusLoaded: {
            [self printLogTextView:@"WAKEUP CALLBACK: Loaded.\n"];
            break;
        }
        case EWakeupEngineWorkStatusUnLoaded: {
            [self printLogTextView:@"WAKEUP CALLBACK: UnLoaded.\n"];
            break;
        }
        case EWakeupEngineWorkStatusTriggered: {
            [self printLogTextView:[NSString stringWithFormat:@"WAKEUP CALLBACK: Triggered - %@.\n", (NSString *)aObj]];
            if (self.continueToVR) {
                self.continueToVR = NO;
                
                [self.asrEventManager setParameter:aObj forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
                [self voiceRecogButtonHelper];
            }
            [self stopWakeup];
            [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:@"主人我在"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self longSpeechRecognition];
            });
            
            self.isWakeUp = YES;
            break;
        }
        case EWakeupEngineWorkStatusError: {
            [self printLogTextView:[NSString stringWithFormat:@"WAKEUP CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            break;
        }
        default:
            break;
    }
}

- (void)printLogTextView:(NSString *)logString
{
//    self.logTextView.text = [logString stringByAppendingString:_logTextView.text];
//    [self.logTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (NSDictionary *)parseLogToDic:(NSString *)logString
{
    NSArray *tmp = NULL;
    NSMutableDictionary *logDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *items = [logString componentsSeparatedByString:@"&"];
    for (NSString *item in items) {
        tmp = [item componentsSeparatedByString:@"="];
        if (tmp.count == 2) {
            [logDic setObject:tmp.lastObject forKey:tmp.firstObject];
        }
    }
    return logDic;
}

#pragma mark - BDRecognizerViewDelegate

- (void)onRecordDataArrived:(NSData *)recordData sampleRate:(int)sampleRate
{
    [self.fileHandler writeData:(NSData *)recordData];
}

- (void)onEndWithViews:(BDRecognizerViewController *)aBDRecognizerViewController withResult:(id)aResult
{
    if (aResult) {
        
    }
    [self.asrEventManager setDelegate:self];
}

#pragma mark - Private: Configuration

- (void)configVoiceRecognitionClient {
    //设置DEBUG_LOG的级别
    [self.asrEventManager setParameter:@(EVRDebugLogLevelTrace) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    //配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[API_KEY, SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    
    //开启提示音
//    [self.asrEventManager setParameter:@(EVRPlayToneAll) forKey:BDS_ASR_PLAY_TONE];
    //###4.3 唤醒辅助识别说明 如需要唤醒后立刻进行识别
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    
    //配置端点检测（二选一）
//    [self configModelVAD];
      [self configDNNMFE];
    
    // ---- 语义与标点 -----
    [self enableNLU];
    // ------------------------
}

- (void) enableNLU {
    // ---- 开启语义理解 -----
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    [self.asrEventManager setParameter:@"1536" forKey:BDS_ASR_PRODUCT_ID];
}

- (void)configModelVAD {
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (void)configDNNMFE {
    NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
    [self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
    NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
    [self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
    
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_MODEL_VAD];
    // MFE支持自定义静音时长
    [self.asrEventManager setParameter:@(51.f) forKey:BDS_ASR_MFE_MAX_SPEECH_PAUSE];
    [self.asrEventManager setParameter:@(50.f) forKey:BDS_ASR_MFE_MAX_WAIT_DURATION];
    
}

- (void)configWakeupClient {
    
    [self.wakeupEventManager setDelegate:self];
    [self.wakeupEventManager setParameter:APP_ID forKey:BDS_WAKEUP_APP_CODE];
    
    [self configWakeupSettings];
}

- (void)configWakeupSettings {
    NSString* dat = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    
    // 默认的唤醒词为"百度一下"，如需自定义唤醒词，请在 http://ai.baidu.com/tech/speech/wake 中评估并下载唤醒词，替换此参数
    NSString* words = [[NSBundle mainBundle] pathForResource:@"WakeUp" ofType:@"dat"];
    [self.wakeupEventManager setParameter:dat forKey:BDS_WAKEUP_DAT_FILE_PATH];
    [self.wakeupEventManager setParameter:words forKey:BDS_WAKEUP_WORDS_FILE_PATH];
}

- (void)configOfflineClient {
    
    // 离线仅可识别自定义语法规则下的词
    NSString* gramm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_gramm" ofType:@"dat"];;
    NSString* lm_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];;
//    NSString* wakeup_words_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_wakeup_words" ofType:@"dat"];;
//    [self.asrEventManager setDelegate:self];
//    [self.asrEventManager setParameter:APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
//    [self.asrEventManager setParameter:lm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH];
//    // 请在 (官网)[http://speech.baidu.com/asr] 参考模板定义语法，下载语法文件后，替换BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH参数
//    [self.asrEventManager setParameter:gramm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH];
//    [self.asrEventManager setParameter:wakeup_words_filepath forKey:BDS_ASR_OFFLINE_ENGINE_WAKEUP_WORDS_FILE_PATH];
    
    // 参数设置：识别策略为离在线并行
    [self.asrEventManager setParameter:@(EVR_STRATEGY_BOTH) forKey:BDS_ASR_STRATEGY];
    // 参数设置：离线识别引擎类型
    [self.asrEventManager setParameter:@(EVR_OFFLINE_ENGINE_GRAMMER) forKey:BDS_ASR_OFFLINE_ENGINE_TYPE];
    // 参数配置：命令词引擎语法文件路径。 请在 (官网)[http://speech.baidu.com/asr] 参考模板定义语法，下载语法文件后，替换BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH参数
    [self.asrEventManager setParameter:gramm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_GRAMMER_FILE_PATH];
    // 参数配置：命令词引擎语言模型文件路径
    [self.asrEventManager setParameter:lm_filepath forKey:BDS_ASR_OFFLINE_ENGINE_DAT_FILE_PATH];
    // 发送指令：加载离线引擎
    [self.asrEventManager sendCommand:BDS_ASR_CMD_LOAD_ENGINE];
    
}

- (void)configRecognizerViewController {
    BDRecognizerViewParamsObject *paramsObject = [[BDRecognizerViewParamsObject alloc] init];
    paramsObject.isShowTipAfterSilence = YES;
    paramsObject.isShowHelpButtonWhenSilence = NO;
    paramsObject.waitTime2ShowTip = 0.5;
    paramsObject.isHidePleaseSpeakSection = YES;
    paramsObject.disableCarousel = YES;
    self.recognizerViewController = [[BDRecognizerViewController alloc] initRecognizerViewControllerWithOrigin:CGPointMake(0, 200)
                                                                                                         theme:[BDTheme darkBlueTheme]
                                                                                              enableFullScreen:NO
                                                                                                  paramsObject:paramsObject
                                                                                                      delegate:self];
}

- (void)configFileHandler {
    self.fileHandler = [self createFileHandleWithName:@"recoder.pcm" isAppend:NO];
}

#pragma mark - Private: File

- (NSString *)getFilePath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths && [paths count]) {
        return [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    } else {
        return nil;
    }
}

- (NSFileHandle *)createFileHandleWithName:(NSString *)aFileName isAppend:(BOOL)isAppend {
    NSFileHandle *fileHandle = nil;
    NSString *fileName = [self getFilePath:aFileName];
    
    int fd = -1;
    if (fileName) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]&& !isAppend) {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        int flags = O_WRONLY | O_APPEND | O_CREAT;
        fd = open([fileName fileSystemRepresentation], flags, 0644);
    }
    
    if (fd != -1) {
        fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:YES];
    }
    
    return fileHandle;
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark - 执行命令
-(void)closeAction{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
    [self startWakeup];
    self.isWakeUp = NO;
}

-(void)action_closeAll{
    [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
    self.isWakeUp = NO;
    [self stopWakeup];
}

-(void)handleTempRegisitionWith:(NSDictionary *)dict{
    
    NSLog(@"%@",dict);
    NSArray *results = @[];
    if ([dict.allKeys containsObject:@"results_recognition"]) {
        results = dict[@"results_recognition"];
    }
    if (results.count>0) {
        NSString *str = [AppGeneral getSafeValueWith:results[0]];
        NSLog(@"识别完成 %@",str);
    }
    
}

@end
