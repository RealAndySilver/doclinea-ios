//
//  PictureDetailViewController.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "PictureDetailViewController.h"

@interface PictureDetailViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIImageView *galleryImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation PictureDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.galleryImage.size;
    self.galleryImageView.frame = CGRectMake(0.0, 0.0, self.galleryImageView.image.size.width, self.galleryImageView.image.size.height);
    self.galleryImageView.center = CGPointMake(self.scrollView.frame.size.width/2.0, self.scrollView.frame.size.height/2.0);
}

-(void)setupUI {
    self.galleryImageView = [[UIImageView alloc] initWithImage:self.galleryImage];
    self.galleryImageView.clipsToBounds = YES;
    self.galleryImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.galleryImageView];
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.galleryImageView;
}

@end
