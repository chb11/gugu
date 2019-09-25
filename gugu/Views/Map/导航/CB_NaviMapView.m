//
//  CB_NaviMapView.m
//  gugu
//
//  Created by Mike Chen on 2019/5/25.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_NaviMapView.h"
#import "SpeechSynthesizer.h"
#import "CB_ActivityUserAnnotation.h"
#import "CB_ActivityDriveAnnotation.h"
#import "CB_ActivityAnnotationView.h"

@interface CB_NaviMapView ()<AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate,
                                AMapNaviRideViewDelegate,AMapNaviRideManagerDelegate,
                                AMapNaviWalkManagerDelegate,AMapNaviWalkViewDelegate,AMapNaviDriveDataRepresentable>

@property (nonatomic, strong) AMapNaviDriveView *driveView;
@property (nonatomic, strong) AMapNaviWalkView *walkView;
@property (nonatomic, strong) AMapNaviRideView *rideView;
@property (nonatomic, strong) NSMutableArray *driveannotations;

@property (nonatomic, strong) NSString *speedStr;
@property (nonatomic, strong) NSString *roudNameStr;
@property (nonatomic, strong) NSString *naviInfoStr;
@end

@implementation CB_NaviMapView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initDriveManager
{
    //请在 dealloc 函数中执行 [AMapNaviDriveManager destroyInstance] 来销毁单例
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];

}

- (void)initDriveView
{
    if (self.driveView == nil)
    {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:self.bounds];
        self.driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.driveView setDelegate:self];
        [self.driveView setShowGreyAfterPass:YES];
        [self.driveView setAutoZoomMapLevel:YES];
        [self.driveView setShowMoreButton:YES];
        [self.driveView setMapViewModeType:AMapNaviViewMapModeTypeDay];
        [self.driveView setTrackingMode:AMapNaviViewTrackingModeCarNorth];

        [self addSubview:self.driveView];
    }
}

-(void)initWalkManager{
    if (!self.walkManager) {
        self.walkManager = [[AMapNaviWalkManager alloc] init];
        [self.walkManager setDelegate:self];
    }
}

- (void)initWalkView
{
    if (self.walkView == nil)
    {
        self.walkView = [[AMapNaviWalkView alloc] initWithFrame:self.bounds];
        self.walkView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.walkView setDelegate:self];
        
        [self addSubview:self.walkView];
    }
}

-(void)initRideManager{
    if (!self.rideManager) {
        self.rideManager = [[AMapNaviRideManager alloc] init];
        [self.rideManager setDelegate:self];
    }
}
- (void)initRidekView
{
    if (self.rideView == nil)
    {
        self.rideView = [[AMapNaviRideView alloc] initWithFrame:self.bounds];
        self.rideView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.rideView setDelegate:self];
        [self addSubview:self.rideView];
    }
}

-(void)action_updateUserPosition{
    
    
    for (CB_ActivityDriveAnnotation *anno in self.driveannotations) {
        [self.driveView removeCustomAnnotation:anno];
    }
    for (int i = 0; i<self.activityUsers.count; i++) {
        CB_MessageModel *msgModel = self.activityUsers[i];
        CB_ActivityDriveAnnotation *anno = [self driveAnnoWith:msgModel];
        [self.driveannotations addObject:anno];
        [self.driveView addCustomAnnotation:anno];
        
    }
}

-(CB_ActivityDriveAnnotation *)driveAnnoWith:(CB_MessageModel *)msgModel{
    
    CB_ActivityAnnotationView *view = [[[NSBundle mainBundle] loadNibNamed:@"CB_ActivityAnnotationView" owner:self options:nil] lastObject];
    view.name = msgModel.SendName;
    view.title = [NSString stringWithFormat:@"%@",msgModel.Message];
    view.img_url = msgModel.SendPhotoUrlURL;
    if ([self.selectUserId isEqualToString:msgModel.SendUserId]) {
        view.isShowPaoPao = YES;
    }else{
        view.isShowPaoPao = NO;
    }
    [view updateFrame];
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([msgModel.Latitude floatValue], [msgModel.Longitude floatValue]);
    CB_ActivityDriveAnnotation *anno = [[CB_ActivityDriveAnnotation alloc] initWithCoordinate:coor view:view];
    anno.Guid = msgModel.SendUserId;
    return anno;
}


- (void)action_startNavi
{
    //进行路径规划
    if (self.routeType == CB_ROUTE_TYPE_DEIVE) {
        [self initDriveView];
        [self initDriveManager];
        [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self.driveView];
        [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithEndPoints:@[self.endPoint]  wayPoints:nil drivingStrategy:self.strategy];
        [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self];
    }
    if (self.routeType == CB_ROUTE_TYPE_RIDE) {
        [self initRidekView];
        [self.rideManager setDelegate:self];
        [self.rideManager addDataRepresentative:self.rideView];
        [self.rideManager calculateRideRouteWithStartPoint:self.startPoint endPoint:self.endPoint];
    }
    if (self.routeType == CB_ROUTE_TYPE_WALK) {
        [self initWalkView];

        [self.walkManager setDelegate:self];
        [self.walkManager addDataRepresentative:self.walkView];
        [self.walkManager calculateWalkRouteWithStartPoints:@[self.startPoint]
                                                  endPoints:@[self.endPoint]];
    }
}

-(void)action_closeNavi{
    
    if (self.routeType == CB_ROUTE_TYPE_DEIVE) {
        //停止导航
        [[AMapNaviDriveManager sharedInstance] stopNavi];
        [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self.driveView];
        [[AMapNaviDriveManager sharedInstance] setDelegate:nil];
    }
    if (self.routeType == CB_ROUTE_TYPE_RIDE) {
        [self.rideManager stopNavi];
    }
    if (self.routeType == CB_ROUTE_TYPE_WALK) {
        [self.walkManager stopNavi];
    }
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
}

