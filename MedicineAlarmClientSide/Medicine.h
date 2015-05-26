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

@property (nonatomic, strong) PFFile *imageFile;
//
@property (nonatomic, strong) NSString *medID;
@property (nonatomic, strong) PFFile *medImage;
//@property (nonatomic, strong) NSString *medCode;
//
@property (nonatomic, strong) NSString *medMerEngName;
@property (nonatomic, strong) NSString *medMerChiName;
@property (nonatomic, strong) NSString *medScienceName;
@property (nonatomic, strong) NSString *medCategory;
//
@property (nonatomic, strong) NSArray *medIngredient;
@property (nonatomic, strong) NSArray *medUsage;
@property (nonatomic, strong) NSArray *medSideEffect;
@property (nonatomic, strong) NSArray *medNotice;

@end
