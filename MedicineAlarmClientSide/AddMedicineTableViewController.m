//
//  AddMedicineTableViewController.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/26/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "AddMedicineTableViewController.h"
#import "MedicineTableViewController.h"
#import "MedicineDetailTableViewController.h"
#import "MediDataBase.h"
#import "MediDataSingleton.h"

#import "MBProgressHUD.h"
#import <ParseUI/ParseUI.h>
#import <MobileCoreServices/MobileCoreServices.h>


static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface AddMedicineTableViewController () {
    
    MBProgressHUD *completionHud;
    UIBarButtonItem *popMasterButtonItem;
    UIBarButtonItem *cancelButtonItem;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *medImage;
@property (weak, nonatomic) IBOutlet UITextField *medIDTF;
@property (weak, nonatomic) IBOutlet UITextField *medScienceTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerEngTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerChiTF;
@property (weak, nonatomic) IBOutlet UITextField *medCategoryTF;
@property (weak, nonatomic) IBOutlet UITextField *medIngredientTF;
@property (weak, nonatomic) IBOutlet UITextField *medUsageTF;
@property (weak, nonatomic) IBOutlet UITextField *medAdaptationTF;
@property (weak, nonatomic) IBOutlet UITextField *medSideEffectTF;
@property (weak, nonatomic) IBOutlet UITextField *medNoticeTF;

@property (weak, nonatomic) MBProgressHUD *hud;

@end

@implementation AddMedicineTableViewController {
    UIBarButtonItem *saveButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.medImage.image = [UIImage imageNamed:@"add-photo-placeholder.png"];
    [self.medImage setExclusiveTouch:YES];
    UITapGestureRecognizer *imagepressedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressedReceiveGesture:)];
    [self.medImage addGestureRecognizer:imagepressedGesture];
    [self.medImage setUserInteractionEnabled:YES];
    [self.medIDTF setEnabled:NO];
    [self.medIDTF setClearsOnInsertion:YES];
    [self.medMerEngTF setClearsOnInsertion:YES];
    [self.medMerChiTF setClearsOnInsertion:YES];
    [self.medScienceTF setClearsOnInsertion:YES];
    [self.medCategoryTF setClearsOnInsertion:YES];
    [self.medIngredientTF setClearsOnInsertion:YES];
    [self.medUsageTF setClearsOnInsertion:YES];
    [self.medSideEffectTF setClearsOnInsertion:YES];
    [self.medNoticeTF setClearsOnInsertion:YES];
    [self.medAdaptationTF setClearButtonMode:YES];
    
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDependTextFieldIsNotEmpty)];
    popMasterButtonItem = [[UIBarButtonItem alloc] init];
    cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonItemPressed)];
    
    self.navigationItem.leftBarButtonItem = saveButton;
    
    self.title = @"Add Medicine";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    completionHud = nil;
    popMasterButtonItem = nil;
    cancelButtonItem = nil;
}

-(void)viewDidUnload {
    NSLog(@"ADD viewdidUnload");
    saveButton = nil;
    popMasterButtonItem = nil;
    cancelButtonItem = nil;
    _medIDTF = nil;
    _medImage = nil;
    _medMerEngTF = nil;
    _medMerChiTF = nil;
    _medScienceTF = nil;
    _medIngredientTF = nil;
    _medUsageTF = nil;
    _medSideEffectTF = nil;
    _medNoticeTF= nil;
    _hud = nil;
}

-(void)dealloc {
    NSLog(@"add dealloc");
    saveButton = nil;
    popMasterButtonItem = nil;
    cancelButtonItem = nil;
    _medIDTF = nil;
    _medImage = nil;
    _medMerEngTF = nil;
    _medMerChiTF = nil;
    _medScienceTF = nil;
    _medIngredientTF = nil;
    _medUsageTF = nil;
    _medSideEffectTF = nil;
    _medNoticeTF= nil;
    _hud = nil;
}


-(BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - upload
-(void)saveDataOnParse {
    
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = nil;
    [self resignFirstResponder];
    
    // test for autoincrement
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
    
    // Create PFObject with recipe information.
    PFObject *medObject = [PFObject objectWithClassName:medicineClassName];
    
    /*
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    // test
    [medObject setObject:[formatter numberFromString:self.medIDTF.text] forKeyedSubscript:@"medID"];
     */
    [self.medIDTF setText:[NSString stringWithFormat:@"%@", [MediDataSingleton shareInstance].lastNumber]];
    [medObject incrementKey:@"medID" byAmount:[MediDataSingleton shareInstance].lastNumber];
    
    //TODO: Upload image fail
    
    // image
    NSData *imageData = UIImageJPEGRepresentation(self.medImage.image, 0.8f);
    NSString *fileName = [NSString stringWithFormat:@"%@.png", self.medMerEngTF.text];
    PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    [medObject setObject:imageFile forKeyedSubscript:@"medImageFile"];
    
    // other columns
    [medObject setObject:self.medMerEngTF.text forKeyedSubscript:@"medMerEngName"];
    [medObject setObject:self.medMerChiTF.text forKeyedSubscript:@"medMerChiName"];
    
    [medObject setObject:self.medScienceTF.text forKeyedSubscript:@"medScienceName"];
    [medObject setObject:self.medCategoryTF.text forKeyedSubscript:@"medCategory"];
    
    [medObject setObject:self.medAdaptationTF.text forKeyedSubscript:@"medAdaptation"];
    [medObject setObject:self.medIngredientTF.text forKey:@"medIngredient"];
    [medObject setObject:self.medUsageTF.text forKey:@"medUsage"];
    [medObject setObject:self.medSideEffectTF.text forKey:@"medSideEffect"];
    [medObject setObject:self.medNoticeTF.text forKey:@"medNotice"];
    /*
    NSArray *ingredients = [self.medIngredientTF.text componentsSeparatedByString:@","];
    [medObject setObject:ingredients forKeyedSubscript:@"medIngredient"];
    
    NSArray *usage = [self.medUsageTF.text componentsSeparatedByString:@","];
    [medObject setObject:usage forKeyedSubscript:@"medUsage"];
    
    NSArray *sideEffect = [self.medSideEffectTF.text componentsSeparatedByString:@","];
    [medObject setObject:sideEffect forKeyedSubscript:@"medSideEffect"];
    
    NSArray *notice = [self.medNoticeTF.text componentsSeparatedByString:@","];
    [medObject setObject:notice forKeyedSubscript:@"medNotice"];
    */
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDAnimationFade;
    self.hud.labelText = @"Uploading...";
    [self.hud show:true];
    
    // upload medicine to parse
    [medObject saveInBackgroundWithBlock:^(BOOL successed, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.hud hide:true];
            
            if (!error) {
                
                // show sucess message
                completionHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                completionHud.mode = MBProgressHUDModeCustomView;
                completionHud.labelText = @"Upload Successfully";
                completionHud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
                
                [completionHud show:true];
                [completionHud hide:true afterDelay:1.0f];
                
                
            } else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
        
    }];
    // save in local
    [medObject pinInBackgroundWithBlock:^(BOOL success, NSError *error){
        
        if (success == true) {
            // if success, refresh table view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshParse" object:nil];
        } else {
            NSLog(@"Pin Error: %@", error);
        }
    }];
    
}

