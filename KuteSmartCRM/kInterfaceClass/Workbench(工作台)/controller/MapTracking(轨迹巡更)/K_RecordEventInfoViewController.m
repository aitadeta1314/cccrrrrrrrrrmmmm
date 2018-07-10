//
//  K_RecordEventInfoViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/6/25.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_RecordEventInfoViewController.h"
#import "LVRecordTool.h"
#import "WN_CustomActionSheet.h"
#import "TZImagePickerController.h"
#import <QuartzCore/QuartzCore.h>
#import "MSSBrowseDefine.h"
#import <QiniuSDK.h>
#import "VoiceConverter.h"

/// 可选图片最大数量
#define MAXImageCount 3

@interface K_RecordEventInfoViewController ()<CustomActionSheetDelegate, TZImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, AVAudioPlayerDelegate>

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
 录音总时间
 */
@property (weak, nonatomic) IBOutlet UILabel *recordTotalTime;

/**
 语音播放imgView
 */
@property (nonatomic, strong) UIImageView *audioImgView;

/**
 录音工具
 */
@property (nonatomic, strong) LVRecordTool *recordTool;

/**
 图片collectionView
 */
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *statusArray;

/**
 上传者
 */
@property (weak, nonatomic) IBOutlet UILabel *uploader;

/**
 上传时间：标签
 */
@property (weak, nonatomic) IBOutlet UILabel *timeTag;

/**
 上传时间
 */
@property (weak, nonatomic) IBOutlet UILabel *uploadTime;

/**
 上传按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *uploderBtn;

/**
 sheet
 */
@property (nonatomic, strong) WN_CustomActionSheet *sheet;

/**
 图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageArray;
/**
 二进制(图片+语音)数组
 */
@property (nonatomic, strong) NSMutableArray *picVoiceDataArray;
/**
 picVoiceArray是否含有语音二进制
 */
@property (nonatomic, assign) BOOL isContainVoiceData;
/**
 保存七牛图片语音地址数组
 */
@property (nonatomic, strong) NSMutableArray *picVoiceUrlArray;
/**
 事件处理页面 保存图片地址
 */
@property (nonatomic, strong) NSMutableArray *pictureDataArr;

@end