//返回导航信息
-(NSString *)currNaviInfo{
    NSString *str = [NSString stringWithFormat:@"%@ %@ %@",self.roudNameStr,self.speedStr,self.naviInfoStr];
    return str;
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    [[AMapNaviDriveManager sharedInstance] selectNaviRouteWithRouteID:self.DriverRouteid];
    //算路成功后开始GPS导航
    [[AMapNaviDriveManager sharedInstance] startGPSNavi];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
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
    return [[SpeechSynthesizer sharedSpeechSynthesizer] isSpeaking];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}

//诱导信息
- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(AMapNaviInfo *)naviInfo {
    if (naviInfo) {
        self.roudNameStr = naviInfo.currentRoadName;
        NSInteger minters = naviInfo.routeRemainDistance;
        NSString *minterStr = @"";
        if (minters<1000) {
            minterStr = [NSString stringWithFormat:@"%ld米",minters];
        }else{
            minterStr = [NSString stringWithFormat:@"%.f公里",minters*0.001];
        }
        NSString *timeStr = [self timeFormatted:naviInfo.routeRemainTime];
        self.naviInfoStr = [NSString stringWithFormat:@"%@ %@",minterStr,timeStr];
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviLocation:(nullable AMapNaviLocation *)naviLocation{
    NSLog(@"");
    self.speedStr = [NSString stringWithFormat:@"%ldkm/h",naviLocation.speed];
    
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d时%02d分",hours, minutes];
}

#pragma mark - AMapNaviRideManager Delegate
/**
 * @brief 发生错误时,会调用代理的此方法
 * @param rideManager 骑行导航管理类
 * @param error 错误信息
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager error:(NSError *)error{
    NSLog(@"");
    
    
}

/**
 * @brief 骑行路径规划失败后的回调函数. 从6.1.0版本起,算路失败后导航SDK只对外通知算路失败,SDK内部不再执行停止导航的相关逻辑.因此,当算路失败后,不会收到 driveManager:updateNaviMode: 回调; AMapNaviRideManager.naviMode 不会切换到 AMapNaviModeNone 状态, 而是会保持在 AMapNaviModeGPS or AMapNaviModeEmulator 状态
 * @param rideManager 骑行导航管理类
 * @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager onCalculateRouteFailure:(NSError *)error{
    NSLog(@"");
}

/**
 * @brief 骑行路径规划成功后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerOnCalculateRouteSuccess:(AMapNaviRideManager *)rideManager{
    [self.rideManager startGPSNavi];
}

- (void)rideManager:(AMapNaviRideManager *)rideManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)rideManagerNeedRecalculateRouteForYaw:(AMapNaviRideManager *)rideManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)rideManager:(AMapNaviRideManager *)rideManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)rideManagerDidEndEmulatorNavi:(AMapNaviRideManager *)rideManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)rideManagerOnArrivedDestination:(AMapNaviRideManager *)rideManager
{
    NSLog(@"onArrivedDestination");
}
#pragma mark - AMapNaviWalkManager Delegate

/**
 * @brief 发生错误时,会调用代理的此方法
 * @param walkManager 步行导航管理类
 * @param error 错误信息
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager error:(NSError *)error{
    NSLog(@"");
}

/**
 * @brief 步行路径规划成功后的回调函数
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerOnCalculateRouteSuccess:(AMapNaviWalkManager *)walkManager{
    
    [self.walkManager startGPSNavi];
}


/**
 * @brief 启动导航后回调函数
 * @param walkManager 步行导航管理类
 * @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager didStartNavi:(AMapNaviMode)naviMode{
    NSLog(@"");
}

/**
 * @brief 出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
 * @param walkManager 步行导航管理类
 */
- (void)walkManagerNeedRecalculateRouteForYaw:(AMapNaviWalkManager *)walkManager{
    NSLog(@"");
}

/**
 * @brief 导航播报信息回调函数
 * @param walkManager 步行导航管理类
 * @param soundString 播报文字
 * @param soundStringType 播报类型,参考AMapNaviSoundType. 注意：since 6.0.0 AMapNaviSoundType 只返回 AMapNaviSoundTypeDefault
 */
- (void)walkManager:(AMapNaviWalkManager *)walkManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType{
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

#pragma mark - AMapNaviDriveViewDelegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView
{
    [AppGeneral action_showAlertWithTitle:@"是否退出导航" andConfirmBlock:^{
        [self action_closeNavi];
        if (self.block_closeNavi) {
            self.block_closeNavi();
        }
    }];
}

- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    NSLog(@"TrunIndicatorViewTapped");
}

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode
{
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}

#pragma mark - MoreMenu Delegate

- (void)moreMenuViewNightTypeChangeTo:(AMapNaviViewMapModeType)mapModeType
{
    [self.driveView setMapViewModeType:mapModeType];
}

- (void)moreMenuViewTrackingModeChangeTo:(AMapNaviViewTrackingMode)trackingMode
{
    [self.driveView setTrackingMode:trackingMode];
}


-(NSMutableArray *)activityUsers{
    if (!_activityUsers) {
        _activityUsers = @[].mutableCopy;
    }
    return _activityUsers;
}

-(NSMutableArray *)driveannotations{
    if (!_driveannotations) {
        _driveannotations = @[].mutableCopy;
    }
    return _driveannotations;
}

@end
