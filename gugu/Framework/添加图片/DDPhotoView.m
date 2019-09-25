//
//  DDPhotoView.m
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//

#import "DDPhotoView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "DDPhotoNotification.h"

@interface DDPhotoView ()

@property (strong, nonatomic) NSString *imageUrl;
@end
@implementation DDPhotoView

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)dealloc
{
    self.imageView = nil;
    self.imageUrl = nil;
}

- (void)initialize
{
    [self setDelegate:self];
    [self setBouncesZoom:YES];

    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.imageView];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self setClipsToBounds:NO];
    [self.imageView setClipsToBounds:NO];
    [self setMaximumZoomScale:5.0];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self loadTouchGestureRecognizers];
}

#pragma mark - Views Management

- (void)layoutSubviews
{
    [super layoutSubviews];
    //This will immediately stop any animations the image view is doing.
    [UIView animateWithDuration:0
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.layer setAffineTransform:CGAffineTransformMakeScale(1, 1)];
                     }completion:nil];
    
    if (![self isZoomed] && !CGRectEqualToRect(self.bounds, [self.imageView frame])) {
        [self.imageView setFrame:self.bounds];
        return;
    }
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
    
    [self setContentModeForImageSize:self.imageView.image.size];
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    NSAssert(image, @"Image cannot be nil");
    [self.imageView setAlpha:0];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.imageView setAlpha:1];
                     }completion:nil];
    
    [self setContentModeForImageSize:image.size];
    [self.imageView setImage:image];
}

- (void)setImageWithUrl:(NSString *)url
{
    if (!url) {
        return;
    }
    NSAssert(url, @"url cannot be nil");
    self.imageUrl = url;
    NSString *imageUrl = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    UIActivityIndicatorView* activityIndicatorView = [ [ UIActivityIndicatorView alloc ]
                                                      initWithFrame:CGRectMake(0,0,30.0,30.0)];
    activityIndicatorView.center = self.center;
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    __block UIImageView * imgView = self.imageView;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [activityIndicatorView stopAnimating];
        if (!image||error) {
            imgView.image = [UIImage imageNamed:DEFAULT_BG_IMAGE];
        }
    }];
}

- (NSString *)url
{
    return _imageUrl;
}

- (void)setContentModeForImageSize:(CGSize)size
{
    if(self.adjustsContentModeForImageSize == NO){
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        return;
    }
    
    UIViewContentMode newContentMode;
    if((size.height < self.imageView.bounds.size.height) &&
       (size.width  < self.imageView.bounds.size.width ) ){
        newContentMode = UIViewContentModeCenter;
    } else {
        newContentMode = UIViewContentModeScaleAspectFit;
    }
    
    if(self.imageView.contentMode != newContentMode){
        [self.imageView setContentMode:newContentMode];
    }
}

- (void)bouncePhoto
{
    [self bouncePhotoWithDuration:0.38 scaleAmount:0.03];
}

- (void)bouncePhotoWithDuration:(NSTimeInterval)duration scaleAmount:(CGFloat)scale
{
    [UIView animateWithDuration:(duration*0.5)
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn|
     UIViewAnimationOptionAllowUserInteraction|
     UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat scaleAmount = self.isZoomed ? scale : -scale;
                         [self.layer setAffineTransform:CGAffineTransformMakeScale(1+scaleAmount,
                                                                                   1+scaleAmount)];
                     } completion:^(BOOL finished){
                         [UIView animateWithDuration:(duration*0.5)
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut|
                          UIViewAnimationOptionAllowUserInteraction|
                          UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [self.layer setAffineTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                          }completion:nil];
                     }];
    
}

- (void)zoomToPoint:(CGPoint)point
{
    if(self.imageView.image == nil){
        return;
    }
    
    CGRect zoomRect = self.isZoomed ? [self bounds] : [self zoomRectForScale:self.maximumZoomScale
                                                                  withCenter:point];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect = self.frame;
    
    zoomRect.size.height /= scale;
    zoomRect.size.width /= scale;
    
    //the origin of a rect is it's top left corner,
    //so subtract half the width and height of the rect from it's center point to get to that x,y
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - Getters

- (CGRect)frameForPhoto
{
    if(self.imageView.image == nil){
        return CGRectZero;
    }
    
    CGRect photoDisplayedFrame=CGRectZero;
    if(self.imageView.contentMode == UIViewContentModeScaleAspectFit){
        photoDisplayedFrame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size, self.imageView.frame);
    } else if(self.imageView.contentMode==UIViewContentModeCenter) {
        CGPoint photoOrigin = CGPointZero;
        photoOrigin.x = (self.imageView.frame.size.width - (self.imageView.image.size.width * self.zoomScale)) * 0.5;
        photoOrigin.y = (self.imageView.frame.size.height - (self.imageView.image.size.height * self.zoomScale)) * 0.5;
        photoDisplayedFrame = CGRectMake(photoOrigin.x, photoOrigin.y,self.imageView.image.size.width*self.zoomScale,
                                         self.imageView.image.size.height*self.zoomScale);
    } else {
        NSAssert(0, @"Don't know how to generate frame for photo with current content mode.");
    }
    
    return photoDisplayedFrame;
}



- (BOOL)canTagPhotoAtNormalizedPoint:(CGPoint)normalizedPoint
{
    if((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
       (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)){
        return YES;
    }
    return NO;
}

- (CGPoint)normalizedPositionForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    point.x -= (frame.origin.x - self.frame.origin.x);
    point.y -= (frame.origin.y - self.frame.origin.y);
    
    CGPoint normalizedPoint = CGPointMake(point.x / frame.size.width,
                                          point.y / frame.size.height);
    
    return normalizedPoint;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return (self.image ? self.imageView : nil);
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (BOOL)isZoomed
{
    return ((self.zoomScale == self.minimumZoomScale) ? NO : YES);
}

#pragma mark - Loading

- (void)loadTouchGestureRecognizers
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(didRecognizeSingleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singleTapRecognizer];
    
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(didRecognizeDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(didRecognizeLongPress:)];
    [self addGestureRecognizer:longPressGesture];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
}

#pragma mark - Event Hooks

- (void)didRecognizeSingleTap:(id)sender
{
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"Expected notification from a single tap gesture");
    
    UITapGestureRecognizer *tapGesture = sender;
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                             inFrame:[self frameForPhoto]];
    
    NSDictionary *tapInfo = @{@"touchGesture" : sender,
                              @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewSingleTapNotification
                                                        object:self
                                                      userInfo:tapInfo];
}

- (void)didRecognizeDoubleTap:(id)sender
{
    NSAssert([sender isKindOfClass:[UITapGestureRecognizer class]], @"Expected notification from a double tap gesture");
    
    UITapGestureRecognizer *tap = sender;
    
    CGPoint touchPoint = [tap locationInView:self];
    CGPoint normalizedTapLocation = [self normalizedPositionForPoint:touchPoint
                                                             inFrame:[self frameForPhoto]];
    
    NSDictionary *tapInfo = @{@"touchGesture" : sender,
                              @"normalizedTapLocation" : [NSValue valueWithCGPoint:normalizedTapLocation]};
    [self zoomToPoint:[tap locationInView:self]];
    [[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewDoubleTapNotification
                                                        object:self
                                                      userInfo:tapInfo];
}

-(void)didRecognizeLongPress:(id)sender
{
    NSAssert([sender isKindOfClass:[UILongPressGestureRecognizer class]], @"Expected notification from a double tap gesture");

    UILongPressGestureRecognizer * gestureRecognizer = sender;
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateEnded:
        {
           
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateBegan:
        {
        }
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        default:
            break;
    }
    
}

@end
