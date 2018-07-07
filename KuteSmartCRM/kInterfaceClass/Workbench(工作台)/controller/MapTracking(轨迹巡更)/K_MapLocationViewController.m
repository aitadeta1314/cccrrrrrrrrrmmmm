//
//  BaseMapViewController.m
//  KuteSmartCRM
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "K_MapLocationViewController.h"
//#import "TipView.h"
#import "AMapRouteRecord.h"
#import "FileHelper.h"
#import "K_CustomPinView.h"
#import "HWWeakTimer.h"
#import "K_RecordEventInfoViewController.h"

#define kTempTraceLocationCount 20

@interface K_MapLocationViewController() <MAMapViewDelegate>

/**
 显示保安
 */
@property (nonatomic, strong) UIButton *securityBtn;
/**
 待处理事件
 */
@property (nonatomic, strong) UIButton *pendingBtn;

/**
 记录突发事件按钮
 */
@property (nonatomic, strong) UIButton *recordEventBtn;
/**
 NSTimer
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 大头针坐标(每一分钟更新大头针坐标  移除之前的坐标信息)
 */
@property (nonatomic, strong) NSMutableArray *pinAnnotation;
/**
 数据源大头针坐标信息(每个大头针包含名字、工号、坐标点经纬度信息)(每分钟更新大头针坐标  移除之前的信息)
 */
@property (nonatomic, strong) NSMutableArray *dataSourcePinCoordsInfo;

/**
 保存弹出气泡的大头针坐标点  防止在每分钟刷新，删除正在查询的大头针
 */
@property (nonatomic, assign) CLLocationCoordinate2D searchCoordinate;
/**
 弹出气泡的人员姓名
 */
@property (nonatomic,copy) NSString *searchName;
/**
 气泡大头针
 */
@property (nonatomic, strong) MAPointAnnotation *searchAnnotation;

@property (nonatomic, strong) MAMapView *mapView;
/**
 轨迹纠偏管理类
 */
@property (nonatomic, strong) MATraceManager *traceManager;

// 不需要
//@property (nonatomic, strong) TipView *tipView;
// 暂不需要
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;

// 是否在记录中...
@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) BOOL isSaving;

// 重要！！！
@property (nonatomic, strong) MAPolyline *polyline;
// 重要！！！
@property (nonatomic, strong) NSMutableArray *locationsArray;
// 重要！！！
@property (nonatomic, strong) AMapRouteRecord *currentRecord;

@property (nonatomic, strong) NSMutableArray *tracedPolylines;
@property (nonatomic, strong) NSMutableArray *tempTraceLocations;
@property (nonatomic, assign) double totalTraceLength;

@end

@implementation K_MapLocationViewController

#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation)
    {
        return;
    }
    
//    if (!self.isRecording)
//    {
//        return;
//    }
    
    if (userLocation.location.horizontalAccuracy < 100 && userLocation.location.horizontalAccuracy > 0)
    {
        double lastDis = [userLocation.location distanceFromLocation:self.currentRecord.endLocation];
        
        if (lastDis < 0.0 || lastDis > 10)
        {
            [self.locationsArray addObject:userLocation.location];
            
            //            NSLog(@"date: %@,now :%@",userLocation.location.timestamp, [NSDate date]);
//            [self.tipView showTip:[NSString stringWithFormat:@"has got %ld locations",self.locationsArray.count]];
            
            // 往 路径记录对象 添加路径location
            [self.currentRecord addLocation:userLocation.location];
            
            if (self.polyline == nil)
            {
                self.polyline = [MAPolyline polylineWithCoordinates:NULL count:0];
                [self.mapView addOverlay:self.polyline];
                
            }
            
            NSUInteger count = 0;
            
            CLLocationCoordinate2D *coordinates = [self coordinatesFromLocationArray:self.locationsArray count:&count];
            if (coordinates != NULL)
            {
                [self.polyline setPolylineWithCoordinates:coordinates count:count];
                free(coordinates);
            }
            
            [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
            
            
            // trace
            [self.tempTraceLocations addObject:userLocation.location];
            if (self.tempTraceLocations.count >= kTempTraceLocationCount)
            {
                // 轨迹纠偏方法（我觉得需要删除这方法，记录保存完整的坐标值）
                [self queryTraceWithLocations:self.tempTraceLocations withSaving:NO];
                [self.tempTraceLocations removeAllObjects];
                
                // 把最后一个再add一遍，否则会有缝隙
                [self.tempTraceLocations addObject:userLocation.location];
            }
        }
    }
    
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
    }
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if (overlay == self.polyline)
    {
        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        view.lineWidth = 5.0;
        view.strokeColor = [UIColor redColor];
        return view;
    }
    
