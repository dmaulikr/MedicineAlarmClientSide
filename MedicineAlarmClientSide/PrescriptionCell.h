//
//  PrescriptionCell.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/3/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrescriptionCellDelegate.h"

@interface PrescriptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *medMerEngLabel;
@property (weak, nonatomic) IBOutlet UILabel *medMerChiLabel;

@property (weak, nonatomic) IBOutlet UILabel *medScienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *medCategoryLabel;

@property (weak, nonatomic) IBOutlet UIButton *addPrescriptButton;

@property (weak, nonatomic) id<CellDelegate>delegate;
@property (nonatomic) NSInteger cellIndex;


- (IBAction)buttonClicked:(UIButton *)sender;
@end