@implementation K_RecordEventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackButton];
    
    self.title = self.isEventDispose ? @"事件处理" : @"事件上报";
    
    self.isContainVoiceData = NO;
    
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
    self.recordBtn.enabled = self.isEventDispose ? NO : YES;
    self.recordBtn.backgroundColor = self.isEventDispose ? RGBA(154, 154, 154, 1) : NavigationBarBGColor;
    self.recordBtn.layer.cornerRadius = 5.f;
    self.recordBtn.layer.masksToBounds = YES;
    
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(recordBtnDidTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    
    // 语音播放
    [self.playRecordBtn addSubview:self.audioImgView];
    self.playRecordBtn.layer.cornerRadius = 3.f;
    self.playRecordBtn.layer.masksToBounds = YES;
    self.playRecordBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.playRecordBtn setBackgroundColor: RGBA(235, 235, 235, 1)];
    self.playRecordBtn.layer.borderWidth = .5f;
    [self.playRecordBtn addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    
    //
    self.recordTotalTime.text = @"0''";
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((CGRectGetWidth(self.imageCollectionView.frame)-30)/3, CGRectGetWidth(self.imageCollectionView.frame)/3);
    
    [self.imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    // 紧急状态
    for (UIButton *btn in self.statusArray) {
        [btn setImage:[[UIImage imageNamed:@"未选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [btn setImage:[[UIImage imageNamed:@"选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        [btn setImage:[[UIImage imageNamed:@"选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    
    /// 上传者
    self.uploader.text = KDISPLAYNAME;
    self.uploader.text = self.isEventDispose ? self.eventData[@"displayName"] : KDISPLAYNAME;
    
    /// 上传按钮
    self.uploderBtn.layer.cornerRadius = 40.f;
    self.uploderBtn.layer.masksToBounds = YES;
    
    
    /// 是事件处理页面
    if (self.isEventDispose) {
        
        [self eventDisposeMethod];
    }
    
}


/**
 事件处理 / 事件详情
 */
- (void)eventDisposeMethod {
    
    self.recordText.text = self.eventData[@"textDescription"];
    self.recordText.editable = NO;  // 不能编辑
    
    
    /// 图片
    for (NSInteger i = 0; i < 3; i ++) {
        NSString *key = [NSString stringWithFormat:@"pictureDescription%ld", i+1];
        if ([self.eventData[key] isValidString]) {
            [self.pictureDataArr addObject:self.eventData[key]];
        }
    }
    [self.imageCollectionView reloadData];
    
    /// 紧急状态
    for (UIButton *btn in self.statusArray) {
        if ([self.eventData[@"urgentStatus"] isEqualToString:@"0"]) {
            if (btn.tag == 111) {
                btn.selected = YES;
            }
        } else if ([self.eventData[@"urgentStatus"] isEqualToString:@"1"]) {
            if (btn.tag == 222) {
                btn.selected = YES;
            }
        } else {
            if (btn.tag == 333) {
                btn.selected = YES;
            }
        }
        btn.userInteractionEnabled = NO;
    }
    
    // 上传时间
    self.uploadTime.text = self.eventData[@"createTime"];
    self.timeTag.hidden = NO;
    self.uploadTime.hidden = NO;

    // 上传按钮
    [self.uploderBtn setTitle:@"处理" forState:UIControlStateNormal];
    if (![self.eventData[@"employeeNumber"] isEqualToString:KUSERNAME]) {
        // 不是本人上报 没有权限处理 故隐藏处理按钮
        self.uploderBtn.hidden = YES;
    }
    
    
    
    /// 录音下载
    if ([self.eventData[@"speechDescription"] isValidString]) {
        
        NSData *voiceData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.eventData[@"speechDescription"]]];
        NSString *fileDirectory = [self GetPathByFileName:@"lvRecord" ofType:@"amr"];
        NSString *wavDirectory = [self GetPathByFileName:@"lvRecord" ofType:@"wav"];
    
        BOOL isSave = [voiceData writeToFile:fileDirectory atomically:YES];
        if (isSave) {
            NSLog(@"保存下载录音成功");
        } else {
            NSLog(@"保存下载录音失败");
        }
        [VoiceConverter ConvertAmrToWav:fileDirectory wavSavePath:wavDirectory];
        NSURL *wavURL = [NSURL fileURLWithPath:wavDirectory];
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:wavURL options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        self.recordTotalTime.text = [NSString stringWithFormat:@"%.0f''", audioDurationSeconds];
    }
    
}

- (NSString *)GetPathByFileName:(NSString *)fileName ofType:(NSString *)type {
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];;
    NSString *fileDirectory = [[[directory stringByAppendingPathComponent:fileName]
                                stringByAppendingPathExtension:type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}


#pragma mark - 紧急状态按钮点击
- (IBAction)urgencyStatusClick:(UIButton *)sender {
    
    if (!sender.selected) {
        /// 未选中状态
        sender.selected = YES;
        
    }
    
    for (UIButton *btn in self.statusArray) {
        if (btn != sender) {
            btn.selected = NO;
        }
    }
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [K_GlobalUtil HUDShowMessage:@"已成功录音" addedToView:self.view];
            
            self.recordTotalTime.text = [NSString stringWithFormat:@"%.0f''", [self.recordTool recordTotalTime]];
        });
    }
}

// 从按钮上移除
- (void)recordBtnDidTouchDragExit:(UIButton *)recordBtn {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.recordTool stopRecording];
        [self.recordTool destructionRecordingFile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [K_GlobalUtil HUDShowMessage:@"已取消录音" addedToView:self.view];
        });
    });
}

#pragma mark - 播放按钮
- (void)playClick {
    if ([self.recordTotalTime.text isEqualToString:@"0''"]) {
        [K_GlobalUtil HUDShowMessage:@"没有可播放的录音" addedToView:self.view];
        
    } else {
        //点击播放按钮时，动画开始
        [self.audioImgView startAnimating];
        [self.recordTool playRecordingFile];
        self.recordTool.player.delegate = self;
    }
}

#pragma mark - 上传按钮 / 处理按钮
- (IBAction)uploaderClick:(UIButton *)sender {
    
    if (self.isEventDispose) {
        // 处理
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self disposeEventMethod];
    } else {
        // 上传
        [self uploadEventDetailInfoMethod];
    }
    
}

/**
 处理事件方法
 */
