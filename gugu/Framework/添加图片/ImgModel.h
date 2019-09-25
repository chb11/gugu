//
//  ImgModel.h
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ImgModel : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double result;
@property (nonatomic, strong) NSString *imgVisitPath;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *imgPath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
