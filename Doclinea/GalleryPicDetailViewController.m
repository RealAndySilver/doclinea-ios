//
//  GalleryPicDetailViewController.m
//  Doclinea
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GalleryPicDetailViewController.h"

@interface GalleryPicDetailViewController () <UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *galleryImageView;
@end

@implementation GalleryPicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.galleryImageView.image = self.galleryImage;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.galleryImage.size;
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)trashButtonPressed:(id)sender {
    //Show delete alert
    [[[UIActionSheet alloc] initWithTitle:@"¿Estás seguro de borrar la imagen?" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:@"Borrar" otherButtonTitles:nil] showInView:self.view];
}


#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.galleryImageView;
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Butotn index: %li", (unsigned long)buttonIndex);
}

@end
