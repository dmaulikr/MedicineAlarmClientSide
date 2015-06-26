//
//  MedicineDetailTableViewController.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/24/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MedicineDetailTableViewController.h"
#import "MediDataBase.h"
#import "MBProgressHUD.h"
#import "MedicineTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface MedicineDetailTableViewController () {
    UIBarButtonItem *editButton;
    UIBarButtonItem *saveButton;
    UIBarButtonItem *backButton;
    UIBarButtonItem *popMasterViewButton;
    UIBarButtonItem *cancelButton;
    NSMutableDictionary *tmpStorage;
    MBProgressHUD *UploadingHud;

}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (weak, nonatomic) IBOutlet PFImageView *medImageView;

@property (weak, nonatomic) IBOutlet UITextField *medIDTF;
@property (weak, nonatomic) IBOutlet UITextField *medScienceTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerEngNameTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerChiNameTF;
@property (weak, nonatomic) IBOutlet UITextField *medCategoryTF;
@property (weak, nonatomic) IBOutlet UITextField *medIngredientTF;


@property (weak, nonatomic) IBOutlet UITextView *medUsageTV;
@property (weak, nonatomic) IBOutlet UITextView *medSideEffectTV;
@property (weak, nonatomic) IBOutlet UITextView *medNoticeTV;
@property (weak, nonatomic) IBOutlet UITextView *medAdaptationTV;

@end

@implementation MedicineDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    /*
    //TODO:  this line cause crash: why???????????
     [MedicineDetailTableViewController respondsToSelector:]: message sent to deallocated instance 0x7fa71629f100
    self.splitViewController.delegate = self;
     */
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fromPhotoRoll) name:@"fromPhotoRoll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fromMedicineTableView) name:@"fromMedicineTableView" object:nil];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setAllEditableAndTextField:)];
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(updateData)];
    popMasterViewButton = [[UIBarButtonItem alloc] init];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    popMasterViewButton = self.splitViewController.displayModeButtonItem;
    popMasterViewButton.title = NSLocalizedString(@"Medicine", @"藥品資料庫");
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [self setNaviItemRBarBtn:editButton andLBarBtn:nil];
    } else {

        [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
    }
    
    
    
    tmpStorage = [[NSMutableDictionary alloc] init];
    
    // uneditable
    [self setAllUneditable];
    // load segue
    [self loadTableViewDataFromMaster];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    editButton = nil;
    saveButton = nil;
    backButton = nil;
    popMasterViewButton = nil;
    cancelButton = nil;
    tmpStorage = nil;
    UploadingHud = nil;

}



-(void)viewDidAppear:(BOOL)animated {
    UIDevice *device;
    
    if (device == UIUserInterfaceIdiomPhone) {
        popMasterViewButton = [[UIBarButtonItem alloc] init];
        popMasterViewButton = self.splitViewController.displayModeButtonItem;
        popMasterViewButton.title = NSLocalizedString(@"Medicine", @"藥品資料庫");
    } else {
        //
    }
     
}

-(void)dealloc {
    NSLog(@"Right: MedicineDetailTableView dismiss");
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    _medIDTF = nil;
    _medImageView = nil;
    _medMerEngNameTF = nil;
    _medMerChiNameTF = nil;
    _medScienceTF = nil;
    _medIngredientTF = nil;
    _medUsageTV = nil;
    _medSideEffectTV = nil;
    _medNoticeTV = nil;
    _medAdaptationTV = nil;
}


-(void)viewWillAppear:(BOOL)animated {
    
    /*
     if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
     
     } else {
     if (self.splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
     
     [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
     
     } else {
     self.navigationItem.leftBarButtonItem = nil;
     }
     }*/
    [super viewWillAppear:YES];
}

-(BOOL)shouldAutorotate {
    return true;
}

