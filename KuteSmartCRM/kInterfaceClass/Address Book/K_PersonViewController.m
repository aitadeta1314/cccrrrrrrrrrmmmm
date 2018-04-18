//
//  K_PersonViewController.m
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/26.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_PersonViewController.h"

@interface K_PersonViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    
}
@end

@implementation K_PersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        if(indexPath.row == 0){
            UILabel *phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 25)];
            phoneLabel.text = @"手机";
            [cell addSubview:phoneLabel];
            UILabel *phoneNum = [[UILabel alloc]initWithFrame:CGRectMake(65, 10, 200, 25)];
            [phoneNum setTag:101];
            [cell addSubview:phoneNum];
        }
        else{
            UILabel *orgLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 25)];
            orgLabel.text = @"部门";
            [cell addSubview:orgLabel];
            UILabel *orgNum = [[UILabel alloc]initWithFrame:CGRectMake(65, 10, 200, 25)];
            [orgNum setTag:101];
            [cell addSubview:orgNum];
        }
    }
    UILabel *phoneNum = (UILabel *)[cell viewWithTag:101];
    if([_phoneNum isKindOfClass:[NSNull class]]){
        phoneNum.text = @"";
    }
    else{
        phoneNum.text = _phoneNum;
    }
    UILabel *orgNum = (UILabel *)[cell viewWithTag:102];
    if([_org isKindOfClass:[NSNull class]]){
        orgNum.text = @"";
    }
    else{
        orgNum.text = _org;
    }
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 95;
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
