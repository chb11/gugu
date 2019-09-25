//
//  CB_FriendInfoModel.h
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_FriendInfoModel : NSObject

@property (nonatomic,strong) NSString *GuNum;
@property (nonatomic,strong) NSString *FriendId;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *MemoName;
@property (nonatomic,strong) NSString *NickName;
@property (nonatomic,strong) NSString *Phone;
@property (nonatomic,strong) NSString *PhotoUrl;
@property (nonatomic,strong) NSString *HeadPhotoURL;
@property (nonatomic,assign) BOOL IsFriend;

@end

NS_ASSUME_NONNULL_END
