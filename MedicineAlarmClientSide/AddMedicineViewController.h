//
//  AddMedicineViewController.h
//  MedicineParse
//
//  Created by Stan Liu on 5/17/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medicine.h"

@interface AddMedicineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
}

@property (strong, nonatomic) Medicine *mediAdd;

@end