//    if ([overlay isKindOfClass:[MAPolyline class]])
//    {
//        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
//        view.lineWidth = 10.0;
//        view.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
//        return view;
//    }
    
    //多边形
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        
        MAPolygonRenderer *pol = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        pol.lineWidth = 1.f;
        NSString *areaStr = overlay.title;

        if ([areaStr isEqualToString:@"停车场"]) {
            pol.fillColor = RGBA(88, 132, 237, 1);
        } else if ([areaStr isEqualToString:@"办公室"]) {
            pol.fillColor = RGBA(49, 98, 206, 1);
        } else if ([areaStr isEqualToString:@"工厂"]) {
            pol.fillColor = RGBA(234, 94, 62, 1);
        } else if ([areaStr isEqualToString:@"超市"]) {
            pol.fillColor = RGBA(246, 186, 89, 1);
        } else if ([areaStr isEqualToString:@"宾馆"]) {
            pol.fillColor = RGBA(58, 169, 241, 1);
        } else if ([areaStr isEqualToString:@"公寓"]) {
            pol.fillColor = RGBA(128, 86, 210, 1);
        } else if ([areaStr isEqualToString:@"食堂"]) {
            pol.fillColor = RGBA(97, 214, 129, 1); 
        }
        
        
        pol.lineDashType = kMALineDashTypeNone;
        return pol;
        
    }
    
    return nil;
}

/// 大头针自定义
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]] && ![annotation isMemberOfClass:[MAUserLocation class]]) {
        /// 用户自身定位的小蓝点也是MAPointAnnotation的子类 ,如果不加以区分小蓝点会消失
        static NSString *customPinReuseIdentifier = @"CustomPinAnnotationIden";
        K_CustomPinView *pinView = (K_CustomPinView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customPinReuseIdentifier];
        if (!pinView) {
            pinView = [[K_CustomPinView alloc] initWithAnnotation:annotation reuseIdentifier:customPinReuseIdentifier];
            pinView.canShowCallout = NO;
            pinView.draggable = NO;
            
        }
        weakObjc(self);
        pinView.clickCustomPinView = ^(CLLocationCoordinate2D coordinate, NSString *name) {
            weakself.searchCoordinate = coordinate;
            weakself.searchName = name;
//            NSLog(@"block ---- searchCoordinate...latitude:%f, longitude:%f", weakself.searchCoordinate.latitude, weakself.searchCoordinate.longitude);
//            NSLog(@"block ---- searchName:%@", weakself.searchName);
        };
        for (NSDictionary *subDic in self.dataSourcePinCoordsInfo) {
            double latitude = [[subDic valueForKey:@"latitude"] doubleValue];
            double longitude = [[subDic valueForKey:@"longitude"] doubleValue];
            if (annotation.coordinate.latitude == latitude && annotation.coordinate.longitude == longitude) {
                
                pinView.portraitUrl = [NSString stringWithFormat:@""];  // 图片暂时是本地的
                pinView.name = [subDic valueForKey:@"name"];
                pinView.employeeNumber = [subDic valueForKey:@"employeeNumber"];
                break;
            }
        }
        
        return pinView;
    }
  
    
    return nil;
}

#pragma mark - Handle Action

- (void)startRecordTrack {
    if (self.currentRecord == nil)
    {
        self.currentRecord = [[AMapRouteRecord alloc] init];
    }
    // 清空轨迹路线
//    [self.mapView removeOverlays:self.tracedPolylines];
    [self setBackgroundModeEnable:YES];
}

