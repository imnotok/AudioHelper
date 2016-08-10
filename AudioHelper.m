//
//  AudioHelper.m
//  AudioHelper
//
//  Created by BJ.y on 16/7/28.
//  Copyright © 2016年 BJ.y. All rights reserved.
//

#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioHelper()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSDictionary *recordSetting;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, copy) AudioHelpRecordProgress progress;
@property (nonatomic, copy) AudioHelpRecordStop recordStop;
@property (nonatomic, copy) AudioHelpRecordPower recordPower;
@property (nonatomic, assign) NSTimeInterval maxTime;
@property (nonatomic, copy) NSString *recordPath;
@property (nonatomic, assign) NSTimeInterval recordTimes;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) BOOL isAddObserver;
@end


@implementation AudioHelper

- (void)dealloc {
    [self _removerObserver];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isAddObserver = NO;
    }
    return self;
}

- (void)_removerObserver {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:AVAudioSessionInterruptionNotification object:nil];
    self.isAddObserver = NO;
}


- (void)_addObserver {
    if (self.isAddObserver) {
        [self _removerObserver];
    }
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleInterruption:)
     name:AVAudioSessionInterruptionNotification
     object:[AVAudioSession sharedInstance]];
    self.isAddObserver = YES;
}

- (void)handleInterruption:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type =
    [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan && notification.object == [AVAudioSession sharedInstance]) {
        // Handle AVAudioSessionInterruptionTypeBegan
        NSLog(@"AVAudioSessionInterruptionTypeBegan");
        [self _stopRecordWithStopType:AudioStopTypeInterrupt];
    } else {
        // Handle AVAudioSessionInterruptionTypeEnded
    }
}


#pragma mark - config recorder
- (void)configRecorderSettingWithEncodingType:(EncodingType)encodingType
                                   sampleRate:(float)rate
                                      bitRate:(int)bitRate {
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(encodingType == EncodingTypePCM) {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM]  forKey: AVFormatIDKey];//ID
    }
    else {
        NSNumber *formatObject;
        
        switch (encodingType) {
            case (EncodingTypeAAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (EncodingTypeALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (EncodingTypeIMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (EncodingTypeILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (EncodingTypeULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];//ID
    }
    
    [recordSettings setObject:[NSNumber numberWithFloat:rate] forKey: AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithFloat:bitRate] forKey:AVEncoderBitRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityMedium] forKey: AVEncoderAudioQualityKey];
    self.recordSetting = [recordSettings copy];
}


- (NSDictionary *)configRecorderSettingWithSampleRate:(float)rate
                                              bitRate:(int)bitRate {
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
    [recordSettings setObject:[NSNumber numberWithFloat:rate] forKey: AVSampleRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordSettings setObject:[NSNumber numberWithFloat:bitRate] forKey:AVEncoderBitRateKey];
    [recordSettings setObject:[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
    [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityMedium] forKey: AVEncoderAudioQualityKey];
    return  [recordSettings copy];
}



#pragma mark - stop record

- (void)_stopRecord {
    [self _resetRecordTimer];
    _isPause = NO;
    if (self.audioRecorder) {
        if (self.audioRecorder.isRecording) {
            [self.audioRecorder stop];
        }
        self.audioRecorder = nil;
    }
    
    __autoreleasing NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    NSLog(@"%@", error.localizedDescription);
    
    [self _removerObserver];
}

- (void)stopRecord {
    [self _stopRecordWithStopType:AudioStopTypeControl];
}

- (void)_stopRecordWithStopType:(AudioStopType)stopType {
    [self _stopRecord];
    NSString *recordPath = nil;
    if (_recordPath) {
        recordPath = [_recordPath copy];
        _recordPath = nil;
    }
    
    if (self.recordStop) {
        NSTimeInterval times = 0;
        if (recordPath) {
            times = [AudioHelper audioDurationWithPath:recordPath];
        }
        
        self.recordStop(stopType, recordPath, times);
    }
}

- (void)stopAndDeleteFile{
    _isPause = NO;
    [self _stopRecord];
    
    if (self.recordPath) {
        NSFileManager *fileManeger = [NSFileManager defaultManager];
        if ([fileManeger fileExistsAtPath:self.recordPath]) {
            NSError *error = nil;
            [fileManeger removeItemAtPath:self.recordPath error:&error];
            if (error) {
                NSLog(@"error :%@", error.description);
            }
            else {
                NSLog(@"del [%@]success", self.recordPath);
            }
        }
        self.recordPath = nil;
    }
}

#pragma mark -
- (void)configChannelPowerBlockWithPowerBlock:(AudioHelpRecordPower)power
                                     progress:(AudioHelpRecordProgress)progress
                              recordStopBlock:(AudioHelpRecordStop)stop{
    self.recordStop = stop;
    self.recordPower = power;
    self.progress = progress;
}


#pragma mark -
+ (NSTimeInterval)audioDurationWithPath:(NSString*)path {
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    CMTime audioDuration = audioAsset.duration;
    NSTimeInterval audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}


+ (void)audioAuthenticationWithAuthBlock:(AudioHelpAuthentication)authBlock {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession
         respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession
         performSelector:@selector(requestRecordPermission:)
         withObject:^(BOOL granted) {
             dispatch_async(dispatch_get_main_queue(), ^(void){
                 if (authBlock) {
                     authBlock(granted);
                 }
             });
         }];
    }
    
}

- (void)resumeRecord {
    _isPause = NO;
    if (_audioRecorder) {
        [_audioRecorder record];
    }
}

- (void)pauseRecord{
    _isPause = YES;
    if (_audioRecorder) {
        [_audioRecorder pause];
    }
}



- (void)startRecorderWithPath:(NSString *)savePath
                     settings:(NSDictionary  *)settings
                        error:(NSError *__autoreleasing *)error {
    
    __autoreleasing NSError *errorInfo = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&errorInfo];
    if (errorInfo && error) {
        *error = errorInfo;
        return;
    }
    [audioSession setActive:YES error:&errorInfo];
    
    if (errorInfo && error) {
        *error = errorInfo;
        return;
    }
    
    
    
    NSURL *url = [NSURL fileURLWithPath:savePath];
    AVAudioRecorder * recorder;
    recorder = [[ AVAudioRecorder alloc]
                initWithURL:url
                settings:settings
                error:&errorInfo];
    
    if (errorInfo && error) {
        *error = errorInfo;
        NSLog(@"%@", errorInfo.localizedDescription);
        return;
    }
    
    if ([recorder prepareToRecord] == YES){
        [recorder record];
    }
}

