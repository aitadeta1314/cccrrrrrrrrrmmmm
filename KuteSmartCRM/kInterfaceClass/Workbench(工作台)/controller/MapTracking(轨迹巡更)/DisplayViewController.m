
//
//  DisplayViewController.m
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "DisplayViewController.h"
#import "AMapRouteRecord.h"
#import "K_InputTimeView.h"
#import "K_DatePickerView.h"

@interface DisplayViewController()<MAMapViewDelegate>
{
    CLLocationCoordinate2D *_traceCoordinate;
    NSUInteger _traceCount;
    CFTimeInterval _duration;  
}

@property (nonatomic, strong) AMapRouteRecord *record;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAAnimatedAnnotation *myLocation;

@property (nonatomic, assign) BOOL isPlaying;

@end


@implementation DisplayViewController


#pragma mark - Utility

- (void)showRoute
{
    if (self.record == nil || [self.record numOfLocations] == 0)
    {
        NSLog(@"invaled route");
    }
    
    [self initDisplayRoutePolyline];

    [self initDisplayTrackingCoords];
}

#pragma mark - Interface

- (void)setRecord:(AMapRouteRecord *)record
{
    if (_record == record)
    {
        return;
    }
    
    if (self.isPlaying)
    {
        [self actionPlayAndStop];
    }
    
    _record = record;
}

#pragma mark - mapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isEqual:self.myLocation]) {
        
        static NSString *annotationIdentifier = @"myLcoationIdentifier";
        
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"car1"];
        annotationView.canShowCallout = NO;
        
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"lcoationIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        poiAnnotationView.canShowCallout = YES;
//        poiAnnotationView.image = [UIImage imageNamed: @"car1"];
        return nil;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
//        MAMultiColoredPolylineRenderer *view = [[MAMultiColoredPolylineRenderer alloc] initWithPolyline:overlay];
//        view.gradient = YES;
//        view.lineWidth = 2;
//        view.strokeColors = @[[UIColor greenColor], [UIColor redColor]];
//
//        return view;
        MAPolylineRenderer *view = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        view.lineWidth = 5.0;
        view.strokeColor = [UIColor redColor];
        return view;
    }
    
    //多边形
    if ([overlay isKindOfClass:[MAPolygon class]])
    {
        
        MAPolygonRenderer *pol = [[MAPolygonRenderer alloc] initWithPolygon:overlay];
        
        pol.lineWidth = 1.f;
        NSString *areaStr = overlay.title;
        
        if ([areaStr isEqualToString:@"停车场"]) {
            pol.fillColor = RGBA(88, 132, 237, 1);    // 绿色
        } else if ([areaStr isEqualToString:@"办公室"]) {
            pol.fillColor = RGBA(49, 98, 206, 1);    // 蓝色
        } else if ([areaStr isEqualToString:@"工厂"]) {
            pol.fillColor = RGBA(234, 94, 62, 1);// 灰色
        } else if ([areaStr isEqualToString:@"超市"]) {
            pol.fillColor = RGBA(246, 186, 89, 1);  // 黄色
        } else if ([areaStr isEqualToString:@"宾馆"]) {
            pol.fillColor = RGBA(58, 169, 241, 1);  // 紫色
        } else if ([areaStr isEqualToString:@"公寓"]) {
            pol.fillColor = RGBA(128, 86, 210, 1);      // 黑色
        } else if ([areaStr isEqualToString:@"食堂"]) {
            pol.fillColor = RGBA(97, 214, 129, 1);  // 橙色
        }
        
        
        pol.lineDashType = kMALineDashTypeNone;
        return pol;
        
    }
    
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if (view.annotation == self.myLocation)
    {
        [mapView selectAnnotation:self.myLocation animated:NO];
    }
}

#pragma mark - Action

- (void)actionPlayAndStop
{
    if (self.record == nil)
    {
        return;
    }
    
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying)
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
        if (self.myLocation == nil)
        {
            self.myLocation = [[MAAnimatedAnnotation alloc] init];
            self.myLocation.title = @"AMap";
            self.myLocation.coordinate = [self.record startLocation].coordinate;
            
            [self.mapView addAnnotation:self.myLocation];
            
            // 选中myLocation，不会被重用移除。
            [self.mapView selectAnnotation:self.myLocation animated:NO];
        }
        
        
        __weak typeof(self) weakSelf = self;
        // 添加移动动画
        [self.myLocation addMoveAnimationWithKeyCoordinates:_traceCoordinate count:_traceCount withDuration:_duration withName:nil completeCallback:^(BOOL isFinished) {
            
            if (isFinished) {
                [weakSelf actionPlayAndStop];
            }
        }];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        
        for(MAAnnotationMoveAnimation *animation in [self.myLocation allMoveAnimations]) {
            [animation cancel];
        }
        [self.myLocation setCoordinate:_traceCoordinate[0]];
        [self.myLocation setMovingDirection:0.0];
    }
}

#pragma mark - Initialazation

- (void)initToolBar
{
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionPlayAndStop)];
    self.navigationItem.rightBarButtonItem = playItem;
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsIndoorMap = NO;
    self.mapView.zoomLevel = 17.f;
    [self.view addSubview:self.mapView];
}

- (void)initDisplayRoutePolyline
{
    NSArray<CLLocation *> *tracePoints = self.record.locations;
//    NSArray<MATracePoint *> *tracePoints = self.record.tracedLocations;
    
    if (tracePoints.count < 2)
    {
        return;
    }
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.firstObject.coordinate.latitude, tracePoints.firstObject.coordinate.longitude);
    startPoint.title = @"start";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.lastObject.coordinate.latitude, tracePoints.lastObject.coordinate.longitude);
    endPoint.title = @"end";
    [self.mapView addAnnotation:endPoint];
    
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(tracePoints.count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < tracePoints.count; i++)
    {
        coords[i] = CLLocationCoordinate2DMake(tracePoints[i].coordinate.latitude, tracePoints[i].coordinate.longitude);
    }
    
    NSInteger drawIndex = tracePoints.count - 1;
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:coords count:tracePoints.count drawStyleIndexes:@[@(0), @(drawIndex)]];
    [self.mapView addOverlay:polyline];
    
    [self.mapView showOverlays:self.mapView.overlays edgePadding:UIEdgeInsetsMake(200, 50, 200, 50) animated:NO];
    
    if (coords)
    {
        free(coords);
    }

}

- (void)initDisplayTrackingCoords
{
    NSArray<CLLocation *> *points = self.record.locations;
//    NSArray<MATracePoint *> *points = self.record.tracedLocations;
    _traceCount = points.count;
    
    if (_traceCount < 2)
    {
        return;
    }
    
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * _traceCount);
    
    for (int i = 0; i < _traceCount; ++i)
    {
        coords[i] = CLLocationCoordinate2DMake(points[i].coordinate.latitude, points[i].coordinate.longitude);
    }
    
    _traceCoordinate = coords;
    _duration = _record.totalDuration / 2.0;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"轨迹回放";
    
    [self initMapView];
    
    [self initPolygonArea];
    
    [self initToolBar];
    
    [self showRoute];
    
    
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


- (void)dealloc
{
    if (_traceCoordinate)
    {
        free(_traceCoordinate);
        _traceCoordinate = NULL;
    }
}

@end