- (void)disposeEventMethod {
    [K_NetWorkClient dealWithEventRecordWithDic:@{@"id":self.eventData[@"id"], @"status": @"1"} Success:^(id response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([response[@"code"] isEqualToString:@"200"]) {
            [K_GlobalUtil HUDShowMessage:@"处理成功" addedToView:SharedAppDelegate.window];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [K_GlobalUtil HUDShowMessage:@"处理失败" addedToView:self.view];
        NSLog(@"处理事件失败");
    }];
}

/**
 上传事件
 */
- (void)uploadEventDetailInfoMethod {
    /// 把图片和语音二进制数据加到一个数组中
    if (self.imageArray.count > 0) {
        
        for (UIImage *item in self.imageArray) {
            NSData *imgData = UIImagePNGRepresentation(item);
            [self.picVoiceDataArray addObject:imgData];
        }
    }
    
    if ([self.recordTool recordTotalTime] > 0.0) {
        // 语音data
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *AMRFilePath = [[[directory stringByAppendingPathComponent:@"lvRecord"]
                                  stringByAppendingPathExtension:@"amr"]
                                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"amrfilePath:%@", AMRFilePath);
        NSData *voiceData = [NSData dataWithContentsOfFile:AMRFilePath];
        [self.picVoiceDataArray addObject:voiceData];
        self.isContainVoiceData = YES;
    }
    
    
    if (self.picVoiceDataArray.count > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [K_NetWorkClient getQiniuTokenSuccess:^(id response) {
            
            if ([response[@"code"] isEqualToString:@"0"]) {
                // 请求成功
                NSString *token = response[@"data"];
                
                [self uploadImageAndVoiceToken:token];
                
            }
            
        } failure:^(NSError *error) {
            NSLog(@"请求七牛token失败");
        }];
    } else {
        /// 没有需要上传的声音文件和图片  然后判断事件描述是否是空
        if ([self.recordText.text isValidString]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self uploadAllInfomationMethod];
        } else {
            // 没有文件和图片 并且事件描述为空  给予提示输入信息
            [K_GlobalUtil HUDShowMessage:@"请输入详细信息" addedToView:self.view];
            
        }
    }
    
}


/**
 上传图片和语音
 */
- (void)uploadImageAndVoiceToken:(NSString *)token {
    [self putData:self.picVoiceDataArray.lastObject token:token];
    [self.picVoiceDataArray removeLastObject];
}

- (void)putData:(NSData *)data token:(NSString *)token {
    
    __block NSMutableString *url = [[NSMutableString alloc] initWithString:@"https://portalapp.magicmanufactory.com/"];
    QNUploadManager *uploadManger = [[QNUploadManager alloc] init];
    weakObjc(self);
    [uploadManger putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        [url appendString:resp[@"key"]];
        [weakself.picVoiceUrlArray addObject:url]; /// 保存地址的顺序为反序的
        if (weakself.picVoiceDataArray.count > 0) {
            /// 还有未上传的图片或者语音
            [weakself uploadImageAndVoiceToken:token];
        } else {
            /// 上传完毕 需要将图片url和其他信息上传到后台
            [weakself uploadAllInfomationMethod];
        }
        
    } option:nil];
    
}

/**
 信息上传服务器
 */
- (void)uploadAllInfomationMethod {
    NSDictionary *infoDic = [self postServiceInformation];
    [K_NetWorkClient addEventRecordWithDic:infoDic Success:^(id response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"response:%@", response);
        NSLog(@"上传图片语音成功");
        if ([response[@"code"] isEqualToString:@"200"]) {
            
            [K_GlobalUtil HUDShowMessage:@"上传成功" addedToView:SharedAppDelegate.window];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [K_GlobalUtil HUDShowMessage:@"上传失败" addedToView:self.view];
            
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [K_GlobalUtil HUDShowMessage:@"上传失败" addedToView:self.view];
        NSLog(@"上传失败");
    }];
}


