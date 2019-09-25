//
//  DDPhotoViewController.m
//  PageApp
//
//  Created by BingQiLin 14-6-3.
//
#define sMyScale  2.0

#import "DDPhotoViewController.h"
#import "DDPhotoView.h"

@interface DDPhotoViewController ()

@property (strong, nonatomic) DDPhotoView *photoView;
@property (strong, nonatomic) ALAsset *alAsset;
@end

@implementation DDPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.view.backgroundColor = [UIColor clearColor];
    _photoView = [[DDPhotoView alloc] initWithFrame:self.view.bounds];
    _photoView.contentSize = self.view.bounds.size;
    _photoView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_photoView];    
}

- (void)dealloc
{
    self.photoView = nil;
    self.alAsset = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImage:(UIImage *)image
{
    _photoView.image = image;
}


//相册
- (void)setAlssetImage:(ALAsset *)asset
{
    self.alAsset = asset;
    [_photoView setImage:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage scale:sMyScale orientation:UIImageOrientationUp]];
}

- (void)setImageWithUrl:(NSString *)url
{
    [_photoView setImageWithUrl:url];
}

- (UIImage *)image
{
    return _photoView.image;
}

- (ALAsset *)asset
{
    return self.alAsset;
}

- (NSString *)url
{
    return _photoView.url;
}

-(DDPhotoView *)DDPhotoView
{
    return _photoView;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.photoView setNeedsLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.photoView setNeedsLayout];
}


- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}
@end
