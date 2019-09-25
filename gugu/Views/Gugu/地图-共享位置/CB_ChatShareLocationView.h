//
//  CB_ChatShareLocationView.h
//  gugu
//
//  Created by Mike Chen on 2019/5/19.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ChatShareLocationView : UIView

-(void)action_updateUserWith:(CB_MessageModel *)msg;

-(void)action_clearUsers;

@end

NS_ASSUME_NONNULL_END
