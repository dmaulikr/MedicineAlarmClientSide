//
//  PrescriptionCellDelegate.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/4/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

#ifndef MedicineAlarmClientSide_PrescriptionCellDelegate_h
#define MedicineAlarmClientSide_PrescriptionCellDelegate_h


#endif

@protocol CellDelegate <NSObject>

- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data;
/*
- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withString:(NSString *)string;
-(void)didClickOnCellAtIndex:(NSInteger)cellIndex withObject:(PFObject *)object;
*/
@end
