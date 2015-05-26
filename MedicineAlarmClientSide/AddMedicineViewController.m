//
//  AddMedicineViewController.m
//  MedicineParse
//
//  Created by Stan Liu on 5/17/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "AddMedicineViewController.h"
#import "MedicineTableViewController.h"
#import <ParseUI/ParseUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
#import "MediDataBase.h"

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface AddMedicineViewController () {
    
    UITextField *medIDTextField;
    PFImageView *medImage;
    
    UITextField *medMerEngNameTextField;
    UITextField *medMerChiNameTextField;
    UITextField *medScienceNameTextField;
    UITextField *medCategoryTextField;
    
    UITextField *medIngredientTextField;
    
    IBOutlet UITextField *medUsageTextField;
    UITextField *medSideEffectTextField;
    UITextField *medNoticeTextField;
    
    UITableViewCell *cell;
}

@property (weak, nonatomic) IBOutlet UITextField *medIDUITextField;
@property (weak, nonatomic) IBOutlet PFImageView *medPhoto;

@property (weak, nonatomic) IBOutlet UITextField *medMerEngNameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medMerChiNameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medScienceNameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medCategoryUITextField;

@property (weak, nonatomic) IBOutlet UITextField *medIngredientUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medUsageUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medSideEffectUITextField;
@property (weak, nonatomic) IBOutlet UITextField *medNoticeTextUITextField;

@end

@implementation AddMedicineViewController

-(void)dealloc {
    NSLog(@"addMedicine dealloced");
}

//-(void)loadView {
////    [self.navigationController setNavigationBarHidden:NO];
////    [self.navigationController setTitle:@"ADDoo"];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    medIDTextField.text = @"";

    medImage.image = nil;
    
    medMerEngNameTextField.text = @"";
    medMerChiNameTextField.text = @"";
    medScienceNameTextField.text = @"";
    medCategoryTextField.text = @"";
    
    medIngredientTextField.text = @"";
    
    medUsageTextField.text = @"";
    medSideEffectTextField.text = @"";
    medNoticeTextField.text = @"";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.navigationController setTitle:@"ADD"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - upload
// upload Image
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self showPhotoLibrary];
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
    
    // unknown error
    //    mediaUI.delegate = self;
    
    [self.navigationController presentViewController:mediaUI animated:YES completion:nil];
}

