//
//  MedicineDetailViewController.m
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MedicineDetailViewController.h"
#import "MedicineTableViewController.h"
// mediaUI.mediaTypes = @[(NSString *)kUTTypeImage];
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "MediDataBase.h"

@interface MedicineDetailViewController () {
    
    PFImageView *medImage;
    UITextField *medIDTextField;
    UITextField *medMerEngNameTextField;
    UITextField *medMerChiNameTextField;
    UITextField *medScienceNameTextField;
    UITextField *medCategoryTextField;
    UITextField *medIngredientTextField;
    UITextField *medUsageTextField;
    UITextField *medSideEffectTextField;
    UITextField *medNoticeTextTextField;
    
    UITableViewCell *cell;

}

@end

@implementation MedicineDetailViewController

-(void)dealloc {
    NSLog(@"MedicineDetail dealloced");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cell = [UITableViewCell new];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveToLocal)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // uneditable
//    self.medIDTextField.editing = NO;
    
    // segue by code
    
    self.title = self.mediDetail.medMerEngName;
    
    medImage = (PFImageView *)[cell viewWithTag:200];
    
    //
    medIDTextField = (UITextField *)[cell viewWithTag:201];
    [medIDTextField setText:self.mediDetail.medID];
    
    medScienceNameTextField = (UITextField *)[cell viewWithTag:202];
    medScienceNameTextField.text = self.mediDetail.medScienceName;
    
    medMerEngNameTextField = (UITextField *)[cell viewWithTag:203];
    [medMerEngNameTextField setText:self.mediDetail.medMerEngName];
    
    medMerChiNameTextField = (UITextField *)[cell viewWithTag:204];
    medMerChiNameTextField.text = self.mediDetail.medMerChiName;
    
    medCategoryTextField = (UITextField *)[cell viewWithTag:205];
    [medCategoryTextField setText:self.mediDetail.medCategory];
    
    medIngredientTextField = (UITextField *)[cell viewWithTag:206];
    [self loadIngredient:self.mediDetail.medIngredient loadUsage:nil loadSideEffect:nil loadNotice:nil setTextField:medIngredientTextField];
    
    medUsageTextField = (UITextField *)[cell viewWithTag:207];
    [self loadIngredient:nil loadUsage:self.mediDetail.medUsage loadSideEffect:nil loadNotice:nil setTextField:medUsageTextField];
    
    medSideEffectTextField = (UITextField *)[cell viewWithTag:208];
    [self loadIngredient:nil loadUsage:nil loadSideEffect:self.mediDetail.medSideEffect loadNotice:nil setTextField:medSideEffectTextField];
    
    medNoticeTextTextField = (UITextField *)[cell viewWithTag:209];
//    [self loadIngredient:nil loadUsage:nil loadSideEffect:nil loadNotice:self.mediDetail.medNotice setTextField:medNoticeTextTextField];
    NSMutableString *noticeString = [NSMutableString string];
    for (NSString *notice in self.mediDetail.medNotice) {
        [noticeString appendFormat:@"%@,", notice];
    }
    medNoticeTextTextField.text = noticeString;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)saveToLocal {
    
    [[MediDataBase shareInstance] insertMediID:medIDTextField.text andMediImage:medImage.file andMediMerEng:medMerEngNameTextField.text andMediMerChi:medMerChiNameTextField.text andMediScience:medScienceNameTextField.text andMediCategory:medCategoryTextField.text andMedIngredient:medIngredientTextField.text andMedUsage:medUsageTextField.text andMedSideEffect:medSideEffectTextField.text andMedNotice:medNoticeTextTextField.text];
}

#pragma mark - display on table view