-(void)orientationChanged:(NSNotification *)notification {
    
    UIDevice *device = [UIDevice currentDevice];
    
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            //
            NSLog(@"portrait");
            [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            //
            [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
            break;
        case UIDeviceOrientationLandscapeLeft:
            //
            if (device == UIUserInterfaceIdiomPhone) {
                [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
            } else {
                [self setNaviItemRBarBtn:editButton andLBarBtn:nil];
            }
            NSLog(@"landscapeleft");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"landscaperight");
            if (device == UIUserInterfaceIdiomPhone) {
                [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
            } else {
                [self setNaviItemRBarBtn:editButton andLBarBtn:nil];
            }
            break;
        default:
            break;
    }
}


-(void)fromMedicineTableView {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
        popMasterViewButton.enabled = NO;
    } else {
        [self setNaviItemRBarBtn:editButton andLBarBtn:popMasterViewButton];
    }
    
}

-(void)fromPhotoRoll {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [self setNaviItemRBarBtn:cancelButton andLBarBtn:saveButton];
    } else {
        [self setNaviItemRBarBtn:cancelButton andLBarBtn:saveButton];;
    }
}

-(void)loadTableViewDataFromMaster {
    
    // segue by code
    
    self.title = self.mediDetail.medMerEngName;
    //
    if (self.mediDetail.medImageFile == nil) {
        [self setMedImageView:nil];
    } else {
        self.medImageView.file = self.mediDetail.medImageFile;
    }
    
    [self.medIDTF setText:self.mediDetail.medID];
    self.medScienceTF.text = self.mediDetail.medScienceName;
    [self.medMerEngNameTF setText:self.mediDetail.medMerEngName];
    self.medMerChiNameTF.text = self.mediDetail.medMerChiName;
    [self.medCategoryTF setText:self.mediDetail.medCategory];
    
    [self.medUsageTV setText:self.mediDetail.medUsage];
    [self.medAdaptationTV setText:self.mediDetail.medAdaptation];
    [self.medIngredientTF setText:self.mediDetail.medIngredient];
    [self.medNoticeTV setText:self.mediDetail.medNotice];
    [self.medSideEffectTV setText:self.mediDetail.medSideEffect];
    
    /*
    // ingredient
    [self loadIngredient:self.mediDetail.medIngredient loadUsage:nil
          loadSideEffect:nil loadNotice:nil
            setTextField:self.medIngredientTF setTextView:nil];
    // usage
    [self loadIngredient:nil loadUsage:self.mediDetail.medUsage
          loadSideEffect:nil loadNotice:nil
            setTextField:nil setTextView:self.medUsageTV];
    // sideeffect
    [self loadIngredient:nil loadUsage:nil
          loadSideEffect:self.mediDetail.medSideEffect loadNotice:nil
            setTextField:nil setTextView:self.medSideEffectTV];
    // notice
    [self loadIngredient:nil loadUsage:nil loadSideEffect:nil loadNotice:self.mediDetail.medNotice setTextField:nil setTextView:self.medNoticeTV];
     */
}

#pragma mark - set each editable or uneditable
-(void)setAllEditableAndTextField:(UITextField *)textfield {
    
    cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    
    // set textfield make it depend isEditing or not
    textfield = self.medMerEngNameTF;
    
    if ([textfield isEditing] == YES) {
        /*
        [self.medImageView setExclusiveTouch:NO];
//        [self.medIDTF setEnabled:NO];
        [self.medMerEngNameTF setEnabled:NO];
        [self.medMerChiNameTF setEnabled:NO];
        [self.medScienceTF setEnabled:NO];
        [self.medCategoryTF setEnabled:NO];
        [self.medIngredientTF setEnabled:NO];
        [self.medUsageTV setEditable:NO];
        [self.medSideEffectTV setEditable:NO];
        [self.medNoticeTV setEditable:NO];
         [self.medAdaptationTV setEditable:NO];
        //TODO:
        self.navigationItem.rightBarButtonItem = editButton;
        self.navigationItem.leftBarButtonItem = popMasterViewButton;
        */
    } else {
    
        [self.medImageView setExclusiveTouch:YES];
        UITapGestureRecognizer *imagepressedGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressedReceiveGesture:)];
        [self.medImageView addGestureRecognizer:imagepressedGesture];
        [self.medImageView setUserInteractionEnabled:YES];
        
//        [self.medIDTF setEnabled:YES];
        [self.medMerEngNameTF setEnabled:YES];
        [self.medMerChiNameTF setEnabled:YES];
        [self.medScienceTF setEnabled:YES];
        [self.medCategoryTF setEnabled:YES];
        [self.medIngredientTF setEnabled:YES];
        [self.medUsageTV setEditable:YES];
        [self.medSideEffectTV setEditable:YES];
        [self.medNoticeTV setEditable:YES];
        [self.medAdaptationTV setEditable:YES];

        [self setNaviItemRBarBtn:cancelButton andLBarBtn:saveButton];
    }
    [self storeBeforeEdit];
}

