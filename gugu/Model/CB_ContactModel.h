//
//  CB_ContactModel.h
//  gugu
//  紧急联系人
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ContactModel : NSObject

@property (nonatomic,strong) NSString *UserName;
@property (nonatomic,strong) NSString *UserId;
@property (nonatomic,strong) NSString *PhotoUrl;
@property (nonatomic,assign) NSInteger Idx;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *FrendNickName;
@property (nonatomic,strong) NSString *ConsumerId;
@property (nonatomic,strong) NSString *HeadPhotoURL;

@end

NS_ASSUME_NONNULL_END
