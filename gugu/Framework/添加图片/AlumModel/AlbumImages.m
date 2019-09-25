//
//  AlbumImages.m
//
//  Created by 岩 陈 on 15/12/18
//  Copyright (c) 2015 __MyCompanyName__. All rights reserved.
//

#import "AlbumImages.h"


NSString *const kAlbumImagesImageDetailPath = @"image_detail_path";
NSString *const kAlbumImagesImageValue = @"image_value";
NSString *const kAlbumImagesImageListPath = @"image_list_path";
NSString *const kAlbumImagesSort = @"sort";


@interface AlbumImages ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation AlbumImages

@synthesize imageDetailPath = _imageDetailPath;
@synthesize imageValue = _imageValue;
@synthesize imageListPath = _imageListPath;
@synthesize sort = _sort;


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
            self.imageDetailPath = [self objectOrNilForKey:kAlbumImagesImageDetailPath fromDictionary:dict];
            self.imageValue = [self objectOrNilForKey:kAlbumImagesImageValue fromDictionary:dict];
            self.imageListPath = [self objectOrNilForKey:kAlbumImagesImageListPath fromDictionary:dict];
            self.sort = [[self objectOrNilForKey:kAlbumImagesSort fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.imageDetailPath forKey:kAlbumImagesImageDetailPath];
    [mutableDict setValue:self.imageValue forKey:kAlbumImagesImageValue];
    [mutableDict setValue:self.imageListPath forKey:kAlbumImagesImageListPath];
    [mutableDict setValue:[NSNumber numberWithDouble:self.sort] forKey:kAlbumImagesSort];

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

    self.imageDetailPath = [aDecoder decodeObjectForKey:kAlbumImagesImageDetailPath];
    self.imageValue = [aDecoder decodeObjectForKey:kAlbumImagesImageValue];
    self.imageListPath = [aDecoder decodeObjectForKey:kAlbumImagesImageListPath];
    self.sort = [aDecoder decodeDoubleForKey:kAlbumImagesSort];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_imageDetailPath forKey:kAlbumImagesImageDetailPath];
    [aCoder encodeObject:_imageValue forKey:kAlbumImagesImageValue];
    [aCoder encodeObject:_imageListPath forKey:kAlbumImagesImageListPath];
    [aCoder encodeDouble:_sort forKey:kAlbumImagesSort];
}

- (id)copyWithZone:(NSZone *)zone
{
    AlbumImages *copy = [[AlbumImages alloc] init];
    
    if (copy) {

        copy.imageDetailPath = [self.imageDetailPath copyWithZone:zone];
        copy.imageValue = [self.imageValue copyWithZone:zone];
        copy.imageListPath = [self.imageListPath copyWithZone:zone];
        copy.sort = self.sort;
    }
    
    return copy;
}


@end
