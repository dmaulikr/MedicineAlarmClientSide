//
//  PopMealVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PopMealVC.h"
#import "MediDataSingleton.h"

@interface PopMealVC () {
    
    
}

@property (weak, nonatomic) NSString *mealString;

@end

@implementation PopMealVC

-(void)viewDidLoad {
    
    self.preferredContentSize = CGSizeMake(300, 300);
}

- (IBAction)mealBtnClicked:(UITextField *)sender {
    
    switch (sender.tag) {
        case 101:
            _mealString = @"AC";
            break;
        case 102:
            _mealString = @"PC";
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    
    [MediDataSingleton shareInstance].medMeal = _mealString;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"meal"] forKey:@"pass"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPop" object:nil userInfo:dictionary];
}


@end