- (void)startRecorderWithPath:(NSString *)savePath
                      maxTime:(NSTimeInterval)maxTime
                        error:(NSError *__autoreleasing *)error {
    [self _stopRecord];
    
    __autoreleasing NSError *errorInfo = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&errorInfo];
    if (errorInfo && error) {
        *error = errorInfo;
        return;
    }
    [audioSession setActive:YES error:&errorInfo];
    
    if (errorInfo && error) {
        *error = errorInfo;
        return;
    }
    
    
    if (self.recordSetting == nil) {
        NSDictionary *userInfo ;
        userInfo =  [NSDictionary
                     dictionaryWithObject:@"should invole configRecorderSettingWithEncodingType before recorder"
                     forKey:NSLocalizedDescriptionKey];
        
        if (error != nil) {
            *error  = [NSError errorWithDomain:@"AudioHelper" code:0 userInfo:userInfo];
        }
        return;
    }
    _recordPath = savePath;
    _maxTime = maxTime;
    
    NSURL *url = [NSURL fileURLWithPath:savePath];
    _audioRecorder = [[ AVAudioRecorder alloc]
                      initWithURL:url
                      settings:_recordSetting
                      error:&errorInfo];
    
    if (errorInfo && error) {
        *error = errorInfo;
        NSLog(@"%@", errorInfo.localizedDescription);
        return;
    }
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder recordForDuration:(NSTimeInterval) 160];
    
    if ([_audioRecorder prepareToRecord] == YES){
        [self _addObserver];
        [_audioRecorder record];
        if (_progress) {
            [self _resetRecordTimer];
            _recordTimer = [NSTimer
                            scheduledTimerWithTimeInterval:0.05
                            target:self selector:@selector(_timerTick)
                            userInfo:nil repeats:YES];
        }
        NSLog(@"recording");
    }
    else {
        NSLog(@"%@", errorInfo.localizedDescription);
        NSDictionary *userInfo ;
        userInfo =  [NSDictionary
                     dictionaryWithObject:@"prepareToRecord fail"
                     forKey:NSLocalizedDescriptionKey];
        
        if (error != nil) {
            *error  = [NSError errorWithDomain:@"AudioHelper" code:0 userInfo:userInfo];
        }
    }
}


#pragma mark - Timer

- (void)_resetRecordTimer {
    if (!_recordTimer)
        return;
    
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
}

- (void)_timerTick {
    if (!_audioRecorder)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_audioRecorder updateMeters];
        
        NSTimeInterval recordTimes = _audioRecorder.currentTime;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_progress && !_isPause) {
                _progress(recordTimes);
            }
        });
        
        float peakPower = [_audioRecorder averagePowerForChannel:0];
        double ALPHA = 0.015;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新扬声器
            if (_recordPower && !_isPause) {
                _recordPower(peakPowerForChannel);
            }
        });
        
        if (_maxTime > 0 && recordTimes > _maxTime) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _stopRecordWithStopType:AudioStopTypeMaxTime];
            });
        }
    });
}

@end
