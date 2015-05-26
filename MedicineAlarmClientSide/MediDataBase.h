//
//  MediDataBase.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/20/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import <Parse/Parse.h>

@interface MediDataBase : NSObject {
    FMDatabase *db;
}

+(MediDataBase *)shareInstance;

// browse
-(id)queryMedi;

// check mediname data
-(id)queryMediName:(NSString *)mediName;

// receive 流水號
-(NSString *)newMediID;

// add by col
-(void)insertMediID:(NSString *)mediID andMediImage:(PFObject *)image andMediMerEng:(NSString *)merEng andMediMerChi:(NSString *)merChi andMediScience:(NSString *)science andMediCategory:(NSString *)category andMedIngredient:(NSString *)ingredient andMedUsage:(NSString *)usage andMedSideEffect:(NSString *)sideEffect andMedNotice:(NSString *)notice;

// edit
-(void)updateMediID:(NSString *)mediID andMediImage:(PFObject *)image andMediMerEng:(NSString *)merEng andMediMerChi:(NSString *)merChi andMediScience:(NSString *)science andMediCategory:(NSString *)category andMedIngredient:(NSString *)ingredient andMedUsage:(NSString *)usage andMedSideEffect:(NSString *)sideEffect andMedNotice:(NSString *)notice;

// delete
-(void)deleteMediID:(NSString *)mediID;

// add by dictionary
-(void)insertMediDictionary:(NSDictionary *)mediDict;

// add by PFObject
-(void)insertPFObject:(PFObject *)object;


@end
