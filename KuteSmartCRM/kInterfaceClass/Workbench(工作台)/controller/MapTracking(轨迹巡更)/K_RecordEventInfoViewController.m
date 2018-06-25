//
//  K_RecordEventInfoViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/25.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_RecordEventInfoViewController.h"
#import "LVRecordTool.h"

@interface K_RecordEventInfoViewController ()

/**
 记录事件text
 */
@property (weak, nonatomic) IBOutlet UITextView *recordText;

/**
 记录事件 按住说话
 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
/**
 记录事件 播放录音
 */
@property (weak, nonatomic) IBOutlet UIButton *playRecordBtn;

/**
 录音工具
 */
@property (nonatomic, strong) LVRecordTool *recordTool;


@end

@implementation K_RecordEventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackButton];
    self.title = @"事件记录";
    
    // 初始化录音工具
    self.recordTool = [LVRecordTool sharedRecordTool];
    
    [self drawSubView];
}

- (void)drawSubView {
    // 描述
    self.recordText.layer.borderWidth = 1.0f;
    self.recordText.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.recordText.layer.cornerRadius = 5.f;
    self.recordText.layer.masksToBounds = YES;
    
    // 语音按钮
    self.recordBtn.layer.cornerRadius = 5.f;
    self.recordBtn.layer.masksToBounds = YES;
    
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    
    // 语音播放
    self.playRecordBtn.layer.cornerRadius = 5.f;
    self.playRecordBtn.layer.masksToBounds = YES;
    [self.playRecordBtn addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 录音按钮
// 按下
- (void)recordBtnDidTouchDown:(UIButton *)recordBtn {
    [self.recordTool startRecording];
}

// 点击
- (void)recordBtnDidTouchUpInside:(UIButton *)recordBtn {
    double currentTime = self.recordTool.recorder.currentTime;
    NSLog(@"%lf", currentTime);
    if (currentTime < 2) {
        
        [K_GlobalUtil HUDShowMessage:@"说话时间太短" addedToView:self.view];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self.recordTool stopRecording];
            [self.recordTool destructionRecordingFile];
        });
    } else {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self.recordTool stopRecording];
        });
        
        [K_GlobalUtil HUDShowMessage:@"已成功录音" addedToView:self.view];
    }
}

// 从按钮上移除
- (void)recordBtnDidTouchDragExit:(UIButton *)recordBtn {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.recordTool stopRecording];
        [self.recordTool destructionRecordingFile];
        
        [K_GlobalUtil HUDShowMessage:@"已取消录音" addedToView:self.view];
    });
}

#pragma mark - 播放按钮
- (void)playClick {
    [self.recordTool playRecordingFile];
}


- (void)dealloc {
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
    
}


@end
