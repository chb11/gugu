//
//  CB_MessageSocketManager.h
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MessageSocketManager : NSObject

+(instancetype)shareInstance;

-(void)action_startSocket;
-(void)action_stopSocket;
@end

NS_ASSUME_NONNULL_END
