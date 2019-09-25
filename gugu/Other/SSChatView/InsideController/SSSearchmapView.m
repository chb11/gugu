//
//  SSSearchmapView.m
//  gugu
//
//  Created by Mike Chen on 2019/5/22.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "SSSearchmapView.h"

#import "CB_MapBottomView.h"

#import "CommonUtility.h"
#import "MANaviRoute.h"
#import "CB_SearchKeywordController.h"
#import "CB_SearchAroundController.h"
#import "CB_SerachAroundResultView.h"
#import "POIAnnotation.h"
#import "CB_MapRouteController.h"
#import "CB_MessageTransController.h"
#import "CB_ActivityUserAnnotation.h"

@interface SSSearchmapView ()<MAMapViewDelegate,AMapSearchDelegate>

@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic,strong) AMapSearchAPI *search;
@property (nonatomic,strong) MAPointAnnotation *userAnnotation;
@property (nonatomic,strong) MAPointAnnotation *poiAnnotation;
@property (nonatomic,strong) MAPointAnnotation *SearchpoiAnnotation;
@property (nonatomic,strong) CB_MapBottomView *bottomView;

@property (nonatomic, strong) AMapRoute *route;
/* 当前路线方案索引值. */
@property (nonatomic) NSInteger currentCourse;
/* 路线方案个数. */
@property (nonatomic) NSInteger totalCourse;
@property (nonatomic, strong) UIBarButtonItem *previousItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;
/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

@property (nonatomic,strong) UIButton *btn_traffic;
@property (nonatomic,strong) CB_SerachAroundResultView *resultListView;

@property (nonatomic,strong) NSMutableArray *searchResultArray;
@property (nonatomic,assign) BOOL isShowBottom;
@property (nonatomic,assign) BOOL isShowResultList;
@property (nonatomic,strong) NSString *cityName;

@property (nonatomic,strong) NSMutableArray *activityUsers;

@property (nonatomic,strong) CB_ActivityUserAnnotation *currSelectUserAnnotaion;

@end

@implementation SSSearchmapView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configMap];
        [self addSubview:self.bottomView];
        [self addSubview:self.resultListView];
        [self addSubview:self.keywordView];
        [self initAction];
    }
    return self;
}


-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.bottomView.block_goToThere = ^{
        [weakSelf action_goThere];
    };
    self.bottomView.block_searchAround = ^{
        [weakSelf action_searchAround];
    };
    self.bottomView.block_showResultList = ^{
        if (weakSelf.searchResultArray.count>0) {
            [weakSelf action_showResultList];
        }
    };
    self.keywordView.block_clearKeywords = ^{
        [weakSelf action_clearCurrAnnotation];
    };
    self.keywordView.block_searchKeywords = ^{
        [weakSelf action_search];
    };
    self.resultListView.block_selectPOI = ^(NSInteger index, AMapPOI * _Nonnull poi) {
        [weakSelf action_selectAnnotationWith:index];
        [weakSelf action_hideResultList];
    };
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
    self.mapView.showTraffic = YES;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
}

#pragma mark - 懒加载

-(CB_MapBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"CB_MapBottomView" owner:self options:nil] firstObject];
        _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 110);
    }
    return _bottomView;
}

-(CB_MapKeywordView *)keywordView{
    if (!_keywordView) {
        _keywordView = [[[NSBundle mainBundle] loadNibNamed:@"CB_MapKeywordView" owner:self options:nil] firstObject];
        _keywordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    }
    return _keywordView;
}

- (UIButton *)btn_traffic{
    if (!_btn_traffic) {
        _btn_traffic = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-22-35, 22, 35, 35)];
        [_btn_traffic setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_btn_traffic setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    }
    return _btn_traffic;
}

-(CB_SerachAroundResultView *)resultListView{
    if (!_resultListView) {
        _resultListView = [[CB_SerachAroundResultView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH)];
    }
    return _resultListView;
}

-(NSMutableArray *)searchResultArray{
    if (!_searchResultArray) {
        _searchResultArray = @[].mutableCopy;
    }
    return _searchResultArray;
}

