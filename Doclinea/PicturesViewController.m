//
//  PicturesViewController.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "PicturesViewController.h"
#import "UIImageView+WebCache.h"
#import "DoctorGalleryCell.h"
#import "PictureDetailViewController.h"

@interface PicturesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation PicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Actions 

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.picturesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DoctorGalleryCell *cell = (DoctorGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"PictureCell" forIndexPath:indexPath];
    [cell.galleryPicImageView sd_setImageWithURL:self.picturesArray[indexPath.item][@"image_url"]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DoctorGalleryCell *cell = (DoctorGalleryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PictureDetailViewController *pictureDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PictureDetail"];
    pictureDetailVC.galleryImage = cell.galleryPicImageView.image;
    [self.navigationController pushViewController:pictureDetailVC animated:YES];
}

@end
