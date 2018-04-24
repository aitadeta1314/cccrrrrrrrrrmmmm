//
//  ViewController.m
//  KuteSmartCRM
//
//  Created by kutesmart on 2017/5/6.
//  Copyright © 2017年 redcollar. All rights reserved.
//

#import "MainViewController.h"
#import "WebDetailViewController.h"
#import "K_HeaderView.h"
#import "K_PortalCell.h"
#import "K_PortalModel.h"
#import "RSAEncryptor.h"

@interface MainViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 *  collectionView
 */
@property (nonatomic, strong) UICollectionView *collectionView;
/**
 *  可变数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  假数据
 */
@property (nonatomic, strong) SublistModel *emptyData;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self configureForInterface];


}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (SublistModel *)emptyData {
    if (!_emptyData) {
        SublistModel *model = [[SublistModel alloc] init];
        model.sub_node_name = @"";
        model.menu_icon = @"";
        model.menu_url = @"";
        _emptyData = model;
    }
    return _emptyData;
}


/**
 布局
 */
- (void)configureForInterface {

    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) collectionViewLayout:flow];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = RGBA(245, 245, 245, 1);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    weakObjc(self);
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakself.dataArray = [NSMutableArray array];
        [weakself makeDataFromNet];
    }];

    [self.collectionView.mj_header beginRefreshing];

    // 注册cell
    [self registerCell];
}

- (void)registerCell {

    [self.collectionView registerNib:[UINib nibWithNibName:@"K_PortalCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"K_HeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
}

- (void)makeDataFromNet {
    [K_NetWorkClient getWorkbenchListInfoSuccess:^(id responseObject) {
        NSLog(@"responseObject:%@", responseObject);
        
    }
                                         failure:^(NSError *error) {
                                             NSLog(@"请求失败");
    }];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    NSDictionary *params = @{@"userid":KUSERID};
//    [manager GET:KMENUHTTP parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSString *result_code = dic[@"result_code"];
//
//        if ([result_code isEqualToString:@"Y"]) {
//
//            NSString *result_info = dic[@"result_info"];
//            // Convert to JSON object:
//            NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[result_info dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
//            NSLog(@"jsonObject:%@",jsonObject);
////            for (NSDictionary *subDic in jsonObject) {
////                K_PortalModel *model = [[K_PortalModel alloc] initWithDictionary:subDic error:nil];
////                 NSUInteger count = model.sublist.count;
////                if (UI_IS_IPHONE5) {
////                    if (count%3 != 0) {
////                        for (int i=0; i<(3-count%3); i++) {
////                            [model.sublist addObject:self.emptyData];
////                        }
////                    }
////                }
////                else {
////                    if (count%4 != 0) {
////                        for (int i=0; i<(4-count%4); i++) {
////                            [model.sublist addObject:self.emptyData];
////                        }
////                    }
////                }
////
////                [self.dataArray addObject:model];
////            }
//
//        }
//        else {
//            [self progressHUD];
//        }
//
//        [self.collectionView reloadData];
//
//        [self.collectionView.mj_header endRefreshing];
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        [self.collectionView.mj_header endRefreshing];
//        [self progressHUD];
//    }];

}

#pragma mark - UICollectionView delegate / data source
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    K_PortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    SublistModel *model = ((K_PortalModel *)self.dataArray[indexPath.section]).sublist[indexPath.row];
    cell.model = model;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    K_PortalModel *model = self.dataArray[section];
    if (UI_IS_IPHONE5) {
        return model.sublist.count;
    }
    else {
        return model.sublist.count;
    }

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return self.dataArray.count;
}

/** 表头表位视图*/
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        K_HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        headerView.lbHeader.text = ((K_PortalModel *)self.dataArray[indexPath.section]).node_name;
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    WebDetailViewController *webDetailVC = [[WebDetailViewController alloc] init];
    SublistModel *sublist = ((K_PortalModel *)self.dataArray[indexPath.section]).sublist[indexPath.row];
    if (![sublist.menu_url isEqualToString:@""]) {
        if ([sublist.sub_node_name isEqualToString:@"CRM"]) {
            webDetailVC.htmlUrl = [NSString stringWithFormat:@"%@?login_username=%@&login_password=%@&system=%@",sublist.menu_url,KUSERNAME,[RSAEncryptor encryptString:KUSERPASSWORD publicKey:KRSA_PUBLIC_KEY],@"IOS"];
            NSLog(@"url:%@",webDetailVC.htmlUrl);
        }
        if ([sublist.sub_node_name isEqualToString:@"B2M"]) {
            webDetailVC.htmlUrl = [NSString stringWithFormat:@"http://%@",sublist.menu_url];
        }
        else {
            webDetailVC.htmlUrl = sublist.menu_url;
        }

        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webDetailVC animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"反选点击：%ld",(long)indexPath.row);
}

#pragma mark - flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kDeviceWidth, 25);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_IS_IPHONE5) {
        return CGSizeMake(kDeviceWidth/3-0.5, kDeviceWidth/3);
    }
    else {
        return CGSizeMake(kDeviceWidth/4-0.5, kDeviceWidth/4);
    }
}

// 每个分区的外间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    return UIEdgeInsetsMake(0, 0, 10, 0);

}

// 返回每个cell上下的最小距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.1;
}

// 返回每个cell左右之间的最小距离
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.5;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
