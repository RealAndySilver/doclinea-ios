//
//  GalleryPicDetailViewController.m
//  Doclinea
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "GalleryPicDetailViewController.h"
#import "ServerCommunicator.h"
#import "MBProgressHUD.h"
#import "Doctor.h"

@interface GalleryPicDetailViewController () <UIScrollViewDelegate, UIActionSheetDelegate, ServerCommunicatorDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *galleryImageView;
@end

@implementation GalleryPicDetailViewController

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

- (IBAction)trashButtonPressed:(id)sender {
    //Show delete alert
    [[[UIActionSheet alloc] initWithTitle:@"¿Estás seguro de borrar la imagen?" delegate:self cancelButtonTitle:@"Cancelar" destructiveButtonTitle:@"Borrar" otherButtonTitles:nil] showInView:self.view];
}

#pragma mark - Server Stuff 

-(void)deletePhotoInServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/RemoveGalleryPic/%@",self.doctor.identifier] andParameter:[NSString stringWithFormat:@"name=%@", self.imageName] httpMethod:@"POST"];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/RemoveGalleryPic/%@",self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Resputa correcta del remove: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                Doctor *doctor = [[Doctor alloc] initWithDoctorInfo:dictionary[@"response"]];
                [self saveDoctorInUserDefaults:doctor];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DoctorUpdated" object:nil];
                
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La foto se ha borrado de forma exitosa" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                [self backButtonPressed:nil];
                
            }
            
        } else {
            NSLog(@"Respueta incorrecta del remove: %@" ,dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Hubo un error al intentar borrar la imagen. Por favor revisa que estés conectadoa  internet e intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - User Defaults

-(void)saveDoctorInUserDefaults:(Doctor *)doctor {
    NSLog(@"NOMBRE DEL DOCTOR A GUARDA: %@", doctor.name);
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:doctor];
    [[NSUserDefaults standardUserDefaults] setObject:encodedData forKey:@"doctor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Delete Photo
        [self deletePhotoInServer];
    }
}

@end
