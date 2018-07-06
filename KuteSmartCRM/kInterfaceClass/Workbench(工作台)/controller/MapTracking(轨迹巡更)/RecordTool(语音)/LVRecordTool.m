//
//  LVRecordTool.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/25.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#define LVRecordFileName @"lvRecord"

#import "LVRecordTool.h"
#import "VoiceConverter.h"

@interface LVRecordTool () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>



/**
 录音文件地址   .wav格式
 */
@property (nonatomic, strong) NSURL *recordFileUrl;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) AVAudioSession *session;

@end

@implementation LVRecordTool

- (void)startRecording {
    // 录音时停止播放 删除曾经生成的文件
    [self stopPlaying];
    [self destructionRecordingFile];
    
    // 真机环境下需要的代码
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    self.session = session;
    
    [self.recorder record];

//    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//    [timer fire];
//    self.timer = timer;
}

- (void)updateImage {
    
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    NSLog(@"%f", result);
    int no = 0;
    if (result > 0 && result <= 1.3) {
        no = 1;
    } else if (result > 1.3 && result <= 2) {
        no = 2;
    } else if (result > 2 && result <= 3.0) {
        no = 3;
    } else if (result > 3.0 && result <= 3.0) {
        no = 4;
    } else if (result > 5.0 && result <= 10) {
        no = 5;
    } else if (result > 10 && result <= 40) {
        no = 6;
    } else if (result > 40) {
        no = 7;
    }
    
    if ([self.delegate respondsToSelector:@selector(recordTool:didstartRecoring:)]) {
        [self.delegate recordTool:self didstartRecoring: no];
    }
}

#pragma mark - 停止录音
- (void)stopRecording {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
//        [self.timer invalidate];
        
        
        // 停止录音  并将wav格式转化为amr音频格式
        NSString *recordWAVPath = [self GetPathByFileName:LVRecordFileName ofType:@"wav"];
        NSString *recordAMRPath = [self GetPathByFileName:LVRecordFileName ofType:@"amr"];
        
        if ([VoiceConverter ConvertWavToAmr:recordWAVPath amrSavePath:recordAMRPath]) {
            NSLog(@"wav转amr成功");
        } else {
            NSLog(@"wav转amr失败");
        }
        
        
        
    }
    
}

- (void)playRecordingFile {
    // 播放时停止录音
    [self.recorder stop];
    
    // 正在播放就返回
    if ([self.player isPlaying]) return;

//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:NULL];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[self GetPathByFileName:LVRecordFileName ofType:@"wav"]] error:NULL];
    self.player.delegate = self;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}

- (void)stopPlaying {
    [self.player stop];
}

static id instance;
#pragma mark - 单例
+ (instancetype)sharedRecordTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

#pragma mark - 生成文件路径
- (NSString *)GetPathByFileName:(NSString *)fileName ofType:(NSString *)type {
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];;
    NSString *fileDirectory = [[[directory stringByAppendingPathComponent:fileName]
                                stringByAppendingPathExtension:type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}

#pragma mark - lazy init
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        
        self.recordFileUrl = [NSURL fileURLWithPath:[self GetPathByFileName:LVRecordFileName ofType:@"wav"]];
        
        // 3.设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        // 音频格式
        setting[AVFormatIDKey] = @(kAudioFormatLinearPCM);
        // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        setting[AVSampleRateKey] = @(8000);
        // 音频通道数 1 或 2
        setting[AVNumberOfChannelsKey] = @(1);
        // 线性音频的位深度  8、16、24、32
        setting[AVLinearPCMBitDepthKey] = @(16);
        //录音的质量
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityMin];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (void)destructionRecordingFile {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl) {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
        
    }
    NSURL *recordAMRUrl = [NSURL fileURLWithPath:[self GetPathByFileName:LVRecordFileName ofType:@"amr"]];

    if (recordAMRUrl) {
        
        [fileManager removeItemAtPath:[self GetPathByFileName:LVRecordFileName ofType:@"amr"] error:NULL];
    }
}

- (float)recordTotalTime {
    
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.recordFileUrl options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    return audioDurationSeconds;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        [self.session setActive:NO error:nil];
    }
}



@end
