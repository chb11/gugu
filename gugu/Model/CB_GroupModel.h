//
//  CB_GroupModel.h
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_GroupModel : NSObject

@property (nonatomic,strong) NSString *CreatDate;
@property (nonatomic,strong) NSString *GroupHeadPhoto;
@property (nonatomic,strong) NSString *GroupId;
@property (nonatomic,strong) NSString *GroupName;
@property (nonatomic,strong) NSString *GroupNickName;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *PhotoUrl;
@property (nonatomic,strong) NSString *HeadPhoto;
@property (nonatomic,strong) NSString *InviterUserId;
@property (nonatomic,assign) NSInteger Lat;
@property (nonatomic,assign) NSInteger Lng;
@property (nonatomic,strong) NSString *Phone;
@property (nonatomic,strong) NSString *PostDate;
@property (nonatomic,strong) NSString *UserId;
@property (nonatomic,strong) NSString *UserName;

@property (nonatomic,strong) NSString *GroupHeadPhotoURL;
@property (nonatomic,strong) NSString *HeadPhotoURL;


@end

NS_ASSUME_NONNULL_END
