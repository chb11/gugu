//
//  CB_MessageModel.h
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_MessageModel : NSObject

@property (nonatomic,strong) NSString *pkid;
@property (nonatomic,strong) NSString *GroupName;
@property (nonatomic,strong) NSString *SendName;
@property (nonatomic,strong) NSString *Message;
@property (nonatomic,assign) BOOL Collect;
@property (nonatomic,strong) NSString *SendPhotoUrl;
@property (nonatomic,strong) NSString *SendPhotoUrlURL;
@property (nonatomic,strong) NSString *SendId;
@property (nonatomic,strong) NSString *CollectName;
@property (nonatomic,assign) NSInteger SenderType;
@property (nonatomic,assign) CGFloat Duration;
@property (nonatomic,assign) NSInteger NoReadNum;
@property (nonatomic,strong) NSString *GroupId;
@property (nonatomic,strong) NSString *GroupHeadPhoto;
@property (nonatomic,strong) NSString *GroupHeadPhotoURL;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *SendUserUrl;
@property (nonatomic,strong) NSString *SendUserUrlURL;
@property (nonatomic,assign) BOOL ReadState;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSString *FileUrl;
@property (nonatomic,strong) NSString *FileUrlURL;
@property (nonatomic,assign) BOOL IsGroup;
@property (nonatomic,strong) NSString *SendPhone;
@property (nonatomic,strong) NSString *CreatDate;
@property (nonatomic,strong) NSString *PostDate;
@property (nonatomic,assign) NSInteger MessageType;
@property (nonatomic,strong) NSString *SendUserId;
@property (nonatomic,strong) NSString *Abbr;

@property (nonatomic,strong) NSString *ActivityId;
@property (nonatomic,strong) NSString *Longitude;
@property (nonatomic,strong) NSString *Latitude;

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSData *voicrData;
@property (nonatomic,strong) NSString *AddressName;
@property (nonatomic,strong) NSString *SubName;


@property (nonatomic,strong) NSString *loginUserId;
@property (nonatomic,strong) NSString *loginUserName;

@property (nonatomic,strong) NSString *SessionName;
@property (nonatomic,strong) NSString *SessionPhoto;
@property (nonatomic,strong) NSString *SessionMsg;

@property (nonatomic,strong) NSString *GuUserId;
@property (nonatomic,strong) NSString *GuUserName;
@property (nonatomic,strong) NSString *GuUserHeadUrl;
@property (nonatomic,strong) NSString *GuUserHeadURL;

//是否是临时消息
@property (nonatomic,assign) BOOL isTemp;
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