#pragma mark - 事件
-(void)action_selectAnnotationWith:(NSInteger )index{
    [self.mapView selectAnnotation:self.searchResultArray[index] animated:YES];
}

-(void)action_search{
    NSLog(@"跳转搜索");
    CB_SearchKeywordController *page = [CB_SearchKeywordController  new];
    
    __weak typeof(self) weakSelf = self;
    page.block_select = ^(AMapPOI *mapPoi) {
        [weakSelf action_keyworSearchResult:mapPoi];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
    [[AppGeneral getPresentedViewController] presentViewController:nav animated:NO completion:nil];
}

-(void)action_keyworSearchResult:(AMapPOI *)mapPoi{
    [self action_clearCurrAnnotation];
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
        self.poiAnnotation = nil;
    }
    self.keywordView.keywordStr = mapPoi.name;
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate =CLLocationCoordinate2DMake(mapPoi.location.latitude, mapPoi.location.longitude);
    annotation.title = mapPoi.name;
    self.poiAnnotation = annotation;
    self.SearchpoiAnnotation = annotation;
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
    self.bottomView.btn_shangla.hidden = YES;
    [self action_hideResultList];
}

-(void)action_searchAround{
    CB_SearchAroundController *page = [CB_SearchAroundController  new];
    page.mapGeoPoint = [AMapGeoPoint locationWithLatitude:self.poiAnnotation.coordinate.latitude longitude:self.poiAnnotation.coordinate.longitude];
    __weak typeof(self) weakSelf = self;
    page.block_selectType = ^(AMapGeoPoint * _Nonnull mapGeoPoint, NSString * _Nonnull type) {
        [weakSelf action_searchAroundCenter:mapGeoPoint WithWords:type];
    };
    page.block_selectPOI = ^(AMapGeoPoint * _Nonnull mapGeoPoint, AMapPOI * _Nonnull poi) {
        [weakSelf action_searchAroundCenter:mapGeoPoint withPoi:poi];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
    [[AppGeneral getPresentedViewController] presentViewController:nav animated:NO completion:nil];
}

-(void)action_searchAroundCenter:(AMapGeoPoint *)mapGeoPoint WithWords:(NSString *)words{
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location            = mapGeoPoint;
    request.keywords            = words;
    /* 按照距离排序. */
    request.sortrule            = 0;
    request.requireExtension    = YES;
    [self.search AMapPOIAroundSearch:request];
}

-(void)action_searchAroundCenter:(AMapGeoPoint *)mapGeoPoint withPoi:(AMapPOI *)poi{
    
    POIAnnotation *annotation = [[POIAnnotation alloc] initWithPOI:poi];
    [self.mapView removeAnnotations:self.searchResultArray];
    [self.searchResultArray removeAllObjects];
    [self.searchResultArray addObject:annotation];
    [self.mapView addAnnotation:annotation];
    [self.mapView setCenterCoordinate:[annotation coordinate]];
}

-(void)action_goThere{
    NSLog(@"到这去");
    
    if (self.block_chooseAddress) {
        [AppGeneral action_showAlertWithTitle:@"确定修改目的地？" andConfirmBlock:^{
            self.block_chooseAddress(self.poiAnnotation);
        }];
    }
}

-(void)action_showBottom{
    self.isShowBottom = YES;
    MAMapStatus *mapstatus = [[MAMapStatus alloc] init];
    mapstatus.centerCoordinate =self.poiAnnotation.coordinate;
    mapstatus.zoomLevel = self.mapView.zoomLevel;
    [self.mapView setMapStatus:mapstatus animated:YES];
    
    self.bottomView.lbl_title.text = self.poiAnnotation.title;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-BottomPadding-110-NavBarHeight, SCREEN_WIDTH, 110);
    }];
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
    
    if (self.block_userCount) {
        self.block_userCount(self.activityUsers.count);
    }
    
}

