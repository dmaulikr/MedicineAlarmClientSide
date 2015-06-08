//
//  AddMedicineTableViewController.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/26/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medicine.h"

@interface AddMedicineTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
}

@property (strong, nonatomic) Medicine *mediAdd;

@end
