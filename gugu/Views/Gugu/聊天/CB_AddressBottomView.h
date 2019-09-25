//
//  CB_AddressBottomView.h
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_AddressBottomView : UIView

@property (nonatomic,strong) NSString *sendId;
@property (nonatomic,copy) void(^block_chooseAddress)(CB_MessageModel *msgModel);
-(void)refreshData;
@end

NS_ASSUME_NONNULL_END
