//
//  PopHowtouseVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PopHowtouseVC.h"
#import "MediDataSingleton.h"

@interface PopHowtouseVC ()

@property (weak, nonatomic) NSString *howtouseString;

@end

@implementation PopHowtouseVC

-(void)viewDidLoad {
    
    self.preferredContentSize = CGSizeMake(300, 300);
}

- (IBAction)howToUseBtnClicked:(UITextField *)sender {
    
    switch (sender.tag) {
        case 101:
            _howtouseString = @"口服";
            break;
        case 102:
            _howtouseString = @"滴藥";
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    
    [MediDataSingleton shareInstance].medHowtouse = _howtouseString;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"howtouse"] forKey:@"pass"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPop" object:nil userInfo:dictionary];
}


@end