#pragma mark - choose camera or photo roll
/* old school method
// upload Image when choose first row
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Select" message:@"Camera or Photo Roll" delegate:self cancelButtonTitle:@
                              "Cancel"otherButtonTitles:@"Camara", @"Photo Roll", nil];
    
    if (indexPath.row == 0) {
        [alertView show];
    }
}*/
// cell is unselectable
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(void)imageViewPressedReceiveGesture:(UITapGestureRecognizer *)gestureRecognizer {
    /*
     // this line is depended which imageview is tapped, we dont need it here
     UIImageView *image = (UIImageView *)gestureRecognizer.view;
     switch (image.tag) {
     case 1:
     // do work here
     break;
     default:
     break;
     }*/
    
    if ([UIAlertController class]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Source Option" message:@"Camera or Album Roll" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self useCamera];
        }];
        
        UIAlertAction *albumRollAction = [UIAlertAction actionWithTitle:@"Album Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showPhotoLibrary];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cameraAction];
        [alertController addAction:albumRollAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else {
        //
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Select" message:@"Camera or Photo Roll" delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"Camara", @"Photo Roll", nil];
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 2) {
        [self showPhotoLibrary];

    } else if (buttonIndex == 1) {
        [self useCamera];
    }
}

-(void)showPhotoLibrary {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]== NO)) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Display saved pictures from the camera Roll album.
    mediaUI.mediaTypes = @[(NSString *)kUTTypeImage];
    
    // Hides the controls for moving & scaling picture.
    mediaUI.allowsEditing = YES;
    // delegate this will step into imagePickerController method
    mediaUI.delegate = self;
    
    [self.navigationController presentViewController:mediaUI animated:YES completion:nil];
}
//TODO: save photo in camera roll
-(void)useCamera {
    
    // check Camera unavailable.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        
        [self showPhotoLibrary];
    }
    // check Camera avalible.
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == YES) {
        
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        // use camera, and rear.
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // when use camera, set it to capture mode.
        ipc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        // designate what type of media, add photo or video if needed.
        // here is just image.
        ipc.mediaTypes = [NSArray arrayWithObject:@"public.image"];
        //        ipc.allowsEditing = NO;
        //        if (ipc.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //
        //            CameraView *cv = [[CameraView alloc] init];
        //            [ipc.cameraOverlayView addSubview:cv.myOverlayView];
        //        }
        ipc.showsCameraControls = YES;
        // designate Viewcontroll from delegate
        ipc.delegate = self;
        
        //        currentImagePicker = ipc;
        // show UIImagePickerController
        [self presentViewController:ipc animated:YES completion:^{
            //
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.medImage.image = originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    /*
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *imgEdited = [info objectForKey:UIImagePickerControllerEditedImage];
        //
    }
    */
    //TODO:
}
// Save image.
-(void)saveImage:(UIImage *)image {
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary *)info {
    
    // notify if save successfully.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo" message:@"Save Successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField andTextViewShouldReturn:(UITextView *)textView {
    
    [textField resignFirstResponder];
    [textView resignFirstResponder];
    return YES;
}

#pragma mark - split view delegate

-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
    if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        self.navigationItem.leftBarButtonItem = popMasterButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void)cancelBarButtonItemPressed {
    
    self.navigationItem.leftBarButtonItem = popMasterButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 11;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// textfield must add somthing
-(void)saveDependTextFieldIsNotEmpty {
    /*
    if ([self.medIDTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品ID欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    */
    if ([self.medMerEngTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品英文欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medMerChiTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品中文欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medScienceTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品學名欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medCategoryTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品分類欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medIngredientTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品成分欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medUsageTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品用途欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medSideEffectTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品副作用欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    }
    else if ([self.medNoticeTF.text isEqualToString:@""]) {
        UIAlertView *emptyAlert = [[UIAlertView alloc] initWithTitle:@"藥品注意事項欄位" message:@"請確實填入資料" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [emptyAlert show];
    } else {

        [self saveDataOnParse];
    }
}

@end
