//
//  MyViewController.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/13.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "MyViewController.h"
#import "UIView+PS.h"
#import "K_ChangePasswordViewController.h"
#import "K_MyTableCell.h"
#import "LoginViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

#define Max_OffsetY  50

#define HalfF(x) ((x)/2.0f)

#define  Statur_HEIGHT   [[UIApplication sharedApplication] statusBarFrame].size.height
#define  NAVIBAR_HEIGHT  (self.navigationController.navigationBar.frame.size.height)
#define  INVALID_VIEW_HEIGHT (Statur_HEIGHT + NAVIBAR_HEIGHT)


@interface MyViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate> {
    
    CGFloat _lastPosition;
}
/**
 *  姓名
 */
@property (nonatomic, strong) UILabel * personLabel;

@property (nonatomic, strong) UILabel * messageLabel;
@property (nonatomic, strong) UIView * headBackView;
/**
 *  尾部视图
 */
@property (nonatomic, strong) UIView * footView;
@property (nonatomic, strong) UIImageView * avatarView;
@property (nonatomic, strong) UIImageView * headImageView;
@property (nonatomic, strong) UITableView * displayTableView;
/**
 *  数据数组
 */
@property (nonatomic, strong) NSArray *dataArray;
/**
 * 是否能够使用返回手势
 */
@property (nonatomic, assign) BOOL isCanSideBack;
/**
 *  imagePicker
 */
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation MyViewController
- (void)dealloc {
    
    _headBackView = nil;
    _headImageView = nil;
    _displayTableView = nil;
}
#pragma mark - 懒加载
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"修改密码"];
    }
    return _dataArray;
}

- (UITableView *)displayTableView {
    
    if (!_displayTableView) {
        
        _displayTableView  = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _displayTableView.delegate = self;
        _displayTableView.dataSource = self;
        _displayTableView.showsVerticalScrollIndicator = NO;
    }
    return _displayTableView;
}

- (UIView *)headBackView {
    
    if (!_headBackView) {
        _headBackView = [UIView new];
        _headBackView.userInteractionEnabled = YES;
        _headBackView.frame = CGRectMake(0, 0, kDeviceWidth, 200);
    }
    return _headBackView;
}

- (UIView *)footView {
    if (!_footView) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, 80)];
        _footView.backgroundColor = [UIColor clearColor];
        
        // 退出登录
        UIButton *logout = [[UIButton alloc] init];
        logout.size = CGSizeMake(kDeviceWidth, 40);
        logout.center = _footView.center;
        logout.backgroundColor = [UIColor whiteColor];
        [logout setTitle:@"退出登录" forState:UIControlStateNormal];
        [logout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        logout.titleLabel.font = [UIFont fontWithName:@"thin" size:16];
        [logout addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:logout];
        
        UIView *upLine = [[UIView alloc] init];
        upLine.backgroundColor = [UIColor lightGrayColor];
        UIView *downLine = [[UIView alloc] init];
        downLine.backgroundColor = [UIColor lightGrayColor];
        [_footView addSubview:upLine];
        [_footView addSubview:downLine];
        
        upLine.sd_layout
        .leftEqualToView(_footView)
        .rightEqualToView(_footView)
        .heightIs(0.5)
        .bottomSpaceToView(logout, 0);
        
        downLine.sd_layout
        .leftEqualToView(_footView)
        .rightEqualToView(_footView)
        .heightIs(0.5)
        .topSpaceToView(logout, 0);
    }
    return _footView;
}

- (UIImageView *)avatarView {
    
    if (!_avatarView) {
        _avatarView = [UIImageView new];
        _avatarView.userInteractionEnabled = YES;
        _avatarView.image = [UIImage imageNamed:@"defaultAvatar"];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.size = CGSizeMake(80, 80);
        _avatarView.clipsToBounds = YES;
        [_avatarView setLayerWithCr:_avatarView.width / 2];
    }
    return _avatarView;
}

- (UIImageView *)headImageView {
    
    if (!_headImageView) {
        
        _headImageView = [UIImageView new];
        _headImageView.image = [UIImage imageNamed:@"bg.jpg"];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.backgroundColor = [UIColor orangeColor];
    }
    return _headImageView;
}

- (UILabel*)messageLabel {
    
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:16];
        _messageLabel.textColor = [UIColor whiteColor];
    }
    return _messageLabel;
}

- (UILabel *)personLabel {
    if (!_personLabel) {
        _personLabel = [[UILabel alloc] init];
        _personLabel.textAlignment = NSTextAlignmentCenter;
        _personLabel.font = [UIFont fontWithName:@"Helvetica" size:30];
        _personLabel.textColor = [UIColor whiteColor];
    }
    return _personLabel;
}

