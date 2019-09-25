//
//  CB_FriendModel.h
//  gugu
//
//  Created by Mike Chen on 2019/3/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_FriendModel : NSObject

@property (nonatomic,strong) NSString *FriendUserName;
@property (nonatomic,strong) NSString *FriendId;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *FriendHeadPhoto;
@property (nonatomic,strong) NSString *HeadPhotoURL;

@end

NS_ASSUME_NONNULL_END