-(void)action_clearCurrAnnotation{
    
    if (self.SearchpoiAnnotation) {
        [self.mapView removeAnnotation:self.SearchpoiAnnotation];
        self.SearchpoiAnnotation = nil;
    }
    
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
        self.poiAnnotation = nil;
        [self action_hideBottom];
    }
    [self action_clearSearch];
}

-(void)action_hideBottom{
    self.isShowBottom = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 110);
    }];
}

-(void)action_clearSearch{
    [self.mapView removeAnnotations:self.searchResultArray];
    [self.searchResultArray removeAllObjects];
}

-(void)action_showResultList{
    self.isShowResultList = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.resultListView.mj_y = SCREEN_HEIGHT-BottomPadding-self.resultListView.height;
    }];
}

-(void)action_hideResultList{
    self.isShowResultList = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.resultListView.mj_y = SCREEN_HEIGHT;
    }];
}

#pragma mark - 点击地图

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    if (self.currSelectUserAnnotaion) {
        self.currSelectUserAnnotaion = nil;
    }
    
    if (self.keywordView.txt_keyword.text.length>0) {
        if (self.searchResultArray.count>0) {
            return;
        }
    }
    
    if (!self.poiAnnotation) {
        [self action_clearCurrAnnotation];
        [self searchReGeocodeWithCoordinate:coordinate];
    }else{
        [self action_clearCurrAnnotation];
    }

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
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
    }
    self.cityName = response.regeocode.addressComponent.city;
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate =CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
    annotation.title = response.regeocode.formattedAddress;
    self.poiAnnotation = annotation;
    self.SearchpoiAnnotation = annotation;
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];
    
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
    if ([annotation isKindOfClass:[POIAnnotation class]]){
        static NSString *locationBackViewReuseIndetifier = @"POIAnnotationReuseIndetifier";
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

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
//    [self.mapView removeAnnotation:self.userAnnotation];
    
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    
    if (response.pois.count == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"没有找到相关信息"];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }
    [self action_clearSearch];
    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
    }];
    
    [self.searchResultArray addObjectsFromArray:poiAnnotations];
    /* 将结果以annotation的形式加载到地图上. */
    [self.mapView addAnnotations:poiAnnotations];
    
    /* 如果只有一个结果，设置其为中心点. */
    if (poiAnnotations.count == 1)
    {
        [self.mapView setCenterCoordinate:[(POIAnnotation *)poiAnnotations[0] coordinate]];
        self.bottomView.btn_shangla.hidden = YES;
    }
    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    else
    {
        [self.mapView showAnnotations:poiAnnotations animated:NO];
        if (self.searchResultArray.count>1) {
            self.bottomView.btn_shangla.hidden = NO;
        }else{
            self.bottomView.btn_shangla.hidden = YES;
        }
    }
    [self.mapView selectAnnotation:self.poiAnnotation animated:YES];
    self.resultListView.dataSource = response.pois.mutableCopy;
    [self action_showResultList];
    
}

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    view.canShowCallout = YES;
    
    if ([view.annotation isKindOfClass:[MAUserLocation class]]||[view.reuseIdentifier isEqualToString:@"ActivityUserViewReuseIndetifier"]) {
        [self.mapView selectAnnotation:view.annotation animated:YES];
        self.currSelectUserAnnotaion = view.annotation;
        return;
    }
    
    
    
    
    CLLocationCoordinate2D coordinate = view.annotation.coordinate;
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    self.poiAnnotation = view.annotation;
    if (self.isShowBottom) {
        self.bottomView.lbl_title.text = view.annotation.title;
    }else{
        [self action_showBottom];
    }
    
    [self action_hideResultList];
}

//-(void)action_shareLocation{
//    CB_MessageTransController *page = [CB_MessageTransController new];
//    page.annotation = self.userAnnotation;
//    [self.navigationController pushViewController:page animated:YES];
//}

-(NSMutableArray *)activityUsers{
    if (!_activityUsers) {
        _activityUsers = @[].mutableCopy;
    }
    return _activityUsers;
}

@end