-(void)setAllUneditable{
    
    [self.medImageView setExclusiveTouch:NO];
    [self.medImageView setUserInteractionEnabled:NO];
    [self.medIDTF setEnabled:NO];
    [self.medMerEngNameTF setEnabled:NO];
    [self.medMerChiNameTF setEnabled:NO];
    [self.medScienceTF setEnabled:NO];
    [self.medCategoryTF setEnabled:NO];
    [self.medIngredientTF setEnabled:NO];
    [self.medUsageTV setEditable:NO];
    [self.medSideEffectTV setEditable:NO];
    [self.medNoticeTV setEditable:NO];
    [self.medAdaptationTV setEditable:NO];

}

-(void)setNaviItemRBarBtn:(UIBarButtonItem *)rightButton andLBarBtn:(UIBarButtonItem *)leftButton  {
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
}


// Store Tmp data before edit
-(void)storeBeforeEdit {
    /* 
    //TODO:error because save Image into Dictionary
    if (self.medImageView.image == nil) {
        UIImage *image = [UIImage imageNamed:@"add-photo-placeholder.png"];
        [tmpStorage setObject:image forKey:@"medImageFile"];
    } else {
        [tmpStorage setObject:self.medImageView.image forKey:@"medImageDict"];
    }
     */

    [tmpStorage setValue:self.medIDTF.text forKey:@"medIDDict"];
    [tmpStorage setValue:self.medMerEngNameTF.text forKey:@"medMerEngNameDict"];
    [tmpStorage setValue:self.medMerChiNameTF.text forKey:@"medMerChiNameDict"];
    [tmpStorage setValue:self.medScienceTF.text forKey:@"medScienceNameDict"];
    [tmpStorage setValue:self.medCategoryTF.text forKey:@"medCategoryDict"];
    [tmpStorage setValue:self.medIngredientTF.text forKey:@"medIngredient"];
    [tmpStorage setValue:self.medUsageTV.text forKey:@"medUsageDict"];
    [tmpStorage setValue:self.medSideEffectTV.text forKey:@"medSideEffectDict"];
    [tmpStorage setValue:self.medNoticeTV.text forKey:@"medNoticeDict"];
    [tmpStorage setValue:self.medAdaptationTV.text forKey:@"medAdaptation"];
    
}
// set Data to original and make it uneditable (save prior data into a dictionary)
-(void)cancelButtonClicked {
    
//    [self.medImageView setValue:tmpStorage forKey:@"medImageFile"];
    [self.medIDTF setText:[tmpStorage objectForKey:@"medIDDict"]];
    [self.medMerEngNameTF setText:[tmpStorage objectForKey:@"medMerEngNameDict"]];
    [self.medMerChiNameTF setText:[tmpStorage objectForKey:@"medMerChiNameDict"]];
    [self.medScienceTF setText:[tmpStorage objectForKey:@"medScienceNameDict"]];
    [self.medCategoryTF setText:[tmpStorage objectForKey:@"medCategoryDict"]];
    [self.medIngredientTF setText:[tmpStorage objectForKey:@"medIngredient"]];
    [self.medUsageTV setText:[tmpStorage objectForKey:@"medUsageDict"]];
    [self.medSideEffectTV setText:[tmpStorage objectForKey:@"medSideEffectDict"]];
    [self.medNoticeTV setText:[tmpStorage objectForKey:@"medNoticeDict"]];
    [self.medAdaptationTV setText:[tmpStorage objectForKey:@"medAdaptation"]];
    
    [self setAllUneditable];

    [self fromMedicineTableView];
}
    
