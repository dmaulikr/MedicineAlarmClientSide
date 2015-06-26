//
//  PopDaysVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PopDaysVC.h"
#import "MediDataSingleton.h"

@interface PopDaysVC ()

@property (weak, nonatomic) NSString *daysString;
@property float tmpInt;
@property float daysValue;

@end

@implementation PopDaysVC

-(void)viewDidLoad {
    
    self.preferredContentSize = CGSizeMake(300, 300);
}
- (IBAction)daysBtnClicked:(UITextField *)sender {
    
    switch (sender.tag) {
        case 101:
            _daysString = @"1天";
            _daysValue = 1;
            break;
        case 102:
            _daysString = @"2天";
            _daysValue = 2;
            break;
        case 103:
            _daysString = @"3天";
            _daysValue = 3;
            break;
        case 104:
            _daysString = @"4天";
            _daysValue = 4;
            break;
        case 105:
            _daysString = @"5天";
            _daysValue = 5;
            break;
        case 106:
            _daysString = @"6天";
            _daysValue = 6;
            break;
        case 107:
            _daysString = @"7天";
            _daysValue = 7;
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    
    [MediDataSingleton shareInstance].medDays = _daysString;
    [MediDataSingleton shareInstance].medDaysValue = _daysValue;
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    string = (NSMutableString *)[string stringByAppendingString:[MediDataSingleton shareInstance].medDosage];
    
    if ([[MediDataSingleton shareInstance].medDosage containsString:@"PC"] ) {
        
        string = (NSMutableString *)[[MediDataSingleton shareInstance].medDosage substringWithRange:NSMakeRange(0, 3)];
        NSLog(@"substring: %@", string);
        
        _tmpInt = [[NSString stringWithFormat:@"%@", string] floatValue];
        
        _tmpInt = _tmpInt * [MediDataSingleton shareInstance].medFrequencyValue;
        
        _tmpInt = _tmpInt * _daysValue;
        
        [MediDataSingleton shareInstance].medTotalQuantity = roundf(_tmpInt);
        
    } else {
        
        [MediDataSingleton shareInstance].medTotalQuantity = 1;
    }
    
    
    
    
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"days"] forKey:@"pass"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPop" object:nil userInfo:dictionary];
}

@end
