//
//  Medicine.h
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import <ParseUI/ParseUI.h>

@interface Medicine : NSObject

//
@property (nonatomic, strong) NSString *medID;
@property (nonatomic, strong) PFFile *medImageFile;
//@property (nonatomic, strong) NSString *medCode;
//
@property (nonatomic, strong) NSString *medMerEngName;
@property (nonatomic, strong) NSString *medMerChiName;
@property (nonatomic, strong) NSString *medScienceName;
@property (nonatomic, strong) NSString *medCategory;
//
@property (nonatomic, strong) NSString *medIngredient;
@property (nonatomic, strong) NSString *medAdaptation;
@property (nonatomic, strong) NSString *medUsage;
@property (nonatomic, strong) NSString *medSideEffect;
@property (nonatomic, strong) NSString *medNotice;

@end
