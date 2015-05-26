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

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface MedicineDetailTableViewController () {
    UIBarButtonItem *editButton;
    UIBarButtonItem *saveButton;
    NSMutableDictionary *tmpStorage;
}

@property (weak, nonatomic) IBOutlet PFImageView *medImage;
@property (weak, nonatomic) IBOutlet UITextField *medIDTF;
@property (weak, nonatomic) IBOutlet UITextField *medScienceTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerEngNameTF;
@property (weak, nonatomic) IBOutlet UITextField *medMerChiNameTF;
@property (weak, nonatomic) IBOutlet UITextField *medCategoryTF;
@property (weak, nonatomic) IBOutlet UITextField *medIngredientTF;

@property (weak, nonatomic) IBOutlet UITextView *medUsageTV;
@property (weak, nonatomic) IBOutlet UITextView *medSideEffectTV;
@property (weak, nonatomic) IBOutlet UITextView *medNoticeTV;

@end

@implementation MedicineDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(setEditable:)];
    saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData)];
    
    self.navigationItem.leftBarButtonItem = editButton;
    
    tmpStorage = [[NSMutableDictionary alloc] init];
    
    // uneditable
    [self.medImage setExclusiveTouch:NO];
    [self.medIDTF setEnabled:NO];
    [self.medMerEngNameTF setEnabled:NO];
    [self.medMerChiNameTF setEnabled:NO];
    [self.medScienceTF setEnabled:NO];
    [self.medCategoryTF setEnabled:NO];
    [self.medIngredientTF setEnabled:NO];
    [self.medUsageTV setEditable:NO];
    [self.medSideEffectTV setEditable:NO];
    [self.medNoticeTV setEditable:NO];
    
    // segue by code
    
    self.title = self.mediDetail.medMerEngName;
    //
    [self.medIDTF setText:self.mediDetail.medID];
    self.medScienceTF.text = self.mediDetail.medScienceName;
    [self.medMerEngNameTF setText:self.mediDetail.medMerEngName];
    self.medMerChiNameTF.text = self.mediDetail.medMerChiName;
    [self.medCategoryTF setText:self.mediDetail.medCategory];
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
    
//    NSMutableString *noticeString = [NSMutableString string];
//    for (NSString *notice in self.mediDetail.medNotice) {
//        [noticeString appendFormat:@"%@,", notice];
//    }
//    self.medNoticeTV.text = noticeString;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"MedicineDetailTableView dismiss");
}

#pragma mark - barbuttonitem
-(void)setEditable:(UITextField *)textfield {
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked)];
    
    // set textfield make it depend isEditing
    textfield = self.medMerEngNameTF;
    
    if ([textfield isEditing] == YES) {
        
        [self.medImage setExclusiveTouch:NO];
//        [self.medIDTF setEnabled:NO];
        [self.medMerEngNameTF setEnabled:NO];
        [self.medMerChiNameTF setEnabled:NO];
        [self.medScienceTF setEnabled:NO];
        [self.medCategoryTF setEnabled:NO];
        [self.medIngredientTF setEnabled:NO];
        [self.medUsageTV setEditable:NO];
        [self.medSideEffectTV setEditable:NO];
        [self.medNoticeTV setEditable:NO];
        self.navigationItem.leftBarButtonItem = editButton;
        
    } else {
    
        [self.medImage setExclusiveTouch:YES];
//        [self.medIDTF setEnabled:YES];
        [self.medMerEngNameTF setEnabled:YES];
        [self.medMerChiNameTF setEnabled:YES];
        [self.medScienceTF setEnabled:YES];
        [self.medCategoryTF setEnabled:YES];
        [self.medIngredientTF setEnabled:YES];
        [self.medUsageTV setEditable:YES];
        [self.medSideEffectTV setEditable:YES];
        [self.medNoticeTV setEditable:YES];
        self.navigationItem.rightBarButtonItem = saveButton;
        self.navigationItem.leftBarButtonItem = cancelButton;

    }
    [self storeBeforeEdit];
}

-(void)setUneditable {
    [self.medImage setExclusiveTouch:NO];
//    [self.medIDTF setEnabled:NO];
    [self.medMerEngNameTF setEnabled:NO];
    [self.medMerChiNameTF setEnabled:NO];
    [self.medScienceTF setEnabled:NO];
    [self.medCategoryTF setEnabled:NO];
    [self.medIngredientTF setEnabled:NO];
    [self.medUsageTV setEditable:NO];
    [self.medSideEffectTV setEditable:NO];
    [self.medNoticeTV setEditable:NO];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = editButton;
}
// Store Tmp data before edit
-(void)storeBeforeEdit {
    
    [tmpStorage setObject:self.medImage.image forKey:@"medImageDict"];
    [tmpStorage setValue:self.medIDTF.text forKey:@"medIDDict"];
    [tmpStorage setValue:self.medMerEngNameTF.text forKey:@"medMerEngNameDict"];
    [tmpStorage setValue:self.medMerChiNameTF.text forKey:@"medMerChiNameDict"];
    [tmpStorage setValue:self.medScienceTF.text forKey:@"medScienceNameDict"];
    [tmpStorage setValue:self.medCategoryTF.text forKey:@"medCategoryDict"];
    [tmpStorage setValue:self.medIngredientTF.text forKey:@"medIngredient"];
    [tmpStorage setValue:self.medUsageTV.text forKey:@"medUsageDict"];
    [tmpStorage setValue:self.medSideEffectTV.text forKey:@"medSideEffectDict"];
    [tmpStorage setValue:self.medNoticeTV.text forKey:@"medNoticeDict"];
    
}
// set Data to original and make it uneditable
-(void)cancelButtonClicked {
    
//    [self.medImage];
    [self.medIDTF setText:[tmpStorage objectForKey:@"medIDDict"]];
    [self.medMerEngNameTF setText:[tmpStorage objectForKey:@"medMerEngNameDict"]];
    [self.medMerChiNameTF setText:[tmpStorage objectForKey:@"medMerChiNameDict"]];
    [self.medScienceTF setText:[tmpStorage objectForKey:@"medScienceNameDict"]];
    [self.medCategoryTF setText:[tmpStorage objectForKey:@"medCategoryDict"]];
    [self.medIngredientTF setText:[tmpStorage objectForKey:@"medIngredient"]];
    [self.medUsageTV setText:[tmpStorage objectForKey:@"medUsageDict"]];
    [self.medSideEffectTV setText:[tmpStorage objectForKey:@"medSideEffectDict"]];
    [self.medNoticeTV setText:[tmpStorage objectForKey:@"medNoticeDict"]];
    
    [self.medImage setExclusiveTouch:NO];
    [self.medIDTF setEnabled:NO];
    [self.medMerEngNameTF setEnabled:NO];
    [self.medMerChiNameTF setEnabled:NO];
    [self.medScienceTF setEnabled:NO];
    [self.medCategoryTF setEnabled:NO];
    [self.medIngredientTF setEnabled:NO];
    [self.medUsageTV setEditable:NO];
    [self.medSideEffectTV setEditable:NO];
    [self.medNoticeTV setEditable:NO];
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = nil;
}