- (UIImagePickerController *)imagePicker {
    
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

#pragma mark -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    self.navigationItem.title = @"我的";
    
    [self resetHeaderView];
    
    self.displayTableView.backgroundColor = [UIColor  clearColor];
    self.displayTableView.tableHeaderView = self.headBackView;
    self.displayTableView.tableFooterView = self.footView;
    self.displayTableView.scrollEnabled = NO;
    self.displayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.displayTableView];
    
    // 注册cell
    [self.displayTableView registerNib:[UINib nibWithNibName:@"K_MyTableCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

- (void)resetHeaderView {
    
    self.headImageView.frame = self.headBackView.bounds;
    [self.headBackView addSubview:self.headImageView];
    
    self.avatarView.centerX = self.headBackView.centerX;
    self.avatarView.centerY = self.headBackView.centerY -  HalfF(70);
    [self.headBackView addSubview:self.avatarView];
    
    self.personLabel.centerY = self.avatarView.centerY + 50;
    self.personLabel.size = CGSizeMake(kDeviceWidth - HalfF(40), 40);
//    self.personLabel.text = KPERSONNAME;
    self.personLabel.centerX = self.headBackView.centerX;
    [self.headBackView addSubview:self.personLabel];
    
    self.messageLabel.text = [NSString stringWithFormat:@"工号：%@",KUSERNAME];
    self.messageLabel.y = CGRectGetMaxY(self.personLabel.frame);
    self.messageLabel.size = CGSizeMake(kDeviceWidth - HalfF(30), 30);
    self.messageLabel.centerX = self.headBackView.centerX;
    [self.headBackView addSubview:self.messageLabel];
    
    // 头像添加轻击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
    [self.avatarView addGestureRecognizer:tap];
}

/** 点击响应事件*/
- (void)tapAvatar:(UITapGestureRecognizer *)sender {
    [self callActionSheetFunc];
}

- (void)callActionSheetFunc {
    
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"选择图像"
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拍照"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        // 判断有无相机功能，模拟器下没有
                                                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                                        {
                                                            // 检查相机是否可用
                                                            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                                                            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
                                                            {
                                                                //无权限 做一个友好的提示
                                                                UIAlertView * alart = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的相机\n设置>隐私>相机" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"去设置", nil];
                                                                [alart show];
                                                                return ;
                                                            } else {
                                                                //调用相机
                                                                self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                [self presentViewController:self.imagePicker animated:YES completion:nil];
                                                            }
                                                        }
                                                    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"从相册中选择"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                                                        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
                                                        {
                                                            // 无权限
                                                            // do something...
                                                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                                                            message:@"请您设置允许APP访问您的相册\n设置>隐私>照片"
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:@"确定"
                                                                                                  otherButtonTitles:@"去设置", nil];
                                                            [alert show];
                                                            
                                                            return;
                                                        }
                                                        else {
                                                            
                                                            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                            [self presentViewController:self.imagePicker animated:YES completion:nil];
                                                        }
                                                    }];
    [alertVC addAction:cancleAction];
    [alertVC addAction:action1];
    [alertVC addAction:action2];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 禁用返回手势  解决右滑返回之后 点击cell跳转App卡死现象
    [self forbiddenSideBack];
}

- (void)forbiddenSideBack {
    self.isCanSideBack = NO;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 恢复右滑手势
    [self revertSideBack];
}

- (void)revertSideBack {
    self.isCanSideBack = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.isCanSideBack;
}

#pragma mark - 退出登录
- (void)logoutClick {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"确定要退出登录？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        KLOGOUT = YES;
        [self toLoginPage];
    }];
    [alertVC addAction:action2];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)toLoginPage {
    
    UIStoryboard *CRMStory = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
    LoginViewController *loginVC = [CRMStory instantiateViewControllerWithIdentifier:@"loginID"];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = loginVC;
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%s, info == %@",__func__, info);
    UIImage *avatar = info[@"UIImagePickerControllerOriginalImage"];
    self.avatarView.image = avatar;  // 先设置头像，之后再上传服务器，弹出“头像设置成功”
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // 上传图片
    [self uploadAvatar:avatar];
}

- (void)uploadAvatar:(UIImage *)photo {
    NSData *data = UIImageJPEGRepresentation(photo, 1);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:@"" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        /*
         Data: 要上传的二进制数据
         name:保存在服务器上时用的Key值
         fileName:保存在服务器上时用的文件名,注意要加 .jpg或者.png
         mimeType:让服务器知道我上传的是哪种类型的文件
         */
        [formData appendPartWithFileData:data name:@"" fileName:fileName mimeType:@"image/png"];
        
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

#pragma mark - 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    K_MyTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.titleLabel.text = self.dataArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    K_MyTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *vc = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CRM" bundle:nil];
    if ([cell.titleLabel.text isEqualToString:@"修改密码"]) {
        vc = [storyboard instantiateViewControllerWithIdentifier:@"changePassword"];
    }
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

/**
 滚动导航栏渐变

 @param scrollView tableView
 */
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    CGFloat offset_Y = scrollView.contentOffset.y;
//
//    //1.处理图片放大
//    CGFloat imageH = self.headBackView.size.height;
//    CGFloat imageW = kDeviceWidth;
//
//    //下拉
//    if (offset_Y < 0) {
//
//        CGFloat totalOffset = imageH + ABS(offset_Y);
//        CGFloat f = totalOffset / imageH;
//
//        //如果想下拉固定头部视图不动，y和h 是要等比都设置。如不需要则y可为0
//        self.headImageView.frame = CGRectMake(-(imageW * f - imageW) * 0.5, offset_Y, imageW * f, totalOffset);
//    }
//    else {
//        self.headImageView.frame = self.headBackView.bounds;
//    }
//
//    //2.处理导航颜色渐变  3.底部工具栏动画
//    if (offset_Y > Max_OffsetY) {
//
//        CGFloat alpha = MIN(1, 1 - ((Max_OffsetY + INVALID_VIEW_HEIGHT - offset_Y) / INVALID_VIEW_HEIGHT));
//
//        [self.navigationController.navigationBar ps_setBackgroundColor:[NavigationBarBGColor colorWithAlphaComponent:alpha]];
//
//        if (offset_Y - _lastPosition > 5) {
//            //向上滚动
//            _lastPosition = offset_Y;
//
//        }
//        else if (_lastPosition - offset_Y > 5) {
//            // 向下滚动
//            _lastPosition = offset_Y;
//        }
//        self.navigationItem.title = alpha > 0.8? @"我的":@"";
//    }
//    else {
//        [self.navigationController.navigationBar ps_setBackgroundColor:[NavigationBarBGColor colorWithAlphaComponent:0]];
//    }
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
