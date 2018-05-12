
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

@interface DisplayViewController()<MAMapViewDelegate, UITextFieldDelegate, KDatePickerViewDelegate>
{
    CLLocationCoordinate2D *_traceCoordinate;
    NSUInteger _traceCount;
    CFTimeInterval _duration;
}

/**
 时间选择器
 */
@property (nonatomic, strong) K_DatePickerView *dateView;

@property (nonatomic, strong) AMapRouteRecord *record;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAAnimatedAnnotation *myLocation;

@property (nonatomic, assign) BOOL isPlaying;

/**
 时间段view
 */
@property (nonatomic, strong) K_InputTimeView *timeView;
/**
 beginTextField选中弹出timePicker
 */
@property (nonatomic, assign) BOOL beginTFSelected;

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

#pragma mark - KDatePickerViewDelegate
/**
 保存

 @param timer 保存
 */
- (void)saveClick:(NSString *)timer {
    if (self.beginTFSelected) {
        
        self.timeView.beginTextfield.text = timer;
    } else {
        self.timeView.endTextfield.text = timer;
    }    
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
        self.dateView = nil;
    }];
}

/**
 取消
 */
- (void)cancelClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
        
        self.dateView = nil;
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.dateView == nil) {
        K_DatePickerView *dateView = [[K_DatePickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300)];
        dateView.delegate = self;
        dateView.title = @"请选择时间";
        [self.view addSubview:dateView];
        self.dateView = dateView;
    }
    if (textField == self.timeView.beginTextfield) {
        self.beginTFSelected = YES;
    } else {
        self.beginTFSelected = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.dateView.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300);
        [self.dateView show];
    }];
    
    
    return NO;
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
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAMultiColoredPolylineRenderer *view = [[MAMultiColoredPolylineRenderer alloc] initWithPolyline:overlay];
        view.gradient = YES;
        view.lineWidth = 8;
        view.strokeColors = @[[UIColor greenColor], [UIColor redColor]];
        
        return view;
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
    self.mapView.delegate = self;
    self.mapView.showsIndoorMap = NO;
    [self.view addSubview:self.mapView];
}

- (void)initDisplayRoutePolyline
{
    NSArray<MATracePoint *> *tracePoints = self.record.tracedLocations;
    
    if (tracePoints.count < 2)
    {
        return;
    }
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.firstObject.latitude, tracePoints.firstObject.longitude);
    startPoint.title = @"start";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = CLLocationCoordinate2DMake(tracePoints.lastObject.latitude, tracePoints.lastObject.longitude);
    endPoint.title = @"end";
    [self.mapView addAnnotation:endPoint];
    
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(tracePoints.count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < tracePoints.count; i++)
    {
        coords[i] = CLLocationCoordinate2DMake(tracePoints[i].latitude, tracePoints[i].longitude);
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
    NSArray<MATracePoint *> *points = self.record.tracedLocations;
    _traceCount = points.count;
    
    if (_traceCount < 2)
    {
        return;
    }
    
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * _traceCount);
    
    for (int i = 0; i < _traceCount; ++i)
    {
        coords[i] = CLLocationCoordinate2DMake(points[i].latitude, points[i].longitude);
    }
    
    _traceCoordinate = coords;
    _duration = _record.totalDuration / 2.0;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackButton];
    self.beginTFSelected = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"轨迹回放";
    
    [self initMapView];
    
    [self initToolBar];
    
    [self showRoute];
    
    [self.mapView addSubview:self.timeView];
}

- (void)dealloc
{
    if (_traceCoordinate)
    {
        free(_traceCoordinate);
        _traceCoordinate = NULL;
    }
}

- (K_InputTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[K_InputTimeView alloc] initWithFrame:CGRectMake(10, 10, 200, 150)];
        _timeView.beginTextfield.delegate = self;
        _timeView.endTextfield.delegate = self;
    }
    return _timeView;
}

@end
