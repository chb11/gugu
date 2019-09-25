//
//  NewsListModel.h
//  gugu
//
//  Created by Mike Chen on 2019/4/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsListModel : NSObject

@property (nonatomic,strong) NSString *PushTime;
@property (nonatomic,strong) NSString *Imgsrc;
@property (nonatomic,strong) NSString *Digest;
@property (nonatomic,strong) NSString *Title;
@property (nonatomic,strong) NSString *CreatDate;
@property (nonatomic,strong) NSString *Guid;
@property (nonatomic,strong) NSString *Source;
@property (nonatomic,strong) NSString *Url;

@end

NS_ASSUME_NONNULL_END