//- (void)actionRecordAndStop
//{
//    if (self.isSaving)
//    {
//        NSLog(@"保存结果中。。。");
//        return;
//    }
//
//    self.isRecording = !self.isRecording;
//
//    if (self.isRecording)
//    {
//        [self.tipView showTip:@"Start recording"];
//        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
//
//        if (self.currentRecord == nil)
//        {
//            self.currentRecord = [[AMapRouteRecord alloc] init];
//        }
//
//        [self.mapView removeOverlays:self.tracedPolylines];
//        [self setBackgroundModeEnable:YES];
//    }
//    else
//    {
//        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
//        [self.tipView showTip:@"recording stoppod"];
//
//        [self setBackgroundModeEnable:NO];
//
//        [self actionSave];
//    }
//}

/// 还原轨迹路线最初始
- (void)actionSave
{
//    self.isRecording = NO;
//    self.isSaving = YES;
    [self.locationsArray removeAllObjects];
    
    [self.mapView removeOverlay:self.polyline];
    self.polyline = nil;
    
    // 全程请求trace
    [self.mapView removeOverlays:self.tracedPolylines];
    
    // 当前路径轨迹纠偏。。。。方法（为了防止轨迹纠偏删掉一些重要的位置数据  我觉得应该删除轨迹纠偏这一步，直接记录的就是实际走的坐标）
    [self queryTraceWithLocations:self.currentRecord.locations withSaving:YES];
}

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
}

#pragma mark - Utility

- (CLLocationCoordinate2D *)coordinatesFromLocationArray:(NSArray *)locations count:(NSUInteger *)count
{
    if (locations.count == 0)
    {
        return NULL;
    }
    
    *count = locations.count;
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * *count);
    
    int i = 0;
    for (CLLocation *location in locations)
    {
        coordinates[i] = location.coordinate;
        ++i;
    }
    
    return coordinates;
}

- (void)setBackgroundModeEnable:(BOOL)enable
{
    ///指定定位是否会被系统自动暂停 可直接设置为NO
    self.mapView.pausesLocationUpdatesAutomatically = !enable;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        ///是否允许后台定位。  直接设置为YES
        self.mapView.allowsBackgroundLocationUpdates = enable;
    }
}

- (void)queryTraceWithLocations:(NSArray<CLLocation *> *)locations withSaving:(BOOL)saving
{
    if (locations.count < 2) {
        return;
    }
    
    if (saving) {
        self.totalTraceLength = 0.0;
//        self.isSaving = NO;
        
        if ([self saveRoute])
        {
//            [self.tipView showTip:@"recording save succeeded"];
        }
//        else
//        {
//            [self.tipView showTip:@"recording save failed"];
//        }
    }
    
    [self addFullTrace:locations];
    
}

- (void)addFullTrace:(NSArray<CLLocation*> *)tracePoints
{
    MAPolyline *polyline = [self makePolylineWith:tracePoints];
    if(!polyline)
    {
        return;
    }
    
    [self.tracedPolylines addObject:polyline];
    [self.mapView addOverlay:polyline];
}


- (MAPolyline *)makePolylineWith:(NSArray<CLLocation*> *)tracePoints
{
    if(tracePoints.count < 2)
    {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        CLLocation *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.coordinate.latitude;
        pCur->longitude = p.coordinate.longitude;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:pCoords count:tracePoints.count];
    
    if(pCoords)
    {
        free(pCoords);
    }
    
    return polyline;
}

//- (void)updateUserlocationTitleWithDistance:(double)distance
//{
//    self.totalTraceLength += distance;
//    self.mapView.userLocation.title = [NSString stringWithFormat:@"距离：%.0f 米", self.totalTraceLength];
//}

- (BOOL)saveRoute
{
    if (self.currentRecord == nil || self.currentRecord.numOfLocations < 2)
    {
        return NO;
    }
    
    NSString *name = self.currentRecord.title;
    NSString *path = [FileHelper filePathWithName:name];
    
    BOOL result = [NSKeyedArchiver archiveRootObject:self.currentRecord toFile:path];
    
    self.currentRecord = nil;
    if (result) {
        NSLog(@"currentRecord 保存成功");
    } else {
        NSLog(@"currentRecord保存失败");
    }
    
    return result;
    
}

