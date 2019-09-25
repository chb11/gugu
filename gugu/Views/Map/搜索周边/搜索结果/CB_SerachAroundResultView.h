//
//  CB_SerachAroundResultView.h
//  gugu
//
//  Created by Mike Chen on 2019/4/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_SerachAroundResultView : UIView

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,copy) void(^block_selectPOI)(NSInteger index,AMapPOI *poi);

@end

NS_ASSUME_NONNULL_END
