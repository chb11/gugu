//
//  ImgModel.m
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "ImgModel.h"


NSString *const kImgModelResult = @"result";
NSString *const kImgModelImgVisitPath = @"img_visit_path";
NSString *const kImgModelMsg = @"msg";
NSString *const kImgModelImgPath = @"img_path";


@interface ImgModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation ImgModel

@synthesize result = _result;
@synthesize imgVisitPath = _imgVisitPath;
@synthesize msg = _msg;
@synthesize imgPath = _imgPath;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.result = [[self objectOrNilForKey:kImgModelResult fromDictionary:dict] doubleValue];
            self.imgVisitPath = [self objectOrNilForKey:kImgModelImgVisitPath fromDictionary:dict];
            self.msg = [self objectOrNilForKey:kImgModelMsg fromDictionary:dict];
            self.imgPath = [self objectOrNilForKey:kImgModelImgPath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.result] forKey:kImgModelResult];
    [mutableDict setValue:self.imgVisitPath forKey:kImgModelImgVisitPath];
    [mutableDict setValue:self.msg forKey:kImgModelMsg];
    [mutableDict setValue:self.imgPath forKey:kImgModelImgPath];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.result = [aDecoder decodeDoubleForKey:kImgModelResult];
    self.imgVisitPath = [aDecoder decodeObjectForKey:kImgModelImgVisitPath];
    self.msg = [aDecoder decodeObjectForKey:kImgModelMsg];
    self.imgPath = [aDecoder decodeObjectForKey:kImgModelImgPath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_result forKey:kImgModelResult];
    [aCoder encodeObject:_imgVisitPath forKey:kImgModelImgVisitPath];
    [aCoder encodeObject:_msg forKey:kImgModelMsg];
    [aCoder encodeObject:_imgPath forKey:kImgModelImgPath];
}

- (id)copyWithZone:(NSZone *)zone
{
    ImgModel *copy = [[ImgModel alloc] init];
    
    if (copy) {

        copy.result = self.result;
        copy.imgVisitPath = [self.imgVisitPath copyWithZone:zone];
        copy.msg = [self.msg copyWithZone:zone];
        copy.imgPath = [self.imgPath copyWithZone:zone];
    }
    
    return copy;
}


@end