-(void)saveData {
//    
//    //傳回主執行緒，與ＵＩ戶動
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        saveButton.enabled = NO;
//        });

    PFQuery *medQuery = [PFQuery queryWithClassName:medicineClassName];

    // Retrieve the object by id
    [medQuery getObjectInBackgroundWithId:self.receiveObjectId block:^(PFObject *medObject, NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"RECEIVED PFOBJECTID:%@", self.receiveObjectId);
//        if (error == nil) {
        
            // Now let's update it with some data
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [medObject setObject:[formatter numberFromString:self.medIDTF.text] forKeyedSubscript:@"medID"];
            
            //TODO: Upload image fail
            // Medicine image
            NSData *imageData = UIImageJPEGRepresentation(self.medImage.image, 0.8f);
            NSMutableString *tmpString = [[NSMutableString alloc] init];
            tmpString = [self filenameEncoderFromString:(NSMutableString *)self.medMerEngNameTF.text];
            
            NSString *fileName = [NSString stringWithFormat:@"%@.png", tmpString];
            
            PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
            /*
            if (imageFile == nil) {
                
                [medObject setObject:[UIImage imageNamed:@"Ironman head.png"] forKey:@"medImage"];
            } else {
                
                [medObject setObject:imageFile forKeyedSubscript:@"medImage"];
            }*/
            [medObject setObject:imageFile forKey:@"medImage"];
            
            // other Medicine columns
            tmpString = [self filenameEncoderFromString:(NSMutableString *)self.medMerEngNameTF.text
                         ];
            [medObject setObject:tmpString forKeyedSubscript:@"medMerEngName"];
            [medObject setObject:self.medMerChiNameTF.text forKeyedSubscript:@"medMerChiName"];
            [medObject setObject:self.medScienceTF.text forKeyedSubscript:@"medScienceName"];
            [medObject setObject:self.medCategoryTF.text forKeyedSubscript:@"medCategory"];
            
            NSArray *ingredients = [self.medIngredientTF.text componentsSeparatedByString:@","];
            [medObject setObject:ingredients forKeyedSubscript:@"medIngredient"];
            
            NSArray *usage = [self.medUsageTV.text componentsSeparatedByString:@","];
            [medObject setObject:usage forKeyedSubscript:@"medUsage"];
            
            NSArray *sideEffect = [self.medSideEffectTV.text componentsSeparatedByString:@","];
            [medObject setObject:sideEffect forKeyedSubscript:@"medSideEffect"];
            
            NSArray *notice = [self.medNoticeTV.text componentsSeparatedByString:@","];
            [medObject setObject:notice forKeyedSubscript:@"medNotice"];
            
            // show progress when saving
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
        
            // update medicine to parse
            [medObject saveInBackgroundWithBlock:^(BOOL successed, NSError *error) {
                
                if (successed == YES) {
                
//                    if (!error) {
                        // show success message and hide the saving progress
                        MBProgressHUD *hudd = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hudd.mode = MBProgressHUDModeCustomView;
                        hudd.labelText = @"Upload Successfully";
                        hudd.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
                        [hudd showAnimated:YES whileExecutingBlock:^{
                            //
                            [self setUneditable];
                            [hud hide:YES];
                        } completionBlock:^{
                            //                MedicineTableViewController *mtvd = [[MedicineTableViewController alloc] init];
                            //                [mtvd download];
                            // Notify table view to reload the medicines from parse cloud
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshParse" object:self];
                            
                        }];
                    } else {
//                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
//                                                      });

                    }
                    NSLog(@"updateError:%@", error);
            }]; // saveinbackground end }];
        // get objectinbackground if-else
//        } else {
            NSLog(@"getObjectError:%@", error);
//        }
    }];
}

-(NSMutableString *)filenameEncoderFromString:(NSMutableString *)string {
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
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

#pragma mark - display on table view
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

-(void)saveToLocal {
    
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField andTextViewShouldReturn:(UITextView *)textView {
    
    [textField resignFirstResponder];
    [textView resignFirstResponder];
    return YES;
}

@end
