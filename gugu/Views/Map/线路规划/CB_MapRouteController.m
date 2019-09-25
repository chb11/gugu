//
//  CB_MapRouteController.m
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MapRouteController.h"
#import "CB_RouteTypeView.h"
#import "CB_RouteBottomView.h"
#import "MANaviRoute.h"
#import "CommonUtility.h"
#import "CB_PianHaoView.h"
#import "NaviPointAnnotation.h"
#import "MultiDriveRoutePolyline.h"
#import "SelectableOverlay.h"
#import "CB_NaviController.h"
#import "CB_BusRouteView.h"

#define AMapNaviRoutePolylineDefaultWidth  30.f



@interface CB_MapRouteController ()<MAMapViewDelegate,AMapNaviDriveManagerDelegate,AMapNaviRideManagerDelegate,AMapNaviWalkManagerDelegate,AMapSearchDelegate>
@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) CB_RouteTypeView *typeView;
@property (nonatomic,strong) CB_RouteBottomView *bottomView;
@property (nonatomic,assign) __block CB_ROUTE_TYPE routeType;//导航方式
@property (nonatomic, strong) NSMutableArray *routeIndicatorInfoArray;

@property (nonatomic,strong) CB_PianHaoView *pianhaoView;

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,assign) __block AMapNaviDrivingStrategy strategy;

@property (nonatomic, strong) AMapNaviRideManager *rideManager;
@property (nonatomic, strong) AMapNaviWalkManager *walkanager;

@property (nonatomic,strong) CB_BusRouteView *busRouteView;
@property (nonatomic,strong) AMapRoute *busRoute;
@property (nonatomic,strong) MANaviRoute *abusRoute;

@property (nonatomic,assign) NSInteger DriverouteID;
@end

@implementation CB_MapRouteController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initProperties];
    [self initMapView];
    [self initDriveManager];
    [self initUI];
    [self initData];
    [self initAction];
    [self action_searchRoutes];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initAnnotations];
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];
    [self.rideManager setDelegate:self];
    [self.walkanager setDelegate:self];
    
    [self initDriveManager];
}

-(void)viewDidLayoutSubviews{
//    self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-150-BottomPadding-NavBarHeight, SCREEN_WIDTH, 150);
    self.typeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.typeView az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
}

- (void)dealloc {
//    BOOL success = [AMapNaviDriveManager destroyInstance];
//    NSLog(@"单例是否销毁成功 : %d",success);
}

- (void)initProperties {
    self.startPoint = [AMapNaviPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    self.endPoint = [AMapNaviPoint locationWithLatitude:self.endCoordinate.latitude longitude:self.endCoordinate.longitude];
    //为了方便展示驾车多路径规划，选择了固定的起终点
    self.routeIndicatorInfoArray = [NSMutableArray array];
}

- (void)initMapView {
    if (self.mapView == nil)  {
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0,40,SCREEN_WIDTH, SCREEN_HEIGHT-40)];
        [self.mapView setDelegate:self];
        [self.view addSubview:self.mapView];
    }
}

- (void)initDriveManager {
    //请在 dealloc 函数中执行 [AMapNaviDriveManager destroyInstance] 来销毁单例
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];
}

- (void)initAnnotations {
    
    NaviPointAnnotation *beginAnnotation = [[NaviPointAnnotation alloc] init];
    [beginAnnotation setCoordinate:CLLocationCoordinate2DMake(self.startPoint.latitude, self.startPoint.longitude)];
    beginAnnotation.title = @"起始点";
    beginAnnotation.navPointType = NaviPointAnnotationStart;
    
    [self.mapView addAnnotation:beginAnnotation];
    
    NaviPointAnnotation *endAnnotation = [[NaviPointAnnotation alloc] init];
    [endAnnotation setCoordinate:CLLocationCoordinate2DMake(self.endPoint.latitude, self.endPoint.longitude)];
    endAnnotation.title = @"终点";
    endAnnotation.navPointType = NaviPointAnnotationEnd;
    
    [self.mapView addAnnotation:endAnnotation];
}


-(void)initUI{
    self.title = @"导航规划";
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT-40)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    [self.view addSubview:self.typeView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.busRouteView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.backView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pianhaoView];
    [[UIApplication sharedApplication].keyWindow sendSubviewToBack:self.backView];
    [[UIApplication sharedApplication].keyWindow sendSubviewToBack:self.pianhaoView];
}

