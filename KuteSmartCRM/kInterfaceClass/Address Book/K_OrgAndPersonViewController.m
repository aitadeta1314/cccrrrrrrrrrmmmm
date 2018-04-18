//
//  K_OrgAndPersonViewController.m
//  KuteSmartCRM
//
//  Created by mac pro on 2018/3/26.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_OrgAndPersonViewController.h"
#import "AddressBookViewController.h"
#import "K_PersonViewController.h"

@interface K_OrgAndPersonViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_orgArray;
    NSMutableArray *_personArray;
    
}
@end

@implementation K_OrgAndPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [self getDataFromServer];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:_tableView];
    
    _orgArray = [[NSMutableArray alloc] init];
    _personArray = [[NSMutableArray alloc] init];
    
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
        
    }];
//    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
//    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
//    // 设置缓存策略忽略本地缓存数据
//    [mgr.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringCacheData];
//    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
//    [mgr.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    [mgr.requestSerializer setTimeoutInterval:12.0];
//    [mgr.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//
//    [mgr.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
//    [mgr.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    objc_setAssociatedObject(mgr, "RETRY_COUNT_MAP_KEY", [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN);
//    mgr.responseSerializer = [[AFJSONResponseSerializer alloc] init];
//    NSMutableSet* set = [mgr.responseSerializer.acceptableContentTypes mutableCopy];
//    [set addObject:@"text/plain"];
//    [set addObject:@"text/html"];
//
//    mgr.responseSerializer.acceptableContentTypes = set;
//    [mgr.requestSerializer setValue:KTOKEN forHTTPHeaderField:@"token"];
//    [mgr.requestSerializer setValue:KUSERNAME forHTTPHeaderField:@"username"];
//
//    NSString *str = KADRESSHTTP;
//    if(_orgId){
//        str = [NSString stringWithFormat:@"%@%@",KADRESS,_orgId];
//    }
//    [mgr GET:str parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        if(responseObject){
//
//            NSDictionary *dic = responseObject[@"data"];
//            _orgArray = dic[@"org"];
//            _personArray = dic[@"person"];
//            [_tableView reloadData];
//
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//
//    }];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_orgArray.count>0){
        return 2;
    }
    else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
        }    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_orgArray.count>0){
        if(indexPath.section == 0){
            AddressBookViewController *op = [[AddressBookViewController alloc] init];
            op.orgId = _orgArray[indexPath.row][@"objid"];
            op.isPushed = YES;
            [self.navigationController pushViewController:op animated:YES];
        }
        else{
            K_PersonViewController *person = [[K_PersonViewController alloc]init];
            person.name = _personArray[indexPath.row][@"ename"];
            person.phoneNum = _personArray[indexPath.row][@"usrid"];
            person.org = _personArray[indexPath.row][@"orgtx"];
            [self.navigationController pushViewController:person animated:YES];
            
        }
    }
    else{
        K_PersonViewController *person = [[K_PersonViewController alloc]init];
        person.name = _personArray[indexPath.row][@"ename"];
        person.phoneNum = _personArray[indexPath.row][@"usrid"];
        person.org = _personArray[indexPath.row][@"orgtx"];
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
