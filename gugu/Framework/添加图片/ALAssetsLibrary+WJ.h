//
//  ALAssetsLibrary+WJ.h
//  PPLiaoMei
//
//  Created by BeRich2019 on 16/11/24.
//  Copyright © 2016年 BingQiLin. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetsLibrary (WJ)
- (void)latestAsset:(void(^_Nullable)(ALAsset * _Nullable asset,NSError *_Nullable error)) block;


- (void)videoAsset:(void (^_Nullable)(ALAsset * _Nullable, NSError *_Nullable))block ;

- (void)testRun;

@end