#pragma mark - Initialization

//- (void)initTipView
//{
//    self.locationsArray = [[NSMutableArray alloc] init];
//
//    self.tipView = [[TipView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.95, self.view.bounds.size.width, self.view.bounds.size.height*0.05)];
//
//    [self.view addSubview:self.tipView];
//}

- (void)initPolygonArea {
    NSMutableArray *polygonArr = [NSMutableArray array];
    // 主生产楼 西服厂
    NSArray *mainCoordsLatitude = @[@36.3447630000, @36.3450480000, @36.3456270000, @36.3453460000, @36.3449050000, @36.3448790000];
    NSArray *mainCoordsLongitude = @[@120.4336240000, @120.4313120000, @120.4314250000, @120.4334520000, @120.4333880000, @120.4336510000];
    
    CLLocationCoordinate2D *mainProductCoords = (CLLocationCoordinate2D *)malloc(mainCoordsLatitude.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < mainCoordsLatitude.count; i ++) {
        mainProductCoords[i].latitude = [mainCoordsLatitude[i] doubleValue];
        mainProductCoords[i].longitude = [mainCoordsLongitude[i] doubleValue];
    }
    MAPolygon *mainProductPolygon = [MAPolygon polygonWithCoordinates:mainProductCoords count:mainCoordsLongitude.count];
    mainProductPolygon.title = @"工厂";
    [polygonArr addObject:mainProductPolygon];
    
    // 行政楼
    CLLocationCoordinate2D coordsAdmin[4];
    coordsAdmin[0].latitude = 36.3453930000;
    coordsAdmin[0].longitude = 120.4336590000;
    
    coordsAdmin[1].latitude = 36.3449910000;
    coordsAdmin[1].longitude = 120.4335250000;
    
    coordsAdmin[2].latitude = 36.3449830000;
    coordsAdmin[2].longitude = 120.4336970000;
    
    coordsAdmin[3].latitude = 36.3453720000;
    coordsAdmin[3].longitude = 120.4338360000;
    MAPolygon *polygonWithAdmin = [MAPolygon polygonWithCoordinates:coordsAdmin count:4];
    polygonWithAdmin.title = @"办公室";
    [polygonArr addObject:polygonWithAdmin];
    
    
    // 停车场
    CLLocationCoordinate2D coordsPark[10];
    coordsPark[0].latitude = 36.3460280000;
    coordsPark[0].longitude = 120.4339970000;
    
    coordsPark[1].latitude = 36.3459760000;
    coordsPark[1].longitude = 120.4343480000;
    
    coordsPark[2].latitude = 36.3455480000;
    coordsPark[2].longitude = 120.4343000000;
    
    coordsPark[3].latitude = 36.3454840000;
    coordsPark[3].longitude = 120.4350080000;
    
    coordsPark[4].latitude = 36.3445030000;
    coordsPark[4].longitude = 120.4347670000;
    
    coordsPark[5].latitude = 36.3445760000;
    coordsPark[5].longitude = 120.4339670000;
    
    coordsPark[6].latitude = 36.3449180000;
    coordsPark[6].longitude = 120.4340000000;
    
    coordsPark[7].latitude = 36.3449390000;
    coordsPark[7].longitude = 120.4339080000;
    
    coordsPark[8].latitude = 36.3456390000;
    coordsPark[8].longitude = 120.4340690000;
    
    coordsPark[9].latitude = 36.3456820000;
    coordsPark[9].longitude = 120.4339460000;
    
    MAPolygon *polygonWithPark = [MAPolygon polygonWithCoordinates:coordsPark count:10];
    polygonWithPark.title = @"停车场";
    [polygonArr addObject:polygonWithPark];
    
    
    // 三号公寓
    CLLocationCoordinate2D coordsThreeRoom[12];
    coordsThreeRoom[0].latitude = 36.3457170000;
    coordsThreeRoom[0].longitude = 120.4331060000;
    
    coordsThreeRoom[1].latitude = 36.3456990000;
    coordsThreeRoom[1].longitude = 120.4333690000;
    
    coordsThreeRoom[2].latitude = 36.3456090000;
    coordsThreeRoom[2].longitude = 120.4333580000;
    
    coordsThreeRoom[3].latitude = 36.3455830000;
    coordsThreeRoom[3].longitude = 120.4335030000;
    
    coordsThreeRoom[4].latitude = 36.3456560000;
    coordsThreeRoom[4].longitude = 120.4335430000;
    
    coordsThreeRoom[5].latitude = 36.3456000000;
    coordsThreeRoom[5].longitude = 120.4338810000;
    
    coordsThreeRoom[6].latitude = 36.3457210000;
    coordsThreeRoom[6].longitude = 120.4338920000;
    
    coordsThreeRoom[7].latitude = 36.3457770000;
    coordsThreeRoom[7].longitude = 120.4336180000;
    
    coordsThreeRoom[8].latitude = 36.3458420000;
    coordsThreeRoom[8].longitude = 120.4336240000;
    
    coordsThreeRoom[9].latitude = 36.3458600000;
    coordsThreeRoom[9].longitude = 120.4334520000;
    
    coordsThreeRoom[10].latitude = 36.3458030000;
    coordsThreeRoom[10].longitude = 120.4334470000;
    
    coordsThreeRoom[11].latitude = 36.3458380000;
    coordsThreeRoom[11].longitude = 120.4331300000;
    
    MAPolygon *polygonWithThreeRoom = [MAPolygon polygonWithCoordinates:coordsThreeRoom count:12];
    polygonWithThreeRoom.title = @"公寓";
    [polygonArr addObject:polygonWithThreeRoom];
    
    
    /// 宾馆
    CLLocationCoordinate2D coordsHotel[4];
    coordsHotel[0].latitude = 36.3461285777;
    coordsHotel[0].longitude = 120.4340064526;
    
    coordsHotel[1].latitude = 36.3460767283;
    coordsHotel[1].longitude = 120.4344409704;
    
    coordsHotel[2].latitude = 36.3461545023;
    coordsHotel[2].longitude = 120.4344677925;
    
    coordsHotel[3].latitude = 36.3462020309;
    coordsHotel[3].longitude = 120.4340171814;
    
    MAPolygon *polygonWithHotel = [MAPolygon polygonWithCoordinates:coordsHotel count:4];
    polygonWithHotel.title = @"宾馆";
    [polygonArr addObject:polygonWithHotel];
    
    
    /// 食堂
    CLLocationCoordinate2D coordsCanteen[5];
    coordsCanteen[0].latitude = 36.3463618993;
    coordsCanteen[0].longitude = 120.4331052303;
    
    coordsCanteen[1].latitude = 36.3462193140;
    coordsCanteen[1].longitude = 120.4339474440;
    
    coordsCanteen[2].latitude = 36.3460464829;
    coordsCanteen[2].longitude = 120.4339206219;
    
    coordsCanteen[3].latitude = 36.3461674647;
    coordsCanteen[3].longitude = 120.4330730438;
    
    coordsCanteen[4].latitude = 36.3463489370;
    coordsCanteen[4].longitude = 120.4331052303;
    
    MAPolygon *polygonWithCanteen = [MAPolygon polygonWithCoordinates:coordsCanteen count:5];
    polygonWithCanteen.title = @"食堂";
    [polygonArr addObject:polygonWithCanteen];
    
    /// 2号公寓
    CLLocationCoordinate2D coordsTwoRoom[4];
    coordsTwoRoom[0].latitude = 36.3461761062;
    coordsTwoRoom[0].longitude = 120.4328048229;
    
    coordsTwoRoom[1].latitude = 36.3461501816;
    coordsTwoRoom[1].longitude = 120.4330354929;
    
    coordsTwoRoom[2].latitude = 36.3464483146;
    coordsTwoRoom[2].longitude = 120.4331052303;
    
    coordsTwoRoom[3].latitude = 36.3464699184;
    coordsTwoRoom[3].longitude = 120.4328745604;
    
    MAPolygon *polygonWithTwoRoom = [MAPolygon polygonWithCoordinates:coordsTwoRoom count:4];
    polygonWithTwoRoom.title = @"公寓";
    [polygonArr addObject:polygonWithTwoRoom];
    
    
    /// 书吧超市安全办公室浴池
    CLLocationCoordinate2D coordsMarket[4];
    coordsMarket[0].latitude = 36.3460335205;
    coordsMarket[0].longitude = 120.4326224327;
    
    coordsMarket[1].latitude = 36.3456446490;
    coordsMarket[1].longitude = 120.4325795174;
    
    coordsMarket[2].latitude = 36.3457742731;
    coordsMarket[2].longitude = 120.4314637184;
    
    coordsMarket[3].latitude = 36.3458779722;
    coordsMarket[3].longitude = 120.4314637184;
    
    coordsMarket[4].latitude = 36.3457483483;
    coordsMarket[4].longitude = 120.4324185848;
    
    coordsMarket[5].latitude = 36.3460421621;
    coordsMarket[5].longitude = 120.4325044155;
    
    MAPolygon *polygonWithMarket = [MAPolygon polygonWithCoordinates:coordsMarket count:6];
    polygonWithMarket.title = @"超市";
    [polygonArr addObject:polygonWithMarket];
    
    
    /// 5号公寓和后勤
    CLLocationCoordinate2D coordsFiveRoom[4];
    coordsFiveRoom[0].latitude = 36.3465952203;
    coordsFiveRoom[0].longitude = 120.4327940941;
    
    coordsFiveRoom[1].latitude = 36.3462149932;
    coordsFiveRoom[1].longitude = 120.4325258732;
    
    coordsFiveRoom[2].latitude = 36.3465520128;
    coordsFiveRoom[2].longitude = 120.4318177700;
    
    coordsFiveRoom[3].latitude = 36.3468976724;
    coordsFiveRoom[3].longitude = 120.4321074486;
    
    MAPolygon *polygonWithFiveRoom = [MAPolygon polygonWithCoordinates:coordsFiveRoom count:4];
    polygonWithFiveRoom.title = @"公寓";
    [polygonArr addObject:polygonWithFiveRoom];
    
    /// 西裤厂
    CLLocationCoordinate2D coordsPants[4];
    coordsPants[0].latitude = 36.3461372192;
    coordsPants[0].longitude = 120.4328262806;
    
    coordsPants[1].latitude = 36.3461026530;
    coordsPants[1].longitude = 120.4330515862;
    
    coordsPants[2].latitude = 36.3455927994;
    coordsPants[2].longitude = 120.4329442978;
    
    coordsPants[3].latitude = 36.3456100826;
    coordsPants[3].longitude = 120.4327297211;
    
    MAPolygon *polygonWithPants = [MAPolygon polygonWithCoordinates:coordsPants count:4];
    polygonWithPants.title = @"工厂";
    [polygonArr addObject:polygonWithPants];
    
    [_mapView addOverlays:polygonArr];
      

}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.zoomLevel = 17.0;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    self.mapView.showsIndoorMap = NO;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    self.traceManager = [[MATraceManager alloc] init];
}

