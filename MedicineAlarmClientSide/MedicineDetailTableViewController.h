//
//  MedicineDetailTableViewController.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/24/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medicine.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>

@interface MedicineDetailTableViewController : UITableViewController

@property (strong, nonatomic) Medicine *mediDetail;
@property (strong, nonatomic) NSString *receiveObjectId;
@end
