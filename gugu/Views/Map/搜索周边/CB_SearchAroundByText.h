//
//  CB_SearchAroundByText.h
//  gugu
//
//  Created by Mike Chen on 2019/3/31.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SearchAroundByText : UIView

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,copy) void(^block_selectPoi)(AMapPOI *poi);

@end

NS_ASSUME_NONNULL_END