- (void)initNavigationBar
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    UIBarButtonItem *beginItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play"] style:UIBarButtonItemStylePlain target:self action:@selector(actionRecordAndStop)];
    
//    self.navigationItem.rightBarButtonItem = beginItem;
    
//    self.isRecording = NO;
    
//    self.isSaving = NO;
}

- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"location_yes.png"];
    self.imageNotLocate = [UIImage imageNamed:@"location_no.png"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.view.bounds) - 90, 40, 40)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor whiteColor];
    self.locationBtn.layer.cornerRadius = 3;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [self.view addSubview:self.locationBtn];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"轨迹巡更";
    [self addBackButton];
//    [self initNavigationBar];
    
    [self initMapView];
    [self initPolygonArea];
//    [self initTipView];
    
    [self initLocationButton];
    
    self.tracedPolylines = [NSMutableArray array];
    self.tempTraceLocations = [NSMutableArray array];
    self.totalTraceLength = 0.0;
    
    
    self.searchCoordinate = (CLLocationCoordinate2D){0, 0};
    self.searchName = @"";
    
    [self initAnnotation];
    [self initTimer];
    /// 开始记录轨迹路线
    [self startRecordTrack];
    
    [self.view addSubview:self.recordEventBtn];
    [self.view bringSubviewToFront:self.recordEventBtn];
    [self.recordEventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.width.height.mas_equalTo(40);
        make.bottom.equalTo(self.view).offset(-100);
    }];
    
    [self changeShowPendingOrSecurityView];
}

