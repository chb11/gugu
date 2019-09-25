//
//  DDPhotoView.h
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//

#import <UIKit/UIKit.h>

@interface DDPhotoView : UIScrollView<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (assign) BOOL adjustsContentModeForImageSize;
@property (assign, nonatomic) NSInteger  pageIndex;

- (UIImage *)image;
- (void)setImage:(UIImage *)image;

- (void)setImageWithUrl:(NSString *)url;

- (NSString *)url;

- (void)bouncePhoto;
- (void)bouncePhotoWithDuration:(NSTimeInterval)duration scaleAmount:(CGFloat)scale;

- (void)zoomToPoint:(CGPoint)point;
@end
