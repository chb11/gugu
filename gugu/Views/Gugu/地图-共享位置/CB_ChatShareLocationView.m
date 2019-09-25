//
//  CB_ChatShareLocationView.m
//  gugu
//
//  Created by Mike Chen on 2019/5/19.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ChatShareLocationView.h"
#import "CB_ActivityUserAnnotation.h"

@interface CB_ChatShareLocationView ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) MAPointAnnotation *poiAnnotation;
@property (nonatomic,strong) MAPointAnnotation *userAnnotation;
@property (nonatomic,strong) AMapSearchAPI *search;

@property (nonatomic,strong) NSMutableArray *activityUsers;

@property (nonatomic,strong) CB_ActivityUserAnnotation *currSelectUserAnnotaion;

@end

@implementation CB_ChatShareLocationView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configMap];
    }
    return self;
}


-(void)configMap{
    [AMapServices sharedServices].enableHTTPS = YES;
    /*创建地图并添加到父view上*/
    self.mapView = [[MAMapView alloc] initWithFrame:self.bounds];
    self.mapView.delegate = self;
    [self addSubview:self.mapView];
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapView.showsUserLocation = YES;
    ///是否自定义用户位置精度圈(userLocationAccuracyCircle)对应的 view, 默认为 NO.\n 如果为YES: 会调用 - (MAOverlayRenderer *)mapView (MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay 若返回nil, 则不加载.\n 如果为NO : 会使用默认的样式.
    //是否自定义用户位置精度圈
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.compassOrigin= CGPointMake(22, 40+22); //设置指南针位置
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
}

-(void)action_keyworSearchResult:(AMapPOI *)mapPoi{
    [self action_clearCurrAnnotation];
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate =CLLocationCoordinate2DMake(mapPoi.location.latitude, mapPoi.location.longitude);
    annotation.title = mapPoi.name;
    self.poiAnnotation = annotation;
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
}

#pragma mark - 点击地图

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    if (self.poiAnnotation) {
        [self action_clearCurrAnnotation];
        return;
    }
    
    [self action_clearCurrAnnotation];
    [self searchReGeocodeWithCoordinate:coordinate];
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
    
    
}

/**
 * @brief 逆地理编码查询回调函数
 * @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    /* Remove prior annotation. */
    [self action_clearCurrAnnotation];
    
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate =CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    annotation.title = response.regeocode.formattedAddress;
    self.poiAnnotation = annotation;
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
}

-(void)action_clearCurrAnnotation{
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
        self.poiAnnotation = nil;
    }
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    view.canShowCallout = YES;
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]]||[view.reuseIdentifier isEqualToString:@"ActivityUserViewReuseIndetifier"]) {
        [self.mapView selectAnnotation:view.annotation animated:YES];
        self.currSelectUserAnnotaion = view.annotation;
        return;
    }
    
}

#pragma mark - 设置气泡
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    
    //用户所在位置
    if([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        self.userAnnotation = annotation;
        annotationView.canShowCallout = NO;
        [annotationView.imageView sd_setImageWithURL:[NSURL URLWithString:[UserModel shareInstance].HeadPhotoURL]];
        annotationView.frame = CGRectMake(0, 0, 40, 40);
        [annotationView addlayerRadius:annotationView.height/2];
        annotationView.contentMode = UIViewContentModeScaleToFill;
        annotationView.layer.masksToBounds = YES;
        return annotationView;
        
    }
    
    if ([annotation isKindOfClass:[CB_ActivityUserAnnotation class]]) {
        static NSString *ActivityUserViewReuseIndetifier = @"ActivityUserViewReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:ActivityUserViewReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ActivityUserViewReuseIndetifier];
        }
        
        annotationView.canShowCallout = YES;
        CB_ActivityUserAnnotation *aUAnno = annotation;
        NSString *headUrl = aUAnno.userHeadUrl;
        [annotationView.imageView sd_setImageWithURL:[NSURL URLWithString:headUrl]];
        annotationView.frame = CGRectMake(0, 0, 40, 40);
        [annotationView.imageView addlayerRadius:annotationView.imageView.height/2];
        //        annotationView.contentMode = UIViewContentModeScaleToFill;
        //        annotationView.layer.masksToBounds = YES;
        return annotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        
        static NSString *locationBackViewReuseIndetifier = @"locationBackViewReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:locationBackViewReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locationBackViewReuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"map_weizhi.png"];
        annotationView.frame = CGRectMake(0, 0, 40, 40);
        return annotationView;
    }
    return nil;
}

-(void)action_clearUsers{
    NSArray *annos = self.mapView.annotations;
    for (MAPointAnnotation *anno in annos) {
        if ([anno isKindOfClass:[CB_ActivityUserAnnotation class]]) {
            [self.mapView removeAnnotation:anno];
        }
    }
    [self.activityUsers removeAllObjects];
}

-(void)action_updateUserWith:(CB_MessageModel *)msg{
    [self action_updateUserPositionWith:msg];
}

-(void)action_updateUserPositionWith:(CB_MessageModel *)msgModel{
    NSArray *arr = self.activityUsers.copy;
    BOOL isExist = NO;
    for (int i =0;i<arr.count; i++) {
        CB_MessageModel *model = arr[i];
        if ([model.SendUserId isEqualToString:msgModel.SendUserId]) {
            isExist = YES;
            [self.activityUsers replaceObjectAtIndex:i withObject:msgModel];
            break;
        }
    }
    
    if (!isExist) {
        [self.activityUsers addObject:msgModel];
    }
    
    NSArray *annos = self.mapView.annotations;
    for (MAPointAnnotation *anno in annos) {
        if ([anno isKindOfClass:[CB_ActivityUserAnnotation class]]) {
            [self.mapView removeAnnotation:anno];
        }
    }
    
    for (CB_MessageModel *model in self.activityUsers) {
        CB_ActivityUserAnnotation *newPointAnnotation = [[CB_ActivityUserAnnotation alloc] init];
        newPointAnnotation.title = model.SendName;
        newPointAnnotation.subtitle = model.Message;
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([model.Latitude floatValue], [model.Longitude floatValue]);
        newPointAnnotation.coordinate = location;
        newPointAnnotation.Guid = model.SendId;
        newPointAnnotation.userHeadUrl = model.SendPhotoUrlURL;
        [self.mapView addAnnotation:newPointAnnotation];
        
        if ([self.currSelectUserAnnotaion.Guid isEqualToString:newPointAnnotation.Guid]) {
            [self.mapView selectAnnotation:newPointAnnotation animated:NO];
        }
        
    }

}

-(NSMutableArray *)activityUsers{
    if (!_activityUsers) {
        _activityUsers = @[].mutableCopy;
    }
    return _activityUsers;
}

@end