/**
 显示保安或者待处理事件view
 */
- (void)changeShowPendingOrSecurityView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(80);
        make.centerY.equalTo(self.view);
    }];
    
    /// 阴影
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOpacity = 0.8f;
    view.layer.shadowRadius = 2.f;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    
    UIView *line = [[UIView alloc] init];
    [view addSubview:line];
    line.backgroundColor = RGBA(235, 235, 235, 1);
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(3);
        make.right.equalTo(view).offset(-3);
        make.height.mas_equalTo(0.8);
        make.centerY.equalTo(view);
    }];
    
    
    [view addSubview:self.securityBtn];
    [view addSubview:self.pendingBtn];
    [self.securityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(view);
        make.height.mas_equalTo(40);
    }];
    
    [self.pendingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(view);
        make.height.mas_equalTo(40);
    }];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

/**
 大头针显示
 */
- (void)initAnnotation {
    NSLog(@"大头针移除");
    if (self.searchCoordinate.latitude == 0 && self.searchCoordinate.longitude == 0) {
        // ************* 没有大头针气泡弹出 ************ //
        /// 移除所有大头针标注
        [self.mapView removeAnnotations:self.pinAnnotation];
        /// 移除所有大头针数据源数据
        [self.dataSourcePinCoordsInfo removeAllObjects];
        /// 移除大头针标注组
        [self.pinAnnotation removeAllObjects];
    } else {
        
        /// 移除大头针标注(对于已经显示气泡的大头针不做处理)
        NSArray *tempPin = [self.pinAnnotation mutableCopy];
        for (MAPointAnnotation *annotation in tempPin) {
            if (annotation.coordinate.latitude == self.searchCoordinate.latitude && annotation.coordinate.longitude == self.searchCoordinate.longitude) {
                self.searchAnnotation = annotation;
            } else {
                [self.pinAnnotation removeObject:annotation];
                [self.mapView removeAnnotation:annotation];
            }
        }
        /// 移除大头针数据源数据
        NSArray *tempDataSource = [self.dataSourcePinCoordsInfo mutableCopy];
        for (NSDictionary *dic in tempDataSource) {
            if (!([dic[@"longitude"] doubleValue] == self.searchCoordinate.longitude && [dic[@"latitude"] doubleValue] == self.searchCoordinate.latitude)) {
                [self.dataSourcePinCoordsInfo removeObject:dic];
            }
        }
    }
    
    weakObjc(self);
    [K_NetWorkClient getUserLocationInfoSuccess:^(id responseObject) {
        NSLog(@"大头针请求成功:%@", responseObject);
        NSDictionary *responseDic = responseObject;
        if ([responseDic[@"code"] integerValue] == 200) {
            NSLog(@"请求成功");
            NSArray *data = responseDic[@"data"];
            /// 大头针经纬度坐标
            CLLocationCoordinate2D *coords = malloc(data.count*sizeof(CLLocationCoordinate2D));
            for (NSInteger i = 0; i < data.count; i ++) {
                if ([data[i][@"displayName"] isEqualToString:self.searchName]) {
                    coords[i].latitude = self.searchCoordinate.latitude;
                    coords[i].longitude = self.searchCoordinate.longitude;
                    continue;
                }
                coords[i].latitude = [data[i][@"latitude"] doubleValue];
                coords[i].longitude = [data[i][@"longitude"] doubleValue];
            }
            
            for (NSDictionary *everyone in data) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                if ([everyone[@"displayName"] isEqualToString:self.searchName]) {
                    continue;
                }
                [dic setValue:everyone[@"displayName"] forKey:@"name"];
                [dic setValue:everyone[@"employeeNumber"] forKey:@"employeeNumber"];
                [dic setValue:@"警察" forKey:@"imageName"];
                [dic setValue:everyone[@"longitude"] forKey:@"longitude"];
                [dic setValue:everyone[@"latitude"] forKey:@"latitude"];
                [weakself.dataSourcePinCoordsInfo addObject:dic];
            }
            
            for (NSInteger i = 0; i < data.count; i ++) {
                MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
                pointAnnotation.coordinate = coords[i];
//                pointAnnotation.title = [NSString stringWithFormat:@"coord:%d", i];
                [weakself.pinAnnotation addObject:pointAnnotation];
            }
            
            if (self.searchCoordinate.latitude == 0 && self.searchCoordinate.longitude == 0) {
                /// 没有弹出气泡大头针  添加所有的大头针
                [weakself.mapView addAnnotations:weakself.pinAnnotation];
            } else {
                
                for (MAPointAnnotation *annotation in weakself.pinAnnotation) {
                    if (!(annotation.coordinate.latitude == self.searchCoordinate.latitude && annotation.coordinate.longitude == self.searchCoordinate.longitude)) {
                        [self.mapView addAnnotation:annotation];
                    }
                }
            }
            
        }
    } failure:^(NSError *error) {
        NSLog(@"大头针错误：%@", error);
    }];
    
}