-(void)initData{
    self.routeType = CB_ROUTE_TYPE_DEIVE;
}

-(AMapNaviDrivingStrategy)strategy{
    
    return [self.pianhaoView strategyWithIsMultiple:YES];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.bottomView.block_click_go = ^{
        [weakSelf action_goNavi];
    };
    self.bottomView.block_click_pianhao = ^{
        [weakSelf action_showPianhao];
    };
    self.bottomView.block_changeRoute = ^(NSInteger currindex) {
        [weakSelf selectDriveNaviRouteWithID:currindex];
    };
    self.typeView.block_routeType = ^(NSInteger type) {
        weakSelf.routeType = type;
    };
    self.pianhaoView.block_choosePianHao = ^(AMapNaviDrivingStrategy strategy) {
        [weakSelf action_searchRoutes];
        [weakSelf closeBack];
    };
    self.busRouteView.block_choosebusLine = ^(NSInteger index) {
        [weakSelf showBusNaviRoutesONMapWith:index];
    };
}

#pragma mark - 事件

-(void)setRouteType:(CB_ROUTE_TYPE)routeType{
    _routeType = routeType;
    [self action_searchRoutes];
}

-(void)action_searchRoutes{
    [self action_hideBottom];
    [self action_hideBusRoute];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    if (self.routeType == CB_ROUTE_TYPE_DEIVE) {
        [self action_driverRouteSearch];
        [self.bottomView action_showPianHao:YES];
    }
    if (self.routeType == CB_ROUTE_TYPE_RIDE) {
        [self action_rideRouteSearch];
        [self.bottomView action_showPianHao:NO];
    }
    if (self.routeType == CB_ROUTE_TYPE_WALK) {
        [self action_walkRouteSearch];
        [self.bottomView action_showPianHao:NO];
    }
    if (self.routeType == CB_ROUTE_TYPE_BUS) {
        [self action_busRouteSearch];
    }
}

-(void)action_driverRouteSearch{
    //进行多路径规划
    [[AMapNaviDriveManager sharedInstance] setMultipleRouteNaviMode:YES];
    [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithEndPoints:@[self.endPoint] wayPoints:nil drivingStrategy:self.strategy];
}

-(void)action_rideRouteSearch{
    if (!self.rideManager) {
        self.rideManager = [[AMapNaviRideManager alloc] init];
        [self.rideManager setDelegate:self];
    }
    [self.rideManager calculateRideRouteWithEndPoint:self.endPoint];
}

-(void)action_walkRouteSearch{
    if (!self.walkanager) {
        self.walkanager = [[AMapNaviWalkManager alloc] init];
        [self.walkanager setDelegate:self];
    }
    [self.walkanager calculateWalkRouteWithEndPoints:@[self.endPoint]];
}

-(void)action_busRouteSearch{
    AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
    
    navi.requireExtension = YES;
    navi.city             = @"beijing";
    //  //终点城市
    //  navi.destinationCity  = @"wuhan";
    
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                           longitude:self.startCoordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:self.endPoint.latitude
                                                longitude:self.endPoint.longitude];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    [self.search AMapTransitRouteSearch:navi];
    
}


-(void)action_goNavi{
    CB_NaviController *page = [CB_NaviController new];
    page.DriverouteID = self.DriverouteID;
    page.strategy = self.strategy;
    page.routeType = self.routeType;
    page.startPoint = self.startPoint;
    page.endPoint = self.endPoint;
    page.rideManager = self.rideManager;
    page.walkManager = self.walkanager;
    page.chatType = self.chatType;
    page.sessionId = self.sessionId;
    page.isGroup = self.isGroup;
    page.model = self.model;
    page.SendId = self.SendId;
    page.groupModel = self.groupModel;
    page.friendModel = self.friendModel;
    page.isFromChat = self.isFromChat;
    page.isGroupNavi = self.isGroupNavi;
    [self.navigationController pushViewController:page animated:YES];

}

-(void)action_showBottom{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-150-BottomPadding-NavBarHeight, SCREEN_WIDTH, 150);
    }];
}

-(void)action_hideBottom{
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150);
    }];
}

-(void)action_showPianhao{
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.backView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.pianhaoView];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 1;
        self.pianhaoView.frame = CGRectMake(0, SCREEN_HEIGHT-150-BottomPadding, SCREEN_WIDTH, 150);
    }];
}

