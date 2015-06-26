//
//  PopFrequencyVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PopFrequencyVC.h"
#import "MediDataSingleton.h"

@interface PopFrequencyVC ()

@property (weak, nonatomic) NSString *frequencyString;
@property NSInteger frequencyValue;
@property float tmpInt;

@end

@implementation PopFrequencyVC

-(void)viewDidLoad {
    
    self.preferredContentSize = CGSizeMake(300, 300);
}
- (IBAction)frequencyBtnClicked:(UITextField *)sender {
    
    switch (sender.tag) {
        case 101:
            _frequencyString = @"QD";
            _frequencyValue = 1;
            break;
        case 102:
            _frequencyString = @"BID";
            _frequencyValue = 2;
            break;
        case 103:
            _frequencyString = @"TID";
            _frequencyValue = 3;
            break;
        case 104:
            _frequencyString = @"QID";
            _frequencyValue = 4;
            break;
        case 105:
            _frequencyString = @"QN";
            _frequencyValue = 1;
            break;
        case 106:
            _frequencyString = @"HS";
            _frequencyValue = 1;
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    
    [MediDataSingleton shareInstance].medFrequency = _frequencyString;
    
    [MediDataSingleton shareInstance].medFrequencyValue = _frequencyValue;
    
    NSMutableString *string = [[NSMutableString alloc] init];
    
    string = (NSMutableString *)[string stringByAppendingString:[MediDataSingleton shareInstance].medDosage];
    
    if ([[MediDataSingleton shareInstance].medDosage containsString:@"PC"] ) {
        
        string = (NSMutableString *)[[MediDataSingleton shareInstance].medDosage substringWithRange:NSMakeRange(0, 3)];
        NSLog(@"substring: %@", string);
        
        _tmpInt = [[NSString stringWithFormat:@"%@", string] floatValue];
        
        _tmpInt = _tmpInt * [MediDataSingleton shareInstance].medFrequencyValue;
        
        _tmpInt = _tmpInt * [MediDataSingleton shareInstance].medDaysValue;
        
        [MediDataSingleton shareInstance].medTotalQuantity = roundf(_tmpInt);
        
        
    } else {
        
        [MediDataSingleton shareInstance].medTotalQuantity = 1;
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"frequency"] forKey:@"pass"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPop" object:nil userInfo:dictionary];
}

@end