-(void)updateData {
    
    [self setAllUneditable];
    [self resignFirstResponder];
    
    
    PFQuery *medQuery = [PFQuery queryWithClassName:medicineClassName];
    
    // Retrieve the object by id
    [medQuery getObjectInBackgroundWithId:self.receiveObjectId block:^(PFObject *medObject, NSError *error) {
        NSLog(@"RECEIVED PFOBJECTID:%@", self.receiveObjectId);
        if (!error) {
            
            // Now let's update it with some data
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [medObject setObject:[formatter numberFromString:self.medIDTF.text] forKeyedSubscript:@"medID"];
            
            //TODO: Upload image fail
            // Medicine image
            NSData *imageData = UIImageJPEGRepresentation(self.medImageView.image, 0.8f);
            NSMutableString *tmpString = [[NSMutableString alloc] init];
            tmpString = [self filenameEncoderFromString:(NSMutableString *)self.medMerEngNameTF.text];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.png", tmpString];
            
            PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
            
            [medObject setObject:imageFile forKeyedSubscript:@"medImageFile"];
            
            // other Medicine columns
            tmpString = [self filenameEncoderFromString:(NSMutableString *)self.medMerEngNameTF.text
                         ];
            [medObject setObject:tmpString forKeyedSubscript:@"medMerEngName"];
            [medObject setObject:self.medMerChiNameTF.text forKeyedSubscript:@"medMerChiName"];
            [medObject setObject:self.medScienceTF.text forKeyedSubscript:@"medScienceName"];
            [medObject setObject:self.medCategoryTF.text forKeyedSubscript:@"medCategory"];
            
            [medObject setObject:self.medIngredientTF.text forKey:@"medIngredient"];
            [medObject setObject:self.medUsageTV.text forKey:@"medUsage"];
            [medObject setObject:self.medSideEffectTV.text forKey:@"medSideEffect"];
            [medObject setObject:self.medNoticeTV.text forKey:@"medNotice"];
            [medObject setObject:self.medAdaptationTV.text forKeyedSubscript:@"medAdaptation"];
            /*
            NSArray *ingredients = [self.medIngredientTF.text componentsSeparatedByString:@","];
            [medObject setObject:ingredients forKeyedSubscript:@"medIngredient"];
            
            NSArray *usage = [self.medUsageTV.text componentsSeparatedByString:@","];
            [medObject setObject:usage forKeyedSubscript:@"medUsage"];
            
            NSArray *sideEffect = [self.medSideEffectTV.text componentsSeparatedByString:@","];
            [medObject setObject:sideEffect forKeyedSubscript:@"medSideEffect"];
            
            NSArray *notice = [self.medNoticeTV.text componentsSeparatedByString:@","];
            [medObject setObject:notice forKeyedSubscript:@"medNotice"];
            */
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // show progress when saving
                UploadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                UploadingHud.mode = MBProgressHUDAnimationFade;
                UploadingHud.labelText = @"Uploading...";
                [UploadingHud show:true];
            });
            
            // update medicine to parse
            [medObject saveInBackgroundWithBlock:^(BOOL successed, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [UploadingHud hide:YES ];
                    
                    if (successed == YES) {
                        
                        
                        // show success message and hide the saving progress
                        MBProgressHUD *hudd = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hudd.mode = MBProgressHUDModeCustomView;
                        hudd.labelText = @"Upload Successfully";
                        hudd.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
                        [hudd show:true];
                        [hudd hide:true afterDelay:1.0f];
                        
                        // Notify table view to reload the medicines from parse cloud
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshParse" object:self];
                        
                    } else {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                });
                
            }]; // saveinbackground end }];
            // get objectinbackground if-else
        } else {
            NSLog(@"getObjectError:%@", error);
        }
    }];
    
    [self fromMedicineTableView];
}

#pragma mark - receive data(NSArray) and show on each textField
-(void)loadIngredient:(NSArray *)ingredientArray loadUsage:(NSArray *)usageArray
       loadSideEffect:(NSArray *)sideEffectArray loadNotice:(NSArray *)noticeArray setTextField:(UITextField *)textfield setTextView:(UITextView *)textView {
    
    if (ingredientArray != nil) {
        //
        NSMutableString *ingredientString = [NSMutableString string];
        for (NSString* ingredient in ingredientArray) {
            [ingredientString appendFormat:@"%@,", ingredient];
        }
        textfield.text = ingredientString;
        
    } else if (usageArray != nil) {
        NSMutableString *usageString = [NSMutableString string];
        for (NSString *usage in usageArray) {
            [usageString appendFormat:@"%@,", usage];
        }
        textView.text = usageString;
    } else if (sideEffectArray != nil) {
        NSMutableString *sideEffectString = [NSMutableString string];
        for (NSString *sideEffect in sideEffectArray) {
            [sideEffectString appendFormat:@"%@,", sideEffect];
        }
        textView.text = sideEffectString;
    } else if (noticeArray != nil) {
        NSMutableString *noticeString = [NSMutableString string];
        for (NSString *notice in noticeArray) {
            [noticeString appendFormat:@"%@,", notice];
        }
        textView.text = noticeString;
    }
}

