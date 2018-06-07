//
//  AddressBookViewController.m
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/23.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "AddressBookViewController.h"
#import "K_OrgAndPersonViewController.h"
#import "K_PersonViewController.h"
#import "K_SearchViewController.h"


@interface AddressBookViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_orgArray;
    NSMutableArray *_personArray;

}
@end

@implementation AddressBookViewController

- (instancetype)init {
    if (self = [super init]) {
        self.isPushed = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.isPushed ? [self addBackButton] : nil;
    
    
    [self getDataFromServer];
    [self addNavgationItem];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight) style:UITableViewStylePlain];
    _tableView.rowHeight = 50;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _orgArray = [[NSMutableArray alloc]init];
    _personArray = [[NSMutableArray alloc]init];
}

- (void)addNavgationItem {
    if (!self.isPushed) {
        
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(searchClick:)];
        
        self.navigationItem.rightBarButtonItem = search;
    }
}

- (void)searchClick:(UIBarButtonItem *)item {
    NSLog(@"点击了搜索");
    K_SearchViewController *search = [[K_SearchViewController alloc] init];
    search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)getDataFromServer {
    
    [K_NetWorkClient getAddressBookWithOrgID:_orgId success:^(id responseObject) {
        if(responseObject){
            
            NSDictionary *dic = responseObject[@"data"];
            _orgArray = dic[@"org"];
            _personArray = dic[@"person"];
            [_tableView reloadData];
            
        }
    } failure:^(NSError *error) {
        NSLog(@"error:%@", error);
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_orgArray.count>0){
        return 2;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_orgArray.count>0){
        if(section == 0){
            return _orgArray.count;
        }
        else{
            return _personArray.count;
        }
    }
    else{
        return _personArray.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    if(_orgArray.count>0){
        if(indexPath.section == 0){
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"org"];
            UILabel *label = (UILabel *)[cell viewWithTag:102];
            label.text = _orgArray[indexPath.row][@"stext"];
        }
        else{
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
            imageView.image = [UIImage imageNamed:@"person"];
            UILabel *label = (UILabel *)[cell viewWithTag:102];
            NSString *string = _personArray[indexPath.row][@"ename"];
            NSString *str = _personArray[indexPath.row][@"pernr"];
            str = [str substringFromIndex:2];
            if([string isKindOfClass:[NSNull class]] ){
                label.text = str;
            }
            else{
                label.text = [NSString stringWithFormat:@"%@%@",string,str];
            }
        }
    } else {
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
        imageView.image = [UIImage imageNamed:@"person"];
        UILabel *label = (UILabel *)[cell viewWithTag:102];
        NSString *string = _personArray[indexPath.row][@"ename"];
        NSString *str = _personArray[indexPath.row][@"pernr"];
        str = [str substringFromIndex:2];
        if([string isKindOfClass:[NSNull class]] ){
            label.text = str;
        }
        else{
            label.text = [NSString stringWithFormat:@"%@%@",string,str];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_orgArray.count>0){
        if(indexPath.section == 0){
            K_OrgAndPersonViewController *op = [[K_OrgAndPersonViewController alloc]init];
            op.orgId = _orgArray[indexPath.row][@"objid"];
            op.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:op animated:YES];
        }
        else{
            K_PersonViewController *person = [[K_PersonViewController alloc]init];
            person.name = _personArray[indexPath.row][@"ename"];
            person.phoneNum = _personArray[indexPath.row][@"usrid"];
            person.pernr = _personArray[indexPath.row][@"pernr"];
            person.org = _personArray[indexPath.row][@"orgtx"];
            person.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:person animated:YES];

        }
    } else {
        K_PersonViewController *person = [[K_PersonViewController alloc]init];
        person.name = _personArray[indexPath.row][@"ename"];
        person.pernr = _personArray[indexPath.row][@"pernr"];
        person.phoneNum = _personArray[indexPath.row][@"usrid"];
        person.org = _personArray[indexPath.row][@"orgtx"];
        person.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:person animated:YES];
    }
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
