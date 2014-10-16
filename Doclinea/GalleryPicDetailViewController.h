//
//  GalleryPicDetailViewController.h
//  Doclinea
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Doctor;

@interface GalleryPicDetailViewController : UIViewController
@property (strong, nonatomic) UIImage *galleryImage;
@property (strong, nonatomic) NSString *imageID;
@property (strong, nonatomic) Doctor *doctor;
@property (strong, nonatomic) NSString *imageName;
@end
