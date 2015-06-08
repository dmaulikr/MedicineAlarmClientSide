//
//  PrescriptionCell.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/3/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PrescriptionCell.h"

@implementation PrescriptionCell

-(void)buttonClicked:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCellAtIndex:withString:)]) {
        [self.delegate didClickOnCellAtIndex:_cellIndex withString:self.medMerChiLabel.text];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end