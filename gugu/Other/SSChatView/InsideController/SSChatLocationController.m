//
//  SSChatLocationController.m
//  SSChatView
//
//  Created by soldoros on 2018/10/15.
//  Copyright © 2018年 soldoros. All rights reserved.
//

#import "SSChatLocationController.h"
#import "CB_MapKeywordView.h"
#import "CB_SearchKeywordController.h"
#import "CB_LocationManager.h"

@interface SSChatLocationController ()<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic,strong) CB_MapKeywordView *keywordView;
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) MAPointAnnotation *poiAnnotation;
@property (nonatomic,strong) MAPointAnnotation *userAnnotation;
@property (nonatomic,strong) AMapSearchAPI *search;

@end

@implementation SSChatLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择位置";
    [self addItemWithTitle:@"确定" imageName:@"" selector:@selector(rightBtnClick) left:NO];
    [self configMap];
    [self initAction];
    [self.view addSubview:self.keywordView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.keywordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
   
    self.keywordView.block_clearKeywords = ^{
        [weakSelf action_clearCurrAnnotation];
    };
    self.keywordView.block_searchKeywords = ^{
        [weakSelf action_search];
    };
    
}

-(void)configMap{
    [AMapServices sharedServices].enableHTTPS = YES;
    /*创建地图并添加到父view上*/
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
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

//确定
-(void)rightBtnClick{

    if (self.poiAnnotation) {
        if (self.locationBlock) {
            self.locationBlock(self.poiAnnotation);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [AppGeneral action_showAlertWithTitle:@"是否选择当前位置" andConfirmBlock:^{
            [self action_sendCurrLocation];
        }];
    }
}

-(void)action_sendCurrLocation{
    MAPointAnnotation *anno =self.userAnnotation;
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        anno.title = formattedAddress;
        if (self.locationBlock) {
            self.locationBlock(anno);
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)action_search{
    NSLog(@"跳转搜索");
    CB_SearchKeywordController *page = [CB_SearchKeywordController  new];
    
    __weak typeof(self) weakSelf = self;
    page.block_select = ^(AMapPOI *mapPoi) {
        [weakSelf action_keyworSearchResult:mapPoi];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
    [self presentViewController:nav animated:NO completion:nil];
    
}

-(void)action_keyworSearchResult:(AMapPOI *)mapPoi{
    [self action_clearCurrAnnotation];
    
    self.keywordView.keywordStr = mapPoi.name;
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
//    if ([annotation isKindOfClass:[POIAnnotation class]]){
//        static NSString *locationBackViewReuseIndetifier = @"POIAnnotationReuseIndetifier";
//        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:locationBackViewReuseIndetifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:locationBackViewReuseIndetifier];
//        }
//        annotationView.canShowCallout = YES;
//        annotationView.image = [UIImage imageNamed:@"map_weizhi.png"];
//        return annotationView;
//    }
    return nil;
}


-(CB_MapKeywordView *)keywordView{
    if (!_keywordView) {
        _keywordView = [[[NSBundle mainBundle] loadNibNamed:@"CB_MapKeywordView" owner:self options:nil] firstObject];
        _keywordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    }
    return _keywordView;
}
@end
