//
//  DoctorGalleryViewController.m
//  Doclinea
//
//  Created by Developer on 7/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DoctorGalleryViewController.h"
#import "DoctorGalleryCell.h"
#import "Doctor.h"
#import "SharedDoctor.h"
#import "MBProgressHUD.h"
#import "ServerCommunicator.h"
#import "UIImageView+WebCache.h"
#import "NSString+AddOns.h"
#import "GalleryPicDetailViewController.h"
@import MobileCoreServices;
@import AssetsLibrary;

@interface DoctorGalleryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, ServerCommunicatorDelegate>
@property (strong, nonatomic) Doctor *doctor;
@end

@implementation DoctorGalleryViewController

#pragma mark - Lazy Instantiation

-(Doctor *)doctor {
    if (!_doctor) {
        _doctor = [[SharedDoctor sharedDoctor] getSavedDoctor];
    }
    return _doctor;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.doctor.gallery count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DoctorGalleryCell *cell = (DoctorGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DoctorGalleryCell" forIndexPath:indexPath];
    [cell.galleryPicImageView sd_setImageWithURL:self.doctor.gallery[indexPath.item][@"image_url"]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //Get the selected cell
    DoctorGalleryCell *cell = (DoctorGalleryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    //Go To PicDetail ViewController
    GalleryPicDetailViewController *galleryPicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GalleryPicDetail"];
    galleryPicVC.galleryImage = cell.galleryPicImageView.image;
    galleryPicVC.imageID = self.doctor.gallery[indexPath.item][@"_id"];
    [self.navigationController pushViewController:galleryPicVC animated:YES];
}

#pragma mark - Server Stuff 

-(void)sendPhotoToServer:(UIImage *)photo withPhotoName:(NSString *)photoName {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ServerCommunicator *serverCommunicator = [[ServerCommunicator alloc] init];
    serverCommunicator.delegate = self;
    
    // post body
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(photo, 0.5);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"image", photoName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [serverCommunicator callServerWithPOSTMethod:[NSString stringWithFormat:@"Doctor/AddPicToGallery/%@", self.doctor.identifier] andData:body];
}

-(void)receivedDataFromServer:(NSDictionary *)dictionary withMethodName:(NSString *)methodName {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if ([methodName isEqualToString:[NSString stringWithFormat:@"Doctor/AddPicToGallery/%@", self.doctor.identifier]]) {
        if (dictionary) {
            NSLog(@"Respuesta correcta del add pic: %@", dictionary);
            if ([dictionary[@"status"] boolValue]) {
                NSLog(@"Entreeeeeee********************");
                [[[UIAlertView alloc] initWithTitle:@"Éxito!" message:@"La foto se ha subido con éxito. Por favor vuelve a cargar en unos momentos para ver la información actualizada" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        } else {
            NSLog(@"Respuesta incorrecta del add pic: %@", dictionary);
        }
    }
}

-(void)serverError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSLog(@"Error en el server: %@ %@", error, [error localizedDescription]);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error intentando guardar la imagen. Por favor revisa que estés conectado a internet e intenta de nuevo." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Actions 

- (IBAction)addPicButtonPressed:(id)sender {
    //Choose if the pic will be taken from the camera or the phot library
    [[[UIAlertView alloc] initWithTitle:@"Elegir Imagen" message:@"¿De donde deseas elegir la imagen?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Cámara", @"Librería de Fotos", nil] show];
}

#pragma mark - Camera Stuff

-(void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            //Present the picker
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //Camara
        [self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
    } else if (buttonIndex == 2) {
        //Libreria de fotos
        [self presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    if (!photo) photo = info[UIImagePickerControllerOriginalImage];
    if (photo) {
        //Generate the random string name for the photo
        NSString *randomString = [NSString generateRandomString:10];
        NSString *photoName = [NSString stringWithFormat:@"%@.jpg", randomString];
        [self sendPhotoToServer:photo withPhotoName:photoName];
    }
    
    // get the ref url
    /*NSURL *refURL = info[UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            NSLog(@"[imageRep filename] : %@", [imageRep filename]);
        } else {
            NSLog(@"Nombre de la imagen: %@", [NSString generateRandomString:10]);
        }
    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];*/
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
