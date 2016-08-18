//
//  ViewController.m
//  AudioHelpTest
//
//  Created by BJ.y on 16/8/16.
//  Copyright © 2016年 BJ.y. All rights reserved.
//

#import "ViewController.h"
#import "AudioHelper.h"
#import <AVFoundation/AVAudioPlayer.h>


#define KMaxTime 10
#define kRecordType 1
#define kSampleRate 8000.0
#define kBitRate 12800
#define DocumentDir()    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface ViewController ()<AVAudioPlayerDelegate>
@property (nonatomic, strong) AudioHelper *audioHelper;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *path;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSString *)toMillionSecondEndingStringWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    return [NSString stringWithFormat:@"%@.aac", [formatter stringFromDate:date]];
}

- (IBAction)didRecordButtonPressed:(id)sender {
    NSString *path = [DocumentDir()
                      stringByAppendingPathComponent:[self toMillionSecondEndingStringWithDate:[NSDate date]]];
    __autoreleasing NSError *error;
    [self.audioHelper startRecorderWithPath:path maxTime:KMaxTime error:&error];
    
    if (error) {
        NSLog(@"fail %@", error.localizedDescription);
    }
}

- (IBAction)didPlayButtonPressed:(id)sender {
    if (self.path.length > 0) {
        __autoreleasing NSError *error;
        self.audioPlayer  = [[AVAudioPlayer alloc]
                             initWithContentsOfURL:[NSURL fileURLWithPath:self.path]
                             error:&error];
        self.audioPlayer.delegate = self;
        if (error == nil && [self.audioPlayer prepareToPlay]) {
            [self.audioPlayer play];
        }
        else {
            NSLog(@"%@", error.localizedDescription);
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag{
    //播放结束时执行的动作
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
}


- (IBAction)didStopButtonPressed:(id)sender {
    [self.audioHelper stopRecord];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (AudioHelper *)audioHelper {
    if (!_audioHelper) {
        _audioHelper = [[AudioHelper alloc] init];
        __weak __typeof(&*self)weakSelf = self;
        [_audioHelper configRecorderSettingWithEncodingType:kRecordType
                                                 sampleRate:kSampleRate
                                                    bitRate:kBitRate];
        [_audioHelper
         configChannelPowerBlockWithPowerBlock:^(float peakPowerForChannel) {
             NSLog(@"power:%f", peakPowerForChannel);
         }
         progress:^(NSTimeInterval times) {
             NSLog(@"times:%lfs", times);
         }
         recordStopBlock:^(AudioStopType stopType, NSString *path, NSTimeInterval times) {
             weakSelf.path = path;
             NSLog(@"path:%@", path);
             NSLog(@"times:%f", times);
         }];
    }
    return _audioHelper;
}


@end
