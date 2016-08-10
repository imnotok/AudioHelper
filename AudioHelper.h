//
//  AudioHelper.h
//  AudioHelper
//
//  Created by BJ.y on 16/7/28.
//  Copyright © 2016年 BJ.y. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AudioStopType) {
    AudioStopTypeInterrupt = 1, //Interrupted by call
    AudioStopTypeMaxTime = 2, //have reached the max time
    AudioStopTypeControl = 3  //control
};


typedef void(^AudioHelpRecordProgress)(NSTimeInterval times);
typedef void(^AudioHelpRecordStop)(AudioStopType stopType, NSString *path, NSTimeInterval times);
typedef void(^AudioHelpRecordPower)(float peakPowerForChannel);
typedef void(^AudioHelpAuthentication)(BOOL isGranted);



typedef NS_ENUM(NSInteger, EncodingType) {
    EncodingTypeAAC = 1,
    EncodingTypeALAC = 2,
    EncodingTypeIMA4 = 3,
    EncodingTypeILBC = 4,
    EncodingTypeULAW = 5,
    EncodingTypePCM = 6
};

@interface AudioHelper : NSObject


/**
 *  start recording
 *
 *  @param savePath the recording save to
 *  @param maxTime  the max time , when the duration of the audio, it will stop recording
 *  @param error    error description
 */
- (void)startRecorderWithPath:(NSString *)savePath
                      maxTime:(NSTimeInterval)maxTime
                        error:(NSError **)error;

/**
 *  config recording setting
 *
 *  @param encodingType audio type
 *  @param rate         sample rate
 *  @param bitRate      bit rate
 */
- (void)configRecorderSettingWithEncodingType:(EncodingType)encodingType
                                   sampleRate:(float)rate
                                      bitRate:(int)bitRate;

/**
 *  config block
 *
 *  @param power    power block
 *  @param progress progress block
 *  @param stop     comoletion block
 */
- (void)configChannelPowerBlockWithPowerBlock:(AudioHelpRecordPower)power
                                     progress:(AudioHelpRecordProgress)progress
                              recordStopBlock:(AudioHelpRecordStop)stop;

/**
 *  resume recording
 */
-(void)resumeRecord;

/**
 *  pause recording
 */
- (void)pauseRecord;

/**
 *  stop recording
 */
- (void)stopRecord;

/**
 *  stop recording and delete the temp file
 */
- (void)stopAndDeleteFile;

/**
 *  calculate the length of the recording.
 *
 *  @param path the path of the audio file
 *
 *  @return the duration of the audio file
 */
+ (NSTimeInterval)audioDurationWithPath:(NSString*)path;

/**
 *  check if application has access to microphone
 *
 *  @param authBlock completion
 */
+ (void)audioAuthenticationWithAuthBlock:(AudioHelpAuthentication)authBlock;
@end
