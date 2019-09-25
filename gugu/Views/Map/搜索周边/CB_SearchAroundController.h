//
//  CB_SearchAroundController.h
//  gugu
//
//  Created by Mike Chen on 2019/3/27.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface CB_SearchAroundController : BaseViewController

@property (nonatomic,strong) AMapGeoPoint *mapGeoPoint;

@property (nonatomic,copy) void(^block_selectType)(AMapGeoPoint *mapGeoPoint,NSString *type);
@property (nonatomic,copy) void(^block_selectPOI)(AMapGeoPoint *mapGeoPoint,AMapPOI *poi);


@end

NS_ASSUME_NONNULL_END
