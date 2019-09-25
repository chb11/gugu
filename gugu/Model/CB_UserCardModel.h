//
//  CB_UserCardModel.h
//  gugu
//
//  Created by Mike Chen on 2019/4/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CB_UserCardModel : NSObject

@property (nonatomic,strong) NSString *UserName;
@property (nonatomic,strong) NSString *PhotoUrl;
@property (nonatomic,strong) NSString *Phone;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSArray *AddressList;
@end

NS_ASSUME_NONNULL_END
