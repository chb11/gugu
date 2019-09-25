//
//  UserModel.h
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject


@property (nonatomic,strong) NSString *UserName;
@property (nonatomic,strong) NSString *Password;
@property (nonatomic,strong) NSString *Email;
@property (nonatomic,strong) NSString *Phone;
@property (nonatomic,strong) NSString *GuNum;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *HeadPhoto;
@property (nonatomic,strong) NSString *HeadPhotoURL;
@property (nonatomic,strong) NSString *OnlineId;

+ (UserModel *)shareInstance;

-(void)reloadModelWith:(UserModel *)model;

- (NSDictionary *)dictionaryRepresentation;

+(instancetype)newModelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
