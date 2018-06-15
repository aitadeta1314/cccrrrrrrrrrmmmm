//
//  K_SearchViewController.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/28.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_SearchViewController.h"
#import "AddressBookViewController.h"
#import "K_PersonViewController.h"

#define View_TOP  (iPhoneX ? 49 : 25)

@interface K_SearchViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

/**
 搜索框
 */
@property (nonatomic, strong) UITextField *searchTF;
/**
 取消
 */
@property (nonatomic, strong) UIButton *cancel;

/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableView;

/**
 搜索数据源
 */
@property (nonatomic, strong) NSMutableArray *searchData;
/**
 组织数据源
 */
@property (nonatomic, strong) NSMutableArray *orgArray;
/**
 个人数据源
 */
@property (nonatomic, strong) NSMutableArray *personArray;

/**
 未查询到信息显示的label
 */
@property (nonatomic, strong) UILabel *notFound;

@end

@implementation K_SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    [self layoutSubViewsSelfdefineMethod];
}

- (void)layoutSubViewsSelfdefineMethod {
    
    self.cancel = [[UIButton alloc] initWithFrame:CGRectMake(kDeviceWidth - 40 - 10, View_TOP + 5, 40, 30)];
    [self.view addSubview:self.cancel];
    
    self.cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancel setTitleColor:NavigationBarBGColor forState:UIControlStateNormal];
    [self.cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    /// 搜索框
    self.searchTF = [[UITextField alloc] initWithFrame:CGRectMake(10, View_TOP, kDeviceWidth - CGRectGetWidth(self.cancel.frame) - 30, 40)];
    [self.view addSubview:self.searchTF];
    
    self.searchTF.placeholder = @"搜索";
    self.searchTF.backgroundColor = FUIColorFromRGB(0xcdcdcd, 0.2);
    self.searchTF.returnKeyType = UIReturnKeySearch;
    self.searchTF.delegate = self;
    self.searchTF.layer.cornerRadius = 5;
    self.searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.searchTF.frame), CGRectGetHeight(self.searchTF.frame))];
    self.searchTF.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(12, 9, 22, 22)];
    [leftImg1 setImage:[UIImage imageNamed:@"search_leftIcon"]];
    [self.searchTF.leftView addSubview:leftImg1];
//    [self.searchTF addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [self.searchTF becomeFirstResponder];
    
    
    [self.view insertSubview:self.notFound aboveSubview:self.tableView];
}

- (void)cancelClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];

}

//#pragma mark - 监测搜索框数值变化
//- (void)textFieldChange:(UITextField *)searchTF {
//    NSLog(@"%@", searchTF.text);
//    if ([self.searchTF.text isValidString]) {
//
//        [self searchRequestMethod];
//    }
//}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"点击了搜索");
    if (![NSString isBlankString:self.searchTF.text]) {
        
        [self searchRequestMethod];
    } else {
        // 空
        [K_GlobalUtil HUDShowMessage:@"请输入搜索信息" addedToView:self.view];
    }
    
    [self.searchTF resignFirstResponder];
    return YES;
}

