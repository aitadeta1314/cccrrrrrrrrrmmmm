//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "K_MapLocationViewController.h"
#import "TipView.h"
#import "AMapRouteRecord.h"
#import "FileHelper.h"
#import "K_CustomPinView.h"
#import "HWWeakTimer.h"

#define kTempTraceLocationCount 20

@interface K_MapLocationViewController() <MAMapViewDelegate>
/**
 NSTimer
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 大头针坐标
 */
@property (nonatomic, strong) NSMutableArray *pinAnnotation;
/**
 数据源大头针坐标信息
 */
@property (nonatomic, strong) NSMutableArray *dataSourcePinCoordsInfo;

@property (nonatomic, strong) MAMapView *mapView;
/**
 轨迹纠偏管理类
 */
@property (nonatomic, strong) MATraceManager *traceManager;

// 不需要
@property (nonatomic, strong) TipView *tipView;
// 暂不需要
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;

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
    
    if (!self.isRecording)
    {
        return;
    }
    
    if (userLocation.location.horizontalAccuracy < 100 && userLocation.location.horizontalAccuracy > 0)
    {
        double lastDis = [userLocation.location distanceFromLocation:self.currentRecord.endLocation];
        
        if (lastDis < 0.0 || lastDis > 10)
        {
            [self.locationsArray addObject:userLocation.location];
            
            //            NSLog(@"date: %@,now :%@",userLocation.location.timestamp, [NSDate date]);
            [self.tipView showTip:[NSString stringWithFormat:@"has got %ld locations",self.locationsArray.count]];
            
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
    
    //    [self.statusView showStatusWith:userLocation.location];
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
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        view.lineWidth = 10.0;
        view.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
        return view;
    }
    
    //多边形
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        
        MAPolygonRenderer *pol = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        pol.lineWidth = 5.f;
        
        pol.strokeColor =  [UIColor blueColor];
        
        pol.fillColor = [UIColor colorWithRed:158/255.0 green:230/255.0 blue:252/255.0 alpha:0.5];
        
        pol.lineDashType = kMALineDashTypeDot;//YES表示虚线绘制，NO表示实线绘制
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
        for (NSDictionary *subDic in self.dataSourcePinCoordsInfo) {
            double latitude = [[subDic valueForKey:@"latitude"] doubleValue];
            double longitude = [[subDic valueForKey:@"longitude"] doubleValue];
            if (annotation.coordinate.latitude == latitude && annotation.coordinate.longitude == longitude) {
                
                pinView.portraitUrl = [NSString stringWithFormat:@"www"];
                pinView.name = [subDic valueForKey:@"name"];
                break;
            }
        }
        
        return pinView;
    }
  
    
    return nil;
}

#pragma mark - Handle Action

- (void)actionRecordAndStop
{
    if (self.isSaving)
    {
        NSLog(@"保存结果中。。。");
        return;
    }
    
    self.isRecording = !self.isRecording;
    
    if (self.isRecording)
    {
        [self.tipView showTip:@"Start recording"];
        self.navigationItem.rightBarButtonItems[1].image = [UIImage imageNamed:@"icon_stop.png"];
        
        if (self.currentRecord == nil)
        {
            self.currentRecord = [[AMapRouteRecord alloc] init];
        }
        
        [self.mapView removeOverlays:self.tracedPolylines];
        [self setBackgroundModeEnable:YES];
    }
    else
    {
        self.navigationItem.rightBarButtonItems[1].image = [UIImage imageNamed:@"icon_play.png"];
        [self.tipView showTip:@"recording stoppod"];
        
        [self setBackgroundModeEnable:NO];
        
        [self actionSave];
    }
}

- (void)actionSave
{
    self.isRecording = NO;
    self.isSaving = YES;
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

- (void)actionShowList
{
//    UIViewController *recordController = [[RecordViewController alloc] init];
//    recordController.title = @"Records";
//
//    [self.navigationController pushViewController:recordController animated:YES];
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
    self.mapView.pausesLocationUpdatesAutomatically = !enable;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        self.mapView.allowsBackgroundLocationUpdates = enable;
    }
}

