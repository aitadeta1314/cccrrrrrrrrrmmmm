//
//  K_PersonViewController.m
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/26.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PersonViewController.h"
#import "K_PersonCell.h"

@interface K_PersonViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation K_PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButton];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self getDataSource];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"K_PersonCell" bundle:nil] forCellReuseIdentifier:@"cellIdentifier"];
    
}

/// 数据源
- (void)getDataSource {
    NSArray *name = @[@"手机", @"部门"];
    if ([NSString isBlankString:_phoneNum]) {
        _phoneNum = @"";
    }
    NSArray *value = @[_phoneNum, _org];
    for (int i = 0; i < 2; i ++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:name[i] forKey:@"name"];
        [dic setValue:value[i] forKey:@"phoneNumber"];
        [self.dataSource addObject:dic];
    }
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    K_PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    NSDictionary *dic = self.dataSource[indexPath.row];
    [cell cellInformationDictionary:dic];
    cell.callPhoneBlock = ^{
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[dic valueForKey:@"phoneNumber"]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 95)];
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 100, 25)];
    if([_name isKindOfClass:[NSNull class]]){
        nameLabel.text = @"";
    }
    else{
        nameLabel.text = _name;
    }
    [view addSubview:nameLabel];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-15-25, 15, 25, 25)];
    imageV.image = [UIImage imageNamed:@"person"];
    [view addSubview:imageV];
    UILabel *idLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(nameLabel.frame)+15, 100, 25)];
    NSString *str = _pernr;
    str = [str substringFromIndex:2];
    idLabel.text = str;
    [view addSubview:idLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 95;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