-(void)action_hidePianhao{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.pianhaoView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150);
    }completion:^(BOOL finished) {
        [[UIApplication sharedApplication].keyWindow sendSubviewToBack:self.backView];
        [[UIApplication sharedApplication].keyWindow sendSubviewToBack:self.pianhaoView];
    }];
}

-(void)action_showBusRoute{
    [UIView animateWithDuration:0.3 animations:^{
        self.busRouteView.frame = CGRectMake(0, SCREEN_HEIGHT-450-BottomPadding, SCREEN_WIDTH, 450);
    }completion:^(BOOL finished) {
        
    }];
}

-(void)action_hideBusRoute{
    if (self.abusRoute) {
        [self.abusRoute removeFromMapView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.busRouteView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 450);
    }completion:^(BOOL finished) {
        
    }];
}

-(void)closeBack{
    [self action_hidePianhao];
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.alpha = 0;
    }];
}

-(void)action_refershCollectionRote{
    
    if (self.routeType == CB_ROUTE_TYPE_DEIVE) {
        NSDictionary *dict = [AMapNaviDriveManager sharedInstance].naviRoutes;
        NSMutableArray *m_arr = [NSMutableArray arrayWithCapacity:dict.allKeys.count];
        for (NSNumber *aRouteID in [[AMapNaviDriveManager sharedInstance].naviRoutes allKeys])
        {
            AMapNaviRoute *aRoute = [[[AMapNaviDriveManager sharedInstance] naviRoutes] objectForKey:aRouteID];
            [m_arr insertObject:aRoute atIndex:aRouteID.integerValue];
        }
        self.bottomView.currIndex = 0;
        self.bottomView.routes = m_arr.copy;
    }
    if (self.routeType == CB_ROUTE_TYPE_RIDE) {
        self.bottomView.currIndex = 0;
        self.bottomView.routes = @[self.rideManager.naviRoute];
    }
    if (self.routeType == CB_ROUTE_TYPE_WALK) {
        self.bottomView.currIndex = 0;
        self.bottomView.routes = @[self.walkanager.naviRoute];
    }
    
}

#pragma mark - 懒加载

-(CB_RouteTypeView *)typeView{
    if (!_typeView) {
        _typeView = [[[NSBundle mainBundle] loadNibNamed:@"CB_RouteTypeView" owner:self options:nil] lastObject];
        
    }
    return _typeView;
}

-(CB_RouteBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"CB_RouteBottomView" owner:self options:nil] lastObject];
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150);
        
    }
    return _bottomView;
}

-(CB_PianHaoView *)pianhaoView{
    if (!_pianhaoView) {
        _pianhaoView = [[[NSBundle mainBundle] loadNibNamed:@"CB_PianHaoView" owner:self options:nil] lastObject];
        _pianhaoView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 150);
    }
    return _pianhaoView;
}

-(UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBack)];
        _backView.alpha = 0;
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

-(CB_BusRouteView *)busRouteView{
    if (!_busRouteView) {
        _busRouteView = [[CB_BusRouteView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 450)];
    }
    return _busRouteView;
}

#pragma mark - Handle Drive Navi Routes

- (void)showDriveNaviRoutes {
    if ([[AMapNaviDriveManager sharedInstance].naviRoutes count] <= 0) {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    for (NSNumber *aRouteID in [[AMapNaviDriveManager sharedInstance].naviRoutes allKeys])
    {
        AMapNaviRoute *aRoute = [[[AMapNaviDriveManager sharedInstance] naviRoutes] objectForKey:aRouteID];
        int count = (int)[[aRoute routeCoordinates] count];
        
        //添加路径Polyline
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < count; i++)
        {
            AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
            coords[i].latitude = [coordinate latitude];
            coords[i].longitude = [coordinate longitude];
        }
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
        
        SelectableOverlay *selectablePolyline = [[SelectableOverlay alloc] initWithOverlay:polyline];
        [selectablePolyline setRouteID:[aRouteID integerValue]];
        
        [self.mapView addOverlay:selectablePolyline];
        free(coords);
        
        //更新CollectonView的信息
        //        RouteCollectionViewInfo *info = [[RouteCollectionViewInfo alloc] init];
        //        info.routeID = [aRouteID integerValue];
        //        info.title = [NSString stringWithFormat:@"路径ID:%ld | 路径计算策略:%ld", (long)[aRouteID integerValue], (long)[self.preferenceView strategyWithIsMultiple:self.isMultipleRoutePlan]];
        //        info.subtitle = [NSString stringWithFormat:@"长度:%ld米 | 预估时间:%ld秒 | 分段数:%ld", (long)aRoute.routeLength, (long)aRoute.routeTime, (long)aRoute.routeSegments.count];
        
        [self.routeIndicatorInfoArray addObject:aRouteID];
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self action_refershCollectionRote];
    
    [self selectDriveNaviRouteWithID:[[self.routeIndicatorInfoArray firstObject] integerValue]];
}

