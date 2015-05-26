//
//  MedicineDetailViewController.h
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Medicine.h"
#import <ParseUI/ParseUI.h>


@interface MedicineDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
// catch data from segue
@property (strong, nonatomic) Medicine *mediDetail;
@property (assign, nonatomic) NSInteger flag; // 1: add 2: edit
@property (strong, nonatomic) NSDictionary *dictt;






@end