-(void)saveData {
    // Create PFObject with recipe information.
    PFObject *medObject = [PFObject objectWithClassName:@"medicineClassName"];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [medObject setObject:[formatter numberFromString:medIDTextField.text] forKeyedSubscript:@"medID"];
    //TODO: Upload image fail

    // image
    NSData *imageData = UIImageJPEGRepresentation(medImage.image, 0.8f);
    NSString *fileName = [NSString stringWithFormat:@"%@.png", medMerEngNameTextField.text];
    PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
    if (imageFile == nil) {
        
        [medObject setObject:[UIImage imageNamed:@"Ironman head.png"] forKey:@"medImage"];
    } else {

        [medObject setObject:imageFile forKeyedSubscript:@"medImage"];
    }
    
    // other columns
        [medObject setObject:medMerEngNameTextField.text forKeyedSubscript:@"medMerEngName"];
        [medObject setObject:medMerChiNameTextField.text forKeyedSubscript:@"medMerChiName"];
        NSLog(@"%@", medMerEngNameTextField.text);
        [medObject setObject:medScienceNameTextField.text forKeyedSubscript:@"medScienceName"];
        [medObject setObject:medCategoryTextField.text forKeyedSubscript:@"medCategory"];
        
        NSArray *ingredients = [medIngredientTextField.text componentsSeparatedByString:@","];
        [medObject setObject:ingredients forKeyedSubscript:@"medIngredient"];
        
        NSArray *usage = [medNoticeTextField.text componentsSeparatedByString:@","];
        [medObject setObject:usage forKeyedSubscript:@"medUsage"];
        
        NSArray *sideEffect = [medSideEffectTextField.text componentsSeparatedByString:@","];
        [medObject setObject:sideEffect forKeyedSubscript:@"medSideEffect"];
        
        NSArray *notice = [medNoticeTextField.text componentsSeparatedByString:@","];
        [medObject setObject:notice forKeyedSubscript:@"medNotice"];

    // show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Uploading...";
    [hud showAnimated:YES whileExecutingBlock:^{
        float progress = 0.0f;
        while (progress < 1.0f) {
            
            progress += 0.01f;
            hud.progress = progress;
            usleep(10000);
        }
    }];

    // upload medicine to parse
    [medObject saveInBackgroundWithBlock:^(BOOL successed, NSError *error) {
        
        
        if (!error) {
            // show sucess message
            MBProgressHUD *hudd = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hudd.mode = MBProgressHUDModeCustomView;
            hudd.labelText = @"Upload Successfully";
            hudd.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
            [hudd showAnimated:YES whileExecutingBlock:^{
                //
                [hud hide:NO];
            } completionBlock:^{
                MedicineTableViewController *mtvd = [[MedicineTableViewController alloc] init];
                [mtvd download];
            }];
            // Notify table view to reload the medicines from parse cloud
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }];
}
/* //local
-(void)saveData {
    // Create PFObject with recipe information.
    PFObject *medObject = [PFObject objectWithClassName:@"medicineClassName"];
    
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [medObject setObject:[formatter numberFromString:medIDTextField.text] forKeyedSubscript:@"medID"];
    //TODO: Upload image fail
    // *************************
     // image
     NSData *imageData = UIImageJPEGRepresentation(medImage.image, 0.8f);
     NSString *fileName = [NSString stringWithFormat:@"%@.png", medMerEngNameTextField.text];
     PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
     if (imageFile == nil) {
     
     [medic setObject:[UIImage imageNamed:@"Ironman head.png"] forKey:@"medImage"];
     } else {
     
     [medic setObject:imageFile forKeyedSubscript:@"medImage"];
     }
    // ************************
    
    [medObject incrementKey:@"medID"];
    
    // other columns
    [medObject setObject:medMerEngNameTextField.text forKeyedSubscript:@"medMerEngName"];
    [medObject setObject:medMerChiNameTextField.text forKeyedSubscript:@"medMerChiName"];
    [medObject setObject:medScienceNameTextField.text forKeyedSubscript:@"medScienceName"];
    [medObject setObject:medCategoryTextField.text forKeyedSubscript:@"medCategory"];
    
    NSArray *ingredients = [medIngredientTextField.text componentsSeparatedByString:@","];
    [medObject setObject:ingredients forKeyedSubscript:@"medIngredient"];
    
    NSArray *usage = [medNoticeTextField.text componentsSeparatedByString:@","];
    [medObject setObject:usage forKeyedSubscript:@"medUsage"];
    
    NSArray *sideEffect = [medSideEffectTextField.text componentsSeparatedByString:@","];
    [medObject setObject:sideEffect forKeyedSubscript:@"medSideEffect"];
    
    NSArray *notice = [medNoticeTextField.text componentsSeparatedByString:@","];
    [medObject setObject:notice forKeyedSubscript:@"medNotice"];
    
    // show progress
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDAnimationFade;
    hud.labelText = @"Uploading...";
    [hud showAnimated:YES whileExecutingBlock:^{
        float progress = 0.0f;
        while (progress < 1.0f) {
            
            progress += 0.01f;
            hud.progress = progress;
            usleep(10000);
        }
    }];
    
    [medObject saveInBackgroundWithBlock:^(BOOL successed, NSError *error){
        if (successed == YES) {
            MBProgressHUD *hudsuccess = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hudsuccess.mode = MBProgressHUDModeCustomView;
            hudsuccess.labelText = @"Successfully";
            [hudsuccess hide:YES afterDelay:0.7f];
            
        } else {
            NSLog(@"\nsaveInBackground error:%@\n", error);
        }
    }];
//    NSLog(@"medobject:%@ \n\n", medObject);
//    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
//    [medObject pinInBackgroundWithBlock:^(BOOL successed, NSError *error){
//        if (successed == YES) {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = @"Save Successfully";
//            [hud hide:YES afterDelay:0.5f];
//        } else NSLog(@"save error: %@", error);
//    }];
//    [query fromLocalDatastore];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
//        
//        NSLog(@"query:%@ \n\n", array);
//        NSLog(@"findObjectError: %@ \n\n", error);
//    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:nil];
}
*/

-(void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC1"];
            medImage = (PFImageView *)[cell viewWithTag:500];
            //
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC2"];
            medIDTextField = (UITextField *)[cell viewWithTag:501];
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC3"];
            medScienceNameTextField = (UITextField *)[cell viewWithTag:502];
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC4"];
            medMerEngNameTextField = (UITextField *)[cell viewWithTag:503];
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC5"];
            medMerChiNameTextField = (UITextField *)[cell viewWithTag:504];
            break;
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC6"];
            medCategoryTextField = (UITextField *)[cell viewWithTag:505];
            break;
        case 6:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC7"];
            medIngredientTextField = (UITextField *)[cell viewWithTag:506];
            break;
        case 7:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC8"];
            medUsageTextField = (UITextField *)[cell viewWithTag:507];
            break;
        case 8:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC9"];
            medSideEffectTextField = (UITextField *)[cell viewWithTag:508];
            break;
        case 9:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC10"];
            medNoticeTextField = (UITextField *)[cell viewWithTag:509];
            
            break;
            
        default:
            break;
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight;
    
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC1"];
            cellHeight = 170.0f;
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC2"];
            cellHeight = 44.0f;
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC3"];
            cellHeight = 44.0f;
            break;
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC4"];
            cellHeight = 44.0f;
            break;
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC5"];
            cellHeight = 44.0f;
            break;
        case 5:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC6"];
            cellHeight = 44.0f;
            break;
        case 6:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC7"];
            cellHeight = 44.0f;
            break;
        case 7:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC8"];
            cellHeight = 10.0f;
            break;
        case 8:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC9"];
            cellHeight = 80.0f;
            break;
        case 9:
            cell = [tableView dequeueReusableCellWithIdentifier:@"DC10"];
            cellHeight = 80.0f;
            break;
            
        default:
            break;
    }
    
    return cellHeight;
}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField andTextViewShouldReturn:(UITextView *)textView {
    
    [textField resignFirstResponder];
    [textView resignFirstResponder];
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
