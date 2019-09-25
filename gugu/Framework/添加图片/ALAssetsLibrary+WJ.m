//
//  ALAssetsLibrary+WJ.m
//  PPLiaoMei
//
//  Created by BeRich2019 on 16/11/24.
//  Copyright © 2016年 BingQiLin. All rights reserved.
//

#import "ALAssetsLibrary+WJ.h"

@implementation ALAssetsLibrary (WJ)
- (void)latestAsset:(void (^)(ALAsset * _Nullable, NSError *_Nullable))block {
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSLog(@"count = %ld",group.numberOfAssets);
            if (group.numberOfAssets==0) {
                block(nil,nil);
            }

            [group enumerateAssetsWithOptions:NSEnumerationConcurrent/*遍历方式*/ usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result&&index==0) {
                    if (block) {
                        block(result,nil);
                    }
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    } failureBlock:^(NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        }
    }];
}


- (void)videoAsset:(void (^)(ALAsset * _Nullable, NSError *_Nullable))block {
    [self enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
            NSLog(@"count = %ld",group.numberOfAssets);
            if (group.numberOfAssets==0) {
                block(nil,nil);
            }
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *sstop) {
                if (result&&index==0) {
                    if (block) {
                        block(result,nil);
                    }
                    *sstop = YES;
                    *stop = YES;
                }
            }];

        }else {
            
        }
    } failureBlock:^(NSError *error) {
        if (error) {
            if (block) {
                block(nil,error);
            }
        }
    }];
}

- (void)testRun
{
    __block NSMutableArray * groupArrays = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group != nil) {
                [groupArrays addObject:group];
            } else {
                [groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *sstop) {
                        if ([result thumbnail] != nil) {
                            
                            ALAssetRepresentation *representation = [result defaultRepresentation];
                            NSLog(@"fileName:%@", [representation filename]);
                            NSLog(@"index:%d", index);

                            if (*sstop) {
                                NSLog(@"over");
                            }
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                                
                            }
                            // 视频
                            else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo] ){
                                
                            }
                        }
                    }];
                }];
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error)
        {
            
        };
        
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]  init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:listGroupBlock failureBlock:failureBlock];
    });
}






@end