-(void)loadIngredient:(NSArray *)ingredientArray loadUsage:(NSArray *)usageArray
       loadSideEffect:(NSArray *)sideEffectArray loadNotice:(NSArray *)noticeArray setTextField:(UITextField *)textfield{
    
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
        textfield.text = usageString;
    } else if (sideEffectArray != nil) {
        NSMutableString *sideEffectString = [NSMutableString string];
                for (NSString *sideEffect in sideEffectArray) {
                    [sideEffectString appendFormat:@"%@,", sideEffect];
                }
        textfield.text = sideEffectString;
    } else if (noticeArray != nil) {
        NSMutableString *noticeString = [NSMutableString string];
                for (NSString *notice in noticeArray) {
                    [noticeString appendFormat:@"%@,", notice];
                }
        textfield.text = noticeString;
    }
}
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    
//    return 10;
//}
//
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    switch (indexPath.row) {
//        case 0:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC1"];
//            medImage = (PFImageView *)[cell viewWithTag:200];
//            //
//            break;
//        case 1:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC2"];
//            medIDTextField = (UITextField *)[cell viewWithTag:201];
//            [medIDTextField setText:self.mediDetail.medID];
////            [medIDTextField setText:[object objectForKey:@"medID"]];
//            break;
//        case 2:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC3"];
//            medScienceNameTextField = (UITextField *)[cell viewWithTag:202];
//            medScienceNameTextField.text = self.mediDetail.medScienceName;
////            [medScienceNameTextField setText:[object objectForKey:@"medScienceName"]];
//            break;
//        case 3:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC4"];
//            medMerEngNameTextField = (UITextField *)[cell viewWithTag:203];
//            [medMerEngNameTextField setText:self.mediDetail.medMerEngName];
////            [medMerEngNameTextField setText:[object objectForKey:@"medMerEngName"]];
//            break;
//        case 4:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC5"];
//             medMerChiNameTextField = (UITextField *)[cell viewWithTag:204];
//             medMerChiNameTextField.text = self.mediDetail.medMerChiName;
////            [medMerChiNameTextField setText:[object objectForKey:@"medMerChiName"]];
//            break;
//        case 5:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC6"];
//            medCategoryTextField = (UITextField *)[cell viewWithTag:205];
//            [medCategoryTextField setText:self.mediDetail.medCategory];
//            break;
//        case 6:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC7"];
//            medIngredientTextField = (UITextField *)[cell viewWithTag:206];
//            [self loadIngredient:self.mediDetail.medIngredient loadUsage:nil loadSideEffect:nil loadNotice:nil setTextField:medIngredientTextField];
//            break;
//        case 7:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC8"];
//            medUsageTextField = (UITextField *)[cell viewWithTag:207];
//            [self loadIngredient:nil loadUsage:self.mediDetail.medUsage loadSideEffect:nil loadNotice:nil setTextField:medUsageTextField];
//            break;
//        case 8:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC9"];
//            medSideEffectTextField = (UITextField *)[cell viewWithTag:208];
//            [self loadIngredient:nil loadUsage:nil loadSideEffect:self.mediDetail.medSideEffect loadNotice:nil setTextField:medSideEffectTextField];
//            break;
//        case 9:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC10"];
//            medNoticeTextTextField = (UITextField *)[cell viewWithTag:209];
//            [self loadIngredient:nil loadUsage:nil loadSideEffect:nil loadNotice:self.mediDetail.medNotice setTextField:medNoticeTextTextField];
//            
//
//            break;
//            
//        default:
//            break;
//    }
//    return cell;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    CGFloat cellHeight;
//    
//    switch (indexPath.row) {
//        case 0:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC1"];
//            cellHeight = 170.0f;
//            break;
//        case 1:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC2"];
//            cellHeight = 170.0f;
//            break;
//        case 2:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC3"];
//            cellHeight = 44.0f;
//            break;
//        case 3:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC4"];
//            cellHeight = 44.0f;
//          break;
//      case 4:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC5"];
//            cellHeight = 44.0f;
//            break;
//        case 5:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC6"];
//            cellHeight = 44.0f;
//          break;
//        case 6:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC7"];
//            cellHeight = 44.0f;
//            break;
//        case 7:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC8"];
//            cellHeight = 10.0f;
//          break;
//      case 8:
//          cell = [tableView dequeueReusableCellWithIdentifier:@"DC9"];
//            cellHeight = 80.0f;
//            break;
//        case 9:
//            cell = [tableView dequeueReusableCellWithIdentifier:@"DC10"];
//            cellHeight = 80.0f;
//            break;
//            
//        default:
//            break;
//    }
//    if (indexPath.row == 0) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC1"];
//        cellHeight = 170.0f;
//    } else if (indexPath.row == 1) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC2"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 2) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC3"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 3) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC4"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 4) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC5"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 5) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC6"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 6) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC7"];
//        cellHeight = 44.0f;
//    } else if (indexPath.row == 7) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC8"];
//        cellHeight = 80.0f;
//    } else if (indexPath.row == 8) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC9"];
//        cellHeight = 80.0f;
//    } else if (indexPath.row == 9) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"DC10"];
//        cellHeight = 80.0f;
//    }
//    
//    return cellHeight;
//}

#pragma mark - TextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField andTextViewShouldReturn:(UITextView *)textView {
    
    [textField resignFirstResponder];
    [textView resignFirstResponder];
    return YES;
}/*
//TODO: Test here
for (NSArray *tmpArray in array) {
    //
    [[MediDataBase shareInstance] insertMediDictionary:tmpArray];
}
meds = [[MediDataBase shareInstance] queryMedi];
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
