//
//  AlbumMD.m
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "AlbumMD.h"
#import "AlbumImages.h"


NSString *const kAlbumMDImages = @"images";
NSString *const kAlbumMDResult = @"result";
NSString *const kAlbumMDMsg = @"msg";


@interface AlbumMD ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation AlbumMD

@synthesize images = _images;
@synthesize result = _result;
@synthesize msg = _msg;


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
    NSObject *receivedAlbumImages = [dict objectForKey:kAlbumMDImages];
    NSMutableArray *parsedAlbumImages = [NSMutableArray array];
    if ([receivedAlbumImages isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedAlbumImages) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedAlbumImages addObject:[AlbumImages modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedAlbumImages isKindOfClass:[NSDictionary class]]) {
       [parsedAlbumImages addObject:[AlbumImages modelObjectWithDictionary:(NSDictionary *)receivedAlbumImages]];
    }

    self.images = [NSArray arrayWithArray:parsedAlbumImages];
            self.result = [[self objectOrNilForKey:kAlbumMDResult fromDictionary:dict] doubleValue];
            self.msg = [self objectOrNilForKey:kAlbumMDMsg fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForImages = [NSMutableArray array];
    for (NSObject *subArrayObject in self.images) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForImages addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForImages addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForImages] forKey:kAlbumMDImages];
    [mutableDict setValue:[NSNumber numberWithDouble:self.result] forKey:kAlbumMDResult];
    [mutableDict setValue:self.msg forKey:kAlbumMDMsg];

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

    self.images = [aDecoder decodeObjectForKey:kAlbumMDImages];
    self.result = [aDecoder decodeDoubleForKey:kAlbumMDResult];
    self.msg = [aDecoder decodeObjectForKey:kAlbumMDMsg];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_images forKey:kAlbumMDImages];
    [aCoder encodeDouble:_result forKey:kAlbumMDResult];
    [aCoder encodeObject:_msg forKey:kAlbumMDMsg];
}

- (id)copyWithZone:(NSZone *)zone
{
    AlbumMD *copy = [[AlbumMD alloc] init];
    
    if (copy) {

        copy.images = [self.images copyWithZone:zone];
        copy.result = self.result;
        copy.msg = [self.msg copyWithZone:zone];
    }
    
    return copy;
}


@end