- (void)selectDriveNaviRouteWithID:(NSInteger)routeID {
    self.DriverouteID = routeID;
    //在开始导航前进行路径选择
    if ([[AMapNaviDriveManager sharedInstance] selectNaviRouteWithRouteID:routeID])   {
        [self selecteDriveOverlayWithRouteID:routeID];
    }   else    {
        NSLog(@"路径选择失败!");
    }
}

- (void)selecteDriveOverlayWithRouteID:(NSInteger)routeID {
    
    NSMutableArray *selectedPolylines = [NSMutableArray array];
    CGFloat backupRoutePolylineWidthScale = 0.8;  //备选路线是当前路线宽度0.8
    
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop) {
        
        if ([overlay isKindOfClass:[MultiDriveRoutePolyline class]]) {
            MultiDriveRoutePolyline *multiPolyline = overlay;
            
            /* 获取overlay对应的renderer. */
            MAMultiTexturePolylineRenderer * overlayRenderer = (MAMultiTexturePolylineRenderer *)[self.mapView rendererForOverlay:multiPolyline];
            
            if (multiPolyline.routeID == routeID) {
                [selectedPolylines addObject:overlay];
            } else {
                // 修改备选路线的样式
                overlayRenderer.lineWidth = AMapNaviRoutePolylineDefaultWidth * backupRoutePolylineWidthScale;
                overlayRenderer.strokeTextureImages = multiPolyline.polylineTextureImages;
            }
        }
    }];
    
    [self.mapView removeOverlays:selectedPolylines];
    [self.mapView addOverlays:selectedPolylines];
}

- (void)showDriveMultiColorNaviRoutes {
    if ([[AMapNaviDriveManager sharedInstance].naviRoutes count] <= 0) {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    for (NSNumber *aRouteID in [[AMapNaviDriveManager sharedInstance].naviRoutes allKeys]) {
        AMapNaviRoute *aRoute = [[[AMapNaviDriveManager sharedInstance] naviRoutes] objectForKey:aRouteID];
        int count = (int)[[aRoute routeCoordinates] count];
        
        //添加路径Polyline
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < count; i++) {
            AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
            coords[i].latitude = [coordinate latitude];
            coords[i].longitude = [coordinate longitude];
        }
        
        NSMutableArray<UIImage *> *textureImagesArrayNormal = [NSMutableArray new];
        NSMutableArray<UIImage *> *textureImagesArraySelected = [NSMutableArray new];
        
        // 添加路况图片
        for (AMapNaviTrafficStatus *status in aRoute.routeTrafficStatuses) {
            UIImage *img = [self defaultTextureImageForRouteStatus:status.status isSelected:NO];
            UIImage *selImg = [self defaultTextureImageForRouteStatus:status.status isSelected:YES];
            if (img && selImg) {
                [textureImagesArrayNormal addObject:img];
                [textureImagesArraySelected addObject:selImg];
            }
        }
        
        MultiDriveRoutePolyline *mulPolyline = [MultiDriveRoutePolyline polylineWithCoordinates:coords count:count drawStyleIndexes:aRoute.drawStyleIndexes];
        mulPolyline.polylineTextureImages = textureImagesArrayNormal;
        mulPolyline.polylineTextureImagesSeleted = textureImagesArraySelected;
        mulPolyline.routeID = aRouteID.integerValue;
        
        [self.mapView addOverlay:mulPolyline];
        free(coords);
        
        //更新CollectonView的信息
        //        RouteCollectionViewInfo *info = [[RouteCollectionViewInfo alloc] init];
        //        info.routeID = [aRouteID integerValue];
        ////        info.title = [NSString stringWithFormat:@"路径ID:%ld | 路径计算策略:%ld", (long)[aRouteID integerValue], (long)[self.preferenceView strategyWithIsMultiple:self.isMultipleRoutePlan]];
        //        info.subtitle = [NSString stringWithFormat:@"长度:%ld米 | 预估时间:%ld秒 | 分段数:%ld", (long)aRoute.routeLength, (long)aRoute.routeTime, (long)aRoute.routeSegments.count];
        
        [self.routeIndicatorInfoArray addObject:aRouteID];
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self action_refershCollectionRote];
    
    [self selectDriveNaviRouteWithID:[[self.routeIndicatorInfoArray firstObject] integerValue]];
    [self action_showBottom];
}

