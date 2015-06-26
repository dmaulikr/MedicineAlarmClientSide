//
//  PrescriptionGeneratorTVC.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/2/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Bolts/Bolts.h>
#import "ViewController.h"
#import "PrescriptionCell.h"


@interface PrescriptionGeneratorTVC : PFQueryTableViewController <UITableViewDataSource, UITableViewDelegate, UISplitViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, CellDelegate>

@end