// 搜索请求
- (void)searchRequestMethod {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    weakObjc(self);
    [K_NetWorkClient searchAddressWithparameter:self.searchTF.text success:^(id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([responseObject[@"message"] isEqualToString:@"SUCCESS"]) {
            NSDictionary *data = responseObject[@"data"];
            
            weakself.orgArray = [NSMutableArray arrayWithArray:![data[@"org"] isValidObject] ? @[] : data[@"org"]];
            weakself.personArray = [NSMutableArray arrayWithArray:![data[@"person"] isValidObject] ? @[] : data[@"person"]];
            
            if (weakself.orgArray.count == 0 && weakself.personArray.count == 0) {
                weakself.notFound.text = @"搜索不到信息";
                
            } else {
                weakself.notFound.text = @"";
            }
            
            [weakself.tableView reloadData];
            
        } else {
            weakself.notFound.text = @"搜索不到信息";
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        weakself.notFound.text = @"搜索不到信息";
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchTF resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchTF resignFirstResponder];
}

#pragma mark - uitableviewDelegate / datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.orgArray.count>0){
        return 2;
    }
    else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.orgArray.count>0){
        if(section == 0){
            return self.orgArray.count;
        }
        else{
            return self.personArray.count;
        }
    }
    else{
        return self.personArray.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 25, 25)];
        [imageview setTag:101];
        [cell addSubview:imageview];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, 200, 25)];
        [label setTag:102];
        [cell addSubview:label];
    }
    if(self.orgArray.count>0){
        if(indexPath.section == 0){
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"org"];
            UILabel *label = (UILabel *)[cell viewWithTag:102];
            label.text = self.orgArray[indexPath.row][@"stext"];
        }
        else{
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"person"];
            UILabel *label = (UILabel *)[cell viewWithTag:102];
            NSString *string = self.personArray[indexPath.row][@"ename"];
            NSString *str = self.personArray[indexPath.row][@"pernr"];
            str = [str substringFromIndex:2];
            if([string isKindOfClass:[NSNull class]] ){
                label.text = str;
            }
            else{
                label.text = [NSString stringWithFormat:@"%@%@",string,str];
            }
        }
    }
    else{
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
        imageView.image = [UIImage imageNamed:@"person"];
        UILabel *label = (UILabel *)[cell viewWithTag:102];
        NSString *string = self.personArray[indexPath.row][@"ename"];
        NSString *str = self.personArray[indexPath.row][@"pernr"];
        str = [str substringFromIndex:2];
        if([string isKindOfClass:[NSNull class]] ){
            label.text = str;
        }
        else{
            label.text = [NSString stringWithFormat:@"%@%@",string,str];
        }    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_orgArray.count>0){
        if(indexPath.section == 0){
            AddressBookViewController *op = [[AddressBookViewController alloc] init];
            op.orgId = self.orgArray[indexPath.row][@"objid"];
            op.isPushed = YES;
            op.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:op animated:YES];
        }
        else{
            K_PersonViewController *person = [[K_PersonViewController alloc]init];
            person.name = self.personArray[indexPath.row][@"ename"];
            person.phoneNum = self.personArray[indexPath.row][@"usrid"];
            person.org = self.personArray[indexPath.row][@"orgtx"];
            person.plstx = _personArray[indexPath.row][@"plstx"];
            person.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:person animated:YES];
            
        }
    }
    else{
        K_PersonViewController *person = [[K_PersonViewController alloc]init];
        person.name = self.personArray[indexPath.row][@"ename"];
        person.phoneNum = self.personArray[indexPath.row][@"usrid"];
        person.org = self.personArray[indexPath.row][@"orgtx"];
        person.plstx = _personArray[indexPath.row][@"plstx"];
        person.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:person animated:YES];
    }
}

#pragma mark - lazying load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(View_TOP+40+10);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    }
    return _tableView;
}

- (UILabel *)notFound {
    if (!_notFound) {
        _notFound = [[UILabel alloc] init];
        [self.view addSubview:_notFound];
        [_notFound setTextColor: RGBA(129, 134, 136, 1)];
        _notFound.textAlignment = NSTextAlignmentCenter;
        [_notFound mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.searchTF.mas_bottom).offset(40);
            make.centerX.equalTo(self.view);
            make.height.mas_equalTo(40);
        }];
        [_notFound sizeToFit];
    
    }
    return _notFound;
}

- (NSMutableArray *)searchData {
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}

- (NSMutableArray *)orgArray {
    if (!_orgArray) {
        _orgArray = [NSMutableArray array];
    }
    return _orgArray;
}

- (NSMutableArray *)personArray {
    if (!_personArray) {
        _personArray = [NSMutableArray array];
    }
    return _personArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
