//
//  CB_Database.h
//  VoicePackage
//
//  Created by douyinbao on 2018/10/12.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CB_MessageModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface CB_Database : NSObject

+(instancetype)sharedDataBase;

-(void)action_saveMessage:(CB_MessageModel *)model;

-(NSArray *)lastedMessageFromLocal;


@end

NS_ASSUME_NONNULL_END