- (NSDictionary *)postServiceInformation {
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setValue:KUSERNAME forKey:@"employeeNumber"];
    [infoDic setValue:KDISPLAYNAME forKey:@"displayName"];
    [infoDic setValue:[processingTime getCurrentDateWithFormatString:@"yyyy-MM-dd HH:mm:ss"] forKey:@"createTime"];
    [infoDic setValue:[[NSNumber numberWithDouble:self.location.latitude] stringValue] forKey:@"latitude"];
    [infoDic setValue:[[NSNumber numberWithDouble:self.location.longitude] stringValue] forKey:@"longitude"];
    [infoDic setValue:self.recordText.text forKey:@"textDescription"];
    NSArray *savePicVoiceUrlTempArr = [self.picVoiceUrlArray copy];
    if (self.isContainVoiceData) {
        /// 有voice
        [infoDic setValue:self.picVoiceUrlArray.firstObject forKey:@"speechDescription"];
        [self.picVoiceUrlArray removeObjectAtIndex:0];
    }
    NSArray *tempUrlarray = [[self.picVoiceUrlArray reverseObjectEnumerator] allObjects];
    for (int i = 0; i < tempUrlarray.count; i ++) {
        [infoDic setValue:tempUrlarray[i] forKey:[NSString stringWithFormat:@"pictureDescription%d", i+1]];
    }
    /// 这里恢复之前的值是因为  如果上传失败的话 需要重新点上传按钮  保存的url需要用到  ！！！
    self.picVoiceUrlArray = [NSMutableArray arrayWithArray:savePicVoiceUrlTempArr];
    
    for (UIButton *btn in self.statusArray) {
        if (btn.isSelected) {
            if ([btn.currentTitle isEqualToString:@"正常"]) {
                [infoDic setValue:@"0" forKey:@"urgentStatus"];
            } else if ([btn.currentTitle isEqualToString:@"重要"]) {
                [infoDic setValue:@"1" forKey:@"urgentStatus"];
            } else {
                /// 紧急
                [infoDic setValue:@"2" forKey:@"urgentStatus"];
            }
            break;
        }
    }
    
    
    return infoDic;
}

#pragma mark - 懒加载
- (NSMutableArray *)pictureDataArr {
    if (!_pictureDataArr) {
        _pictureDataArr = [NSMutableArray array];
    }
    return _pictureDataArr;
}
- (NSDictionary *)eventData {
    if (!_eventData) {
        _eventData = [NSDictionary dictionary];
    }
    return _eventData;
}

- (NSMutableArray *)picVoiceUrlArray {
    if (!_picVoiceUrlArray) {
        _picVoiceUrlArray = [NSMutableArray array];
    }
    return _picVoiceUrlArray;
}

- (NSMutableArray *)picVoiceDataArray {
    if (!_picVoiceDataArray) {
        _picVoiceDataArray = [NSMutableArray array];
    }
    return _picVoiceDataArray;
}
- (UIImageView *)audioImgView {
    if (!_audioImgView) {
        _audioImgView = [[UIImageView alloc] initWithFrame:CGRectMake(11.25, 10, 15, 15)];
        NSArray *myImages = [NSArray arrayWithObjects: [UIImage imageNamed:@"audio_icon_3"],[UIImage imageNamed:@"audio_icon_1"],[UIImage imageNamed:@"audio_icon_2"],[UIImage imageNamed:@"audio_icon_3"],nil];
        [_audioImgView setImage:[UIImage imageNamed:@"audio_icon_3"]];
        _audioImgView.animationImages = myImages;
        _audioImgView.animationDuration = 1;
        _audioImgView.animationRepeatCount = 0; //动画重复次数，0表示无限循环
    }
    return _audioImgView;
}
- (WN_CustomActionSheet *)sheet {
    if (!_sheet) {
        _sheet = [WN_CustomActionSheet customActionSheet];
        _sheet.delegate = self;
    }
    return _sheet;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

#pragma mark - touch page
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - AVAudioPlayerDelegate
/// 结束播放方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [self.audioImgView stopAnimating];
}

#pragma mark - collectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isEventDispose) {
        // 事件处理
        return self.pictureDataArr.count;
    } else {
        // 事件上报
        if (self.imageArray.count < 3)
        {
            return self.imageArray.count+1;
            
        }
        else return 3;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEventDispose) {
        /// 事件处理
        static NSString *identifier = @"cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if(cell != nil){
            [cell  removeFromSuperview];
        }
        for (id obj in cell.contentView.subviews) {
            [obj removeFromSuperview];
        }
         UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (CGRectGetWidth(self.imageCollectionView.frame)-30)/3, CGRectGetWidth(self.imageCollectionView.frame)/3-22)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.pictureDataArr[indexPath.row]]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        
        return cell;
    } else {
        /// 事件上报
        static NSString *identifier = @"cell";
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if(cell != nil){
            [cell  removeFromSuperview];
        }
        for (UIButton * btn in cell.contentView.subviews) {
            [btn removeFromSuperview];
        }
        if((indexPath.row == self.imageArray.count)||(self.imageArray.count == 0)){
            UIImageView *plus = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (CGRectGetWidth(self.imageCollectionView.frame)-30)/3, CGRectGetWidth(self.imageCollectionView.frame)/3-22)];
            plus.image = [UIImage imageNamed:@"加号"];
            plus.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:plus];
        }
        else if(indexPath.row < self.imageArray.count){
            UIImageView *littleImageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (CGRectGetWidth(self.imageCollectionView.frame)-30)/3, CGRectGetWidth(self.imageCollectionView.frame)/3-22)];
            littleImageview.tag = 2;
            littleImageview.image = self.imageArray[indexPath.row];
            littleImageview.contentMode = UIViewContentModeScaleAspectFill;
            littleImageview.clipsToBounds = YES;
            [cell.contentView addSubview:littleImageview];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(CGRectGetWidth(littleImageview.frame)-15, 0, 15, 15);
            [btn setBackgroundImage:[UIImage imageNamed:@"叉号"] forState:UIControlStateNormal];
            btn.tag = indexPath.row;
            [btn addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            littleImageview.userInteractionEnabled = YES;
            [cell.contentView addSubview:btn];
            cell.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    }
    
}

