//
//  MediDataSingleton.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/8/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MediDataSingleton.h"

static MediDataSingleton *shareInstance;

@implementation MediDataSingleton

+(MediDataSingleton *)shareInstance {
    
    if (shareInstance == nil) {
        
        shareInstance = [[MediDataSingleton alloc] init];
    }
    return shareInstance;
}

@end
