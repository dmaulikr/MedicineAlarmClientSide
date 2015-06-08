//
//  MedicineTableViewController.h
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>

@interface MedicineTableViewController : PFQueryTableViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate>

+(void)downloadAnimation;

@end
