//
//  PopDosageVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PopDosageVC.h"
#import "MediDataSingleton.h"
#import "PrescriptionGenaratorVC.h"

@interface PopDosageVC () {
    

}

@property float tmpInt;

@property (strong, nonatomic) NSString *dosageString;
@property (weak, nonatomic) NSString *unitString;
@property (weak, nonatomic) NSString *amount;

@property (weak, nonatomic) IBOutlet UIButton *unitButton;
@property (weak, nonatomic) IBOutlet UIButton *amountButton;

@property (weak, nonatomic) UIAlertController *alert;

@property (weak, nonatomic) UIPopoverController *popController;
@end

@implementation PopDosageVC



-(void)viewDidLoad {
    
    self.preferredContentSize = CGSizeMake(300, 300);
}

- (IBAction)unitClicked:(UIButton *)sender {
    
    _unitString = @"";
    
    switch (sender.tag) {
        case 201:
            _unitString = @"PC";
            break;
        case 202:
            _unitString = @"Drop";
            break;
        default:
            break;
    }
    NSLog(@"%@", _unitString);
//    _unitButton.tag = sender.tag;
//    [_unitButton setSelected:YES];
    
    if (_amount!= nil && _unitString != nil) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)dosageAmountClicked:(UIButton *)sender {

    _amount = @"";
    
    switch (sender.tag) {
        case 105:
            _amount = @"0.5/";
            break;
        case 110:
            _amount = @"1.0/";
            break;
        case 115:
            _amount = @"1.5/";
            break;
        case 120:
            _amount = @"2.0/";
            break;
        case 125:
            _amount = @"2.5/";
            break;
        case 130:
            _amount = @"3.0/";
            break;

        default:
            break;
    }
    NSLog(@"%@", _amount);
//    _amountButton.tag = sender.tag;
//    [_amountButton setSelected:YES];
    
    if (_amount!= nil && _unitString != nil) {
        
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    
}

-(void)defineBothBtnClicked:(UIButton *)button {
    
    if (_amount == nil) {
        _alert = [UIAlertController alertControllerWithTitle:@"Please Select" message:@"Amount" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [_alert addAction:cancelBtn];
        [self presentViewController:_alert animated:YES completion:nil];
    } else if (_unitString == nil) {
        
        _alert = [UIAlertController alertControllerWithTitle:@"Please Select" message:@"unit" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [_alert addAction:cancelBtn];
        [self presentViewController:_alert animated:YES completion:nil];
    } else if (_amount == nil && _unitString == nil) {
        
        _alert = [UIAlertController alertControllerWithTitle:@"Please Select" message:@"Both Kind of Dosage" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [_alert addAction:cancelBtn];
        [self presentViewController:_alert animated:YES completion:nil];
    }
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    _dosageString = [_amount stringByAppendingString:_unitString];
    
    [MediDataSingleton shareInstance].medDosage = _dosageString;
    
    
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
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"dosage"] forKey:@"pass"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPop" object:nil userInfo:dictionary];
}


@end
