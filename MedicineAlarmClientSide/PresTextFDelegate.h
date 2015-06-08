//
//  PresTextFDelegate.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/5/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class textfield;
@protocol PresTextFieldDelegate <NSObject>



-(void)didClickedTextField:(NSInteger)textfieldIndex;
-(void)setTextFieldAble:(NSInteger)textfieldIndex;

@end


@interface PresTextFDelegate : NSObject

@property (weak, nonatomic) id<PresTextFieldDelegate>delegate;
@property (nonatomic) NSInteger textfieldTag;

-(IBAction)textFieldClicked:(UITextField *)sender;


@end