//根据交通状态获得纹理图片
- (UIImage *)defaultTextureImageForRouteStatus:(AMapNaviRouteStatus)routeStatus isSelected:(BOOL)isSelected {
    
    NSString *imageName = nil;
    
    if (routeStatus == AMapNaviRouteStatusSmooth) {
        imageName = @"custtexture_green";
    } else if (routeStatus == AMapNaviRouteStatusSlow) {
        imageName = @"custtexture_slow";
    } else if (routeStatus == AMapNaviRouteStatusJam) {
        imageName = @"custtexture_bad";
    } else if (routeStatus == AMapNaviRouteStatusSeriousJam) {
        imageName = @"custtexture_serious";
    } else {
        imageName = @"custtexture_no";
    }
    if (!isSelected) {
        imageName = [NSString stringWithFormat:@"%@_unselected",imageName];
    }
    
    return [UIImage imageNamed:imageName];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteSuccessWithType:(AMapNaviRoutePlanType)type
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后显示路径
    [self showDriveMultiColorNaviRoutes];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error routePlanType:(AMapNaviRoutePlanType)type
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager
{
    return NO;
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}


#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NaviPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"NaviPointAnnotationIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.image = nil;
        NaviPointAnnotation *navAnnotation = (NaviPointAnnotation *)annotation;
        /* 起点. */
        if (navAnnotation.navPointType == NaviPointAnnotationStart)
        {
            poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
        }
        else if (navAnnotation.navPointType == NaviPointAnnotationEnd)
        {
            poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
        }
        
        return poiAnnotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[SelectableOverlay class]]) {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColor = selectableOverlay.isSelected ? selectableOverlay.selectedColor : selectableOverlay.regularColor;
        
        return polylineRenderer;
    }else  if ([overlay isKindOfClass:[MANaviPolyline class]]) {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = 6;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking){
            polylineRenderer.strokeColor = self.abusRoute.walkingColor;
        }else if (naviPolyline.type == MANaviAnnotationTypeRailway){
            polylineRenderer.strokeColor = self.abusRoute.railwayColor;
        }else{
            polylineRenderer.strokeColor = self.abusRoute.routeColor;
        }
        return polylineRenderer;

    } else if ([overlay isKindOfClass:[MultiDriveRoutePolyline class]]) {
        MultiDriveRoutePolyline *mpolyline = (MultiDriveRoutePolyline *)overlay;
        MAMultiTexturePolylineRenderer *polylineRenderer = [[MAMultiTexturePolylineRenderer alloc] initWithMultiPolyline:mpolyline];
//        if (self.routeType == CB_ROUTE_TYPE_DEIVE) {
//            polylineRenderer.lineWidth = AMapNaviRoutePolylineDefaultWidth;
//        }else{
//            polylineRenderer.lineWidth = 12.0f;
//        }
        polylineRenderer.lineWidth = AMapNaviRoutePolylineDefaultWidth;
        polylineRenderer.lineJoinType = kMALineJoinRound;
        polylineRenderer.strokeTextureImages = mpolyline.polylineTextureImagesSeleted;
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - Handle Ride Navi Routes
- (void)showRideNaviRoutes
{
    if (self.rideManager.naviRoute == nil)
    {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    AMapNaviRoute *aRoute = self.rideManager.naviRoute;
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    MultiDriveRoutePolyline *mulPolyline = [MultiDriveRoutePolyline polylineWithCoordinates:coords count:count drawStyleIndexes:aRoute.drawStyleIndexes];
    mulPolyline.polylineTextureImages = @[[UIImage imageNamed:@"custtexture_no"]];
    mulPolyline.polylineTextureImagesSeleted = @[[UIImage imageNamed:@"custtexture_no"]];
    [self.mapView addOverlay:mulPolyline];
    free(coords);
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self action_refershCollectionRote];
    [self action_showBottom];
}

- (void)selecteRideOverlayWithRouteID:(NSInteger)routeID
{
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop)
     {
         if ([overlay isKindOfClass:[SelectableOverlay class]])
         {
             SelectableOverlay *selectableOverlay = overlay;
             
             /* 获取overlay对应的renderer. */
             MAPolylineRenderer * overlayRenderer = (MAPolylineRenderer *)[self.mapView rendererForOverlay:selectableOverlay];
             
             if (selectableOverlay.routeID == routeID)
             {
                 /* 设置选中状态. */
                 selectableOverlay.selected = YES;
                 
                 /* 修改renderer选中颜色. */
                 overlayRenderer.fillColor   = selectableOverlay.selectedColor;
                 overlayRenderer.strokeColor = selectableOverlay.selectedColor;
                 
                 /* 修改overlay覆盖的顺序. */
                 [self.mapView exchangeOverlayAtIndex:idx withOverlayAtIndex:self.mapView.overlays.count - 1];
             }
             else
             {
                 /* 设置选中状态. */
                 selectableOverlay.selected = NO;
                 
                 /* 修改renderer选中颜色. */
                 overlayRenderer.fillColor   = selectableOverlay.regularColor;
                 overlayRenderer.strokeColor = selectableOverlay.regularColor;
             }
         }
     }];
}
#pragma mark - AMapNaviRideManager Delegate