-(void)updateToLocal {
    /*
    [[MediDataBase shareInstance] insertMediID:self.medIDTF.text
                                  andMediImage:self.medImage.image
                                 andMediMerEng:self.medMerEngNameTF.text
                                 andMediMerChi:self.medMerChiNameTF.text
                                andMediScience:self.medScienceTF.text
                               andMediCategory:self.medCategoryTF.text
                              andMedIngredient:self.medIngredientTF.text
                                   andMedUsage:self.medUsageTV.text
                              andMedSideEffect:self.medSideEffectTV.text
                                  andMedNotice:self.medNoticeTV.text];
     */
}



#pragma mark - choose camera or photo roll
// upload Image
/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Select" message:@"Camera or Photo Roll" delegate:self cancelButtonTitle:@
 "Cancel"otherButtonTitles:@"Camara", @"Photo Roll", nil];
 
 if (indexPath.row == 0) {
 [alertView show];
}
 */

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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Select" message:@"Camera or Photo Roll" delegate:self cancelButtonTitle:@
                                  "Cancel"otherButtonTitles:@"Camara", @"Photo Roll", nil];
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
    
    // check Camera unavailable
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        
        [self showPhotoLibrary];
    }
    // check Camera avalible
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear] == YES) {
        
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        ipc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        ipc.mediaTypes = [NSArray arrayWithObject:@"public.image"];
        //        ipc.allowsEditing = NO;
        //        if (ipc.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //
        //            CameraView *cv = [[CameraView alloc] init];
        //            [ipc.cameraOverlayView addSubview:cv.myOverlayView];
        //        }
        ipc.showsCameraControls = YES;
        ipc.delegate = self;
        
        //        currentImagePicker = ipc;
        
        [self presentViewController:ipc animated:YES completion:^{
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:@"fromPhotoRoll" object:nil];
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    //UIImageWriteToSavedPhotosAlbum(image, id completionTarget, SEL completionSelector, void *contextInfo);
    // show photo on imageview
    self.medImageView.image = originalImage;
    //TODO: save photo when finished taking pictur
    // save photo
    //UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
        
    }];
}

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - Split view action
//iOS7 and before

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController withBarButtonItem:
(UIBarButtonItem *)barButtonItem forPopoverController:
(UIPopoverController *)popoverController
{
    
    barButtonItem.title = NSLocalizedString(@"Medicine", @"藥品資料庫");
    popMasterViewButton = barButtonItem;
    [self.navigationItem setLeftBarButtonItem:popMasterViewButton animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view,
    //invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
 

//iOS8
-(void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        
        if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
            
            self.navigationItem.leftBarButtonItem = nil;
        } else {
            //
        }
        
    } else {
        
        if (displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
            
            self.navigationItem.leftBarButtonItem = popMasterViewButton;
        } else {
            
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    
    
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


#pragma mark - TextField Delegate
/**
-(BOOL)textFieldShouldReturn:(UITextField *)textField andTextViewShouldReturn:(UITextView *)textView {
    
    [textField resignFirstResponder];
    [textView resignFirstResponder];
    return YES;
}
 */

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = _medScienceTF.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - remove unnecessary character with imageFile name
-(NSMutableString *)filenameEncoderFromString:(NSMutableString *)string {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    mutableString = string;
    
    mutableString =
    (NSMutableString *)[string stringByReplacingOccurrencesOfString:@"%" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"!" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"@" withString:@"" options:1 range:NSMakeRange(0, string.length)];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"$" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"^" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"&" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"*" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@")" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"=" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"|" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"]" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"[" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"{" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"}" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@";" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@":" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"?" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"/" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@">" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"," withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"~" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"`" withString:@""];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    mutableString =(NSMutableString *)[mutableString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    return mutableString;
}

@end
