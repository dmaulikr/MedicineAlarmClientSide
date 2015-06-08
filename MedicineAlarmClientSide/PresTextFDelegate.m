//
//  PresTextFDelegate.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PresTextFDelegate.h"

@implementation PresTextFDelegate

-(void)textFieldClicked:(UITextField *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedTextField:)]) {
        [self.delegate didClickedTextField:_textfieldTag];
    }
}


@end
