//
//  AlbumImages.h
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AlbumImages : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *imageDetailPath;
@property (nonatomic, strong) NSString *imageValue;
@property (nonatomic, strong) NSString *imageListPath;
@property (nonatomic, assign) double sort;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
