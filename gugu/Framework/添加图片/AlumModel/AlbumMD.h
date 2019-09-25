//
//  AlbumMD.h
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AlbumMD : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) double result;
@property (nonatomic, strong) NSString *msg;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