- (void)deleteButtonClicked:(UIButton *)btn {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    weakObjc(self);
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakself.imageArray removeObjectAtIndex:btn.tag];
        [weakself.imageCollectionView reloadData];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [self.navigationController presentViewController:alert animated:YES completion:nil];;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEventDispose) {
        /// 事件处理
        NSMutableArray *browseItemArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.pictureDataArr.count; i ++) {
            MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
            browseItem.bigImageUrl = self.pictureDataArr[i];// 加载网络图片大图地址
            [browseItemArray addObject:browseItem];
        }
        MSSBrowseNetworkViewController *bvc = [[MSSBrowseNetworkViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:indexPath.row];
//        bvc.isEqualRatio = NO;// 大图小图不等比时需要设置这个属性（建议等比）
        
        [bvc showBrowseViewController];
        
    } else {
        /// 事件上报
        if (self.imageArray.count != 0 && indexPath.row<self.imageArray.count) {
            
            /// 显示本地图片
            NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
            for(int i = 0;i < [self.imageArray count]; i++)
            {
                MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
                browseItem.bigImage = self.imageArray[i];
                [browseItemArray addObject:browseItem];
            }
            MSSBrowseLocalViewController *localVC = [[MSSBrowseLocalViewController alloc] initWithBrowseItemArray:browseItemArray currentIndex:indexPath.row];
            //        bvc.isEqualRatio = NO;// 大图小图不等比时需要设置这个属性（建议等比）
            
            [localVC showBrowseViewController];
            
            
            /// 查看处理的时候需要显示网络图片
            //        MSSBrowseNetworkViewController *networkVC = [[MSSBrowseNetworkViewController alloc] initWithBrowseItemArray:browseItemArray currentIndex:indexPath.row];
            //        [networkVC showBrowseViewController];
        }
        else {
            [self.sheet showInView:SharedAppDelegate.window];
        }
    }
}

#pragma mark - flowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((CGRectGetWidth(self.imageCollectionView.frame)-30)/3, (CGRectGetWidth(self.imageCollectionView.frame)-30)/3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}


#pragma mark - CustomActionSheetDelegate
- (void)customActionSheet:(WN_CustomActionSheet *)actionSheet didSelecetWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
//            if ([self isFrontCameraAvailable]) {
//                // 开启前置像头
//                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
        
    } else if (buttonIndex == 1) {
        TZImagePickerController *picker;
        if(self.imageArray.count==0){
            picker = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXImageCount delegate:self];
        }
        else{
            picker = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXImageCount-self.imageArray.count delegate:self];
        }
        // 你可以通过block或者代理，来得到用户选择的照片.
        [picker setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets,BOOL isSelectOriginalPhoto) {
            
            [self.imageArray addObjectsFromArray:photos];
            [self.imageCollectionView reloadData];
//            if(textView.text.length!=0){
//                textString = textView.text;
//            }
//            flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH-20, (SCREEN_WIDTH-20)*0.96+10);
//            imageView.image = dataSource[0];
//            imageView.clipsToBounds = YES;
            
            
        }];
        [self presentViewController:picker animated:YES completion:nil];    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.imageArray addObject:srcImage];
    [self.imageCollectionView reloadData];
}

#pragma mark - 相机相册
/// 相机是否可用
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

/// 是否支持前置摄像头
- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

/// 相机是否支持照片类型
- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

- (void)dealloc {
    NSLog(@"K_RecordEventInfoViewcontroller ---dealloc");
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
    
    [self.recordTool destructionRecordingFile];
}


@end
