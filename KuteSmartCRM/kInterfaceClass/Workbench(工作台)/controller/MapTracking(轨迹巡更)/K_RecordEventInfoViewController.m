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

/// 可选图片最大数量
#define MAXImageCount 3

@interface K_RecordEventInfoViewController ()<CustomActionSheetDelegate, TZImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

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

/**
 图片collectionView
 */
@property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;

/**
 sheet
 */
@property (nonatomic, strong) WN_CustomActionSheet *sheet;

/**
 图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageArray;

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
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake((CGRectGetWidth(self.imageCollectionView.frame)-30)/3, CGRectGetWidth(self.imageCollectionView.frame)/3);
    
    [self.imageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
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

#pragma mark - 懒加载
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

#pragma mark - collectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(self.imageArray.count < 3)
    {
        return self.imageArray.count+1;
        
    }
    else
        return 3;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
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
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
    
}


@end
