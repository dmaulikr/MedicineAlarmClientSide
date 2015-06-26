//
//  MediDataSingleton.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/8/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediDataSingleton : NSObject

@property (nonatomic) NSInteger medIndex;
@property (retain, nonatomic) NSString *medName;
@property (retain, nonatomic) NSString *medDosage;
@property (retain, nonatomic) NSString *medHowtouse;
@property (retain, nonatomic) NSString *medFrequency;
@property (retain, nonatomic) NSString *medMeal;
@property (retain, nonatomic) NSString *medDays;
@property (retain, nonatomic) NSString *medQuantity;

@property float medDaysValue;
@property float medFrequencyValue;
@property float medTotalQuantity;

@property (retain, nonatomic) NSNumber *lastNumber;


+(MediDataSingleton *)shareInstance;



@end
