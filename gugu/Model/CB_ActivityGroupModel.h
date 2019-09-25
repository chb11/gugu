//
//  CB_ActivityModel.h
//  gugu
//
//  Created by Mike Chen on 2019/5/24.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_ActivityGroupModel : NSObject

@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *StartDate;
@property (nonatomic,strong) NSString *CreatUserName;
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *UserId;
@property (nonatomic,assign) BOOL Openable;
@property (nonatomic,strong) NSString *CreatDate;
@property (nonatomic,strong) NSString *CaptainId;
@property (nonatomic,strong) NSString *GroupHeadPhoto;
@property (nonatomic,strong) NSString *CaptainName;
@property (nonatomic,strong) NSString *Notice;
@property (nonatomic,strong) NSString *ChatGroupId;
@property (nonatomic,strong) NSString *Route;

@property (nonatomic,strong) NSString *GroupHeadPhotoURL;

@end

NS_ASSUME_NONNULL_END