- (void)rideManager:(AMapNaviRideManager *)rideManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)rideManagerOnCalculateRouteSuccess:(AMapNaviRideManager *)rideManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后显示路径
    [self showRideNaviRoutes];
}

- (void)rideManager:(AMapNaviRideManager *)rideManager onCalculateRouteFailure:(NSError *)error
{
    self.bottomView.routes = @[];
    [AppGeneral showMessage:@"没有查询到路线，请稍后重试" andDealy:1];
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}



#pragma mark - Handle Ride Navi Routes
- (void)showNaviRoutes
{
    if (self.walkanager.naviRoute == nil)
    {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    AMapNaviRoute *aRoute = self.walkanager.naviRoute;
    int count = (int)[[aRoute routeCoordinates] count];
    
    //添加路径Polyline
    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < count; i++)
    {
        AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
        coords[i].latitude = [coordinate latitude];
        coords[i].longitude = [coordinate longitude];
    }
    
    MultiDriveRoutePolyline *mulPolyline = [MultiDriveRoutePolyline polylineWithCoordinates:coords count:count drawStyleIndexes:aRoute.drawStyleIndexes];
    mulPolyline.polylineTextureImages = @[[UIImage imageNamed:@"custtexture_no"]];
    mulPolyline.polylineTextureImagesSeleted = @[[UIImage imageNamed:@"custtexture_no"]];
    [self.mapView addOverlay:mulPolyline];
    free(coords);
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    [self action_refershCollectionRote];
    [self action_showBottom];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后显示路径
    [self showNaviRoutes];
}

- (void)walkManager:(AMapNaviWalkManager *)walkManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

#pragma mark - 公交导航
//公交导航
/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if (response.route == nil||response.route.transits.count==0)
    {
        [AppGeneral showMessage:@"没有查询到路线" andDealy:1];
        return;
    }
    
    self.busRoute = response.route;
    self.busRouteView.dataSource = response.route.transits.copy;
    [self action_showBusRoute];
    [self showBusNaviRoutesONMapWith:0];
    //解析response获取路径信息，具体解析见 Demo
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
    [AppGeneral showMessage:@"线路搜索失败" andDealy:1];
}

- (void)showBusNaviRoutesONMapWith:(NSInteger)index;
{
    if (self.busRoute.transits.count <= 0) {
        return;
    }
    //清空地图上已有的路线
     [self.abusRoute removeFromMapView];
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startPoint.latitude longitude:self.startPoint.longitude]; //起点
    
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.endPoint.latitude longitude:self.endPoint.longitude];  //终点
    
    //根据已经规划的换乘方案，起点，终点，生成显示方案
    self.abusRoute = [MANaviRoute naviRouteForTransit:self.busRoute.transits[index] startPoint:startPoint endPoint:endPoint];
    
    [self.abusRoute addToMapView:self.mapView];  //显示到地图上
    
    UIEdgeInsets edgePaddingRect = UIEdgeInsetsMake(20, 20, 20, 20);
    
    //缩放地图使其适应polylines的展示
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.abusRoute.routePolylines] edgePadding:edgePaddingRect animated:YES];
}

@end
