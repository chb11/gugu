//
//  DDPhotoViewController.h
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class DDPhotoView;

@interface DDPhotoViewController : UIViewController

- (void)setImage:(UIImage *)image;
@property (assign, nonatomic) NSInteger  pageIndex;
//相册
- (void)setAlssetImage:(ALAsset *)asset;

- (void)setImageWithUrl:(NSString *)url;

- (UIImage *)image;

- (ALAsset *)asset;

- (NSString *)url;

//获取DDPhotoView
- (DDPhotoView *)DDPhotoView;
@end