- (void)queryTraceWithLocations:(NSArray<CLLocation *> *)locations withSaving:(BOOL)saving
{
    if (locations.count < 2) {
        return;
    }
    
    NSMutableArray *mArr = [NSMutableArray array];
    for(CLLocation *loc in locations)
    {
        MATraceLocation *tLoc = [[MATraceLocation alloc] init];
        tLoc.loc = loc.coordinate;
        
        tLoc.speed = loc.speed * 3.6; //m/s  转 km/h
        tLoc.time = [loc.timestamp timeIntervalSince1970] * 1000;
        tLoc.angle = loc.course;
        [mArr addObject:tLoc];
    }
    
    __weak typeof(self) weakSelf = self;
    // 获取纠偏后的经纬度点集
    __unused NSOperation *op = [self.traceManager queryProcessedTraceWith:mArr type:-1 processingCallback:nil  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        
        NSLog(@"trace query done!");
        
        if (saving) {
            weakSelf.totalTraceLength = 0.0;
            [weakSelf.currentRecord updateTracedLocations:points]; // 更新轨迹坐标  // 我们不需要纠偏之后的坐标，所以这里也就不需要更新了。
            weakSelf.isSaving = NO;
            
//            [weakSelf saveRoute];
            if ([weakSelf saveRoute])
            {
                [weakSelf.tipView showTip:@"recording save succeeded"];
            }
            else
            {
                [weakSelf.tipView showTip:@"recording save failed"];
            }
        }
        
        [weakSelf updateUserlocationTitleWithDistance:distance];
        [weakSelf addFullTrace:points];
        
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        
        NSLog(@"query trace point failed :%@", errorDesc);
        if (saving) {
            weakSelf.isSaving = NO;
        }
    }];
    
}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints
{
    MAPolyline *polyline = [self makePolylineWith:tracePoints];
    if(!polyline)
    {
        return;
    }
    
    [self.tracedPolylines addObject:polyline];
    [self.mapView addOverlay:polyline];
}

- (MAPolyline *)makePolylineWith:(NSArray<MATracePoint*> *)tracePoints
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
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:pCoords count:tracePoints.count];
    
    if(pCoords)
    {
        free(pCoords);
    }
    
    return polyline;
}

- (void)updateUserlocationTitleWithDistance:(double)distance
{
    self.totalTraceLength += distance;
    self.mapView.userLocation.title = [NSString stringWithFormat:@"距离：%.0f 米", self.totalTraceLength];
}

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

- (void)initTipView
{
    self.locationsArray = [[NSMutableArray alloc] init];

    self.tipView = [[TipView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.95, self.view.bounds.size.width, self.view.bounds.size.height*0.05)];

    [self.view addSubview:self.tipView];
}

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
    
    UIBarButtonItem *beginItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play"] style:UIBarButtonItemStylePlain target:self action:@selector(actionRecordAndStop)];
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list"] style:UIBarButtonItemStylePlain target:self action:@selector(actionShowList)];
    
    NSArray *array = [[NSArray alloc] initWithObjects:listButton, beginItem, nil];
    self.navigationItem.rightBarButtonItems = array;
    
    self.isRecording = NO;
    
    self.isSaving = NO;
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
    [self initNavigationBar];
    
    [self initMapView];
    [self initPolygonArea];
    [self initTipView];
    
    [self initLocationButton];
    
    self.tracedPolylines = [NSMutableArray array];
    self.tempTraceLocations = [NSMutableArray array];
    self.totalTraceLength = 0.0;
    
    [self initAnnotation];
    [self initTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

/**
 大头针显示     测试数据呢 ！!--—__---
 */
- (void)initAnnotation {
    // 大头针位置经纬度
    CLLocationCoordinate2D coords[5] = {
        {36.3448360000,120.4336480000},
        {36.3453520000,120.4338490000},
        {36.3454730000,120.4329640000},
        {36.3459570000,120.4331250000},
        {36.3456720000,120.4321810000}
    };
    
    for (int i = 0; i < 5; i ++) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = coords[i];
        pointAnnotation.title = [NSString stringWithFormat:@"coord:%d", i];
        [self.pinAnnotation addObject:pointAnnotation];
    }
    [self.mapView addAnnotations:self.pinAnnotation];
    
    NSArray *nameArr = @[@"张三",@"李四",@"王五",@"赵六",@"王八"];
    for (int i = 0; i < 5; i ++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:nameArr[i] forKey:@"name"];
        [dic setValue:@"emoji-test" forKey:@"imageName"];
        [dic setValue:[NSNumber numberWithDouble:coords[i].longitude] forKey:@"longitude"];
        [dic setValue:[NSNumber numberWithDouble:coords[i].latitude] forKey:@"latitude"];
        [self.dataSourcePinCoordsInfo addObject:dic];
    }
}

- (void)initTimer {
    /// 每隔一分钟上传位置坐标集  每隔一分钟获取最新位置坐标
    self.timer = [HWWeakTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    
}

- (void)timerAction:(NSTimer *)timer {
    NSLog(@"timer action");
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    NSLog(@"dealloc");
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

@end