- (void)initTimer {
    /// 每隔一分钟上传位置坐标集(已经移至AppDelegate)  每隔一分钟获取其他人员最新位置坐标(在此实现)
    self.timer = [HWWeakTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    
}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"+++获取大头针timerAction+++");
    [self initAnnotation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - 记录事件
- (void)recordEventBtn:(UIButton *)sender {
    NSLog(@"点击了记录事件 button");
    
    K_RecordEventInfoViewController *record = [[K_RecordEventInfoViewController alloc] initWithNibName:@"K_RecordEventInfoViewController" bundle:nil];
    record.location = SharedAppDelegate.locationInfo.coordinate;
    
    [self.navigationController pushViewController:record animated:YES];
}

#pragma mark - 显示保安
- (void)securityClick {
    
}

#pragma mark - 显示待处理事件
- (void)pendingClick {
    
}

#pragma mark - Lazy init
- (NSMutableArray *)pinAnnotation {
    if (!_pinAnnotation) {
        _pinAnnotation = [NSMutableArray array];
    }
    return _pinAnnotation;
}

- (NSMutableArray *)dataSourcePinCoordsInfo {
    if (!_dataSourcePinCoordsInfo) {
        _dataSourcePinCoordsInfo = [NSMutableArray array];
    }
    return _dataSourcePinCoordsInfo;
}

- (UIButton *)recordEventBtn {
    if (!_recordEventBtn) {
        _recordEventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordEventBtn setImage:[UIImage imageNamed:@"事件记录"] forState:UIControlStateNormal];
        _recordEventBtn.layer.cornerRadius = 20;
        _recordEventBtn.layer.masksToBounds = YES;
        _recordEventBtn.layer.borderColor = NavigationBarBGColor.CGColor;
        _recordEventBtn.layer.borderWidth = 1.0f;
        [_recordEventBtn addTarget:self action:@selector(recordEventBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordEventBtn;
}

- (UIButton *)securityBtn {
    if (!_securityBtn) {
        _securityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_securityBtn setImage:[UIImage imageNamed:@"保安"] forState:UIControlStateNormal];
        [_recordEventBtn addTarget:self action:@selector(securityClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _securityBtn;
}

- (UIButton *)pendingBtn {
    if (!_pendingBtn) {
        _pendingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pendingBtn setImage:[UIImage imageNamed:@"待处理"] forState:UIControlStateNormal];
        [_pendingBtn addTarget:self action:@selector(pendingClick) forControlEvents:UIControlEventTouchUpInside];
//        [_pendingBtn setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    return _pendingBtn;
}

@end
