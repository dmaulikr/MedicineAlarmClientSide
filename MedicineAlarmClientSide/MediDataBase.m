//
//  MediDataBase.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/20/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MediDataBase.h"

MediDataBase *shareInstance;

@implementation MediDataBase

-(void)loadDB {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths firstObject];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"Medicine_database.sqlite"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could not open db");
        return;
    }
}

-(id)init {
    
    self = [super init];
    if (self) {
        [self loadDB];
    }
    return self;
}

+(MediDataBase *)shareInstance {
    
    if (shareInstance == nil) {
        shareInstance = [[MediDataBase alloc] init];
    }
    return shareInstance;
}

#pragma mark - db methods
// browse
-(id)queryMedi {
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    FMResultSet *result = [db executeQuery:@"select * from medicineDetail by medID"];
    
    while ([result next]) {
        // BOF 1 2 3 4 5 ... EOF
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

// check mediname data
-(id)queryMediName:(NSString *)mediName {
    
    NSString *query = [NSString stringWithFormat:@"%@%%", mediName];
    
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    FMResultSet *result = [db executeQuery:@"select * from medicineDetail where medMerEngName like ? order by medID", query];
    while ([result next]) {
        // BOF 1 2 3 4 5 ... EOF
        [rows addObject:result.resultDictionary];
    }
    return rows;
}

// receive 流水號
-(NSString *)newMediID {
    
    int maxid = 1;
    FMResultSet *result = [db executeQuery:@"select max(medID) from medicineDetail"];
    [result next];
    maxid = [result intForColumnIndex:0] +1;
    
    return [NSString stringWithFormat:@"%03d", maxid];
}

// add by col
-(void)insertMediID:(NSString *)mediID andMediImage:(UIImage *)image andMediMerEng:(NSString *)merEng andMediMerChi:(NSString *)merChi andMediScience:(NSString *)science andMediCategory:(NSString *)category andMedIngredient:(NSString *)ingredient andMedUsage:(NSString *)usage andMedSideEffect:(NSString *)sideEffect andMedNotice:(NSString *)notice {
    if (![db executeUpdate:@"insert into medicineDetail (medID,medImage,medMerEngName,medMerChiName,medScienceName,medCategory,medIngredient,medUsage,medSideEffect,medNotice) values (?,?,?,?,?,?,?,?,?,?)", mediID, image, merEng, merChi, science, category, ingredient, usage, sideEffect, notice]) {
        NSLog(@"Could not insert data:\n%@",[db lastErrorMessage]);
    };
}

// edit
-(void)updateMediID:(NSString *)mediID andMediImage:(PFObject *)image andMediMerEng:(NSString *)merEng andMediMerChi:(NSString *)merChi andMediScience:(NSString *)science andMediCategory:(NSString *)category andMedIngredient:(NSString *)ingredient andMedUsage:(NSString *)usage andMedSideEffect:(NSString *)sideEffect andMedNotice:(NSString *)notice {
    if (![db executeUpdate:@"update medicineDetail set medImage=?,medMerEngName=?,medMerChiName=?,medScienceName=?,medCategory=?,medIngredient=?,medUsage=?,medSideEffect=?,medNotice=? where medID=?", image, merEng, merChi, science, category, ingredient, usage, sideEffect, notice, mediID]) {
        NSLog(@"Could not update data:\n%@",[db lastErrorMessage]);
    };
}

// delete
-(void)deleteMediID:(NSString *)mediID {
    if (![db executeUpdate:@"delete from medicineDetail where medID=?", mediID]) {
        NSLog(@"Could'nt delete data:\n%@", [db lastErrorMessage]);
    }
}

// add by dictionary into SQLite
-(void)insertMediDictionary:(NSDictionary *)mediDict {
    /*
     Parse          Local SQLite
     medID          medID
     medImage       medImage
     medMerEngName  medMerEngName
     medMerChiName  medMerChiName
     medScienceName medScienceName
     medCategory    medCategory
     medIngredient  medIngredient
     medUsage       medUsage
     medSideEffect  medSideEffect
     medNotice      medNotice
     */
    
    FMResultSet *result = [db executeQuery:@"select count(*) from medicineDetail where medID=?", mediDict[@"medID"]];
    while ([result next]) {
        if ([result intForColumnIndex:0] == 0) {
            // addable
            if (![db executeUpdate:@"insert into medicineDetail (medID,medImage,medMerEngName,medMerChiName,medScienceName,medCategory,medIngredient,medUsage,medSideEffect,medNotice) values (?,?,?,?,?,?,?,?,?,?)",
                  mediDict[@"medID"],
                  mediDict[@"medImage"],
                  mediDict[@"medMerEngName"],
                  mediDict[@"medMerChiName"],
                  mediDict[@"medScienceName"],
                  mediDict[@"medCategory"],
                  mediDict[@"medIngredient"],
                  mediDict[@"medUsage"],
                  mediDict[@"medSideEffect"],
                  mediDict[@"medNotice"]]) {
                //
                NSLog(@"Could not insertDictionary data:\n%@", [db lastErrorMessage]);
            }
        }
    }
}

// add by PFObject into SQLite
-(void)insertPFObject:(PFObject *)object {
    /*
     Parse          Local SQLite
     medID          medID
     medImage       medImage
     medMerEngName  medMerEngName
     medMerChiName  medMerChiName
     medScienceName medScienceName
     medCategory    medCategory
     medIngredient  medIngredient
     medUsage       medUsage
     medSideEffect  medSideEffect
     medNotice      medNotice
     */
    
    FMResultSet *result = [db executeQuery:@"select count(*) from medicineDetail where medID=?", object[@"medID"]];
    while ([result next]) {
        if ([result intForColumnIndex:0] == 0) {
            // addable
            if (![db executeUpdate:@"insert into medicineDetail (medID,medImage,medMerEngName,medMerChiName,medScienceName,medCategory,medIngredient,medUsage,medSideEffect,medNotice) values (?,?,?,?,?,?,?,?,?,?)",
//                  object[@"medID"],
//                  object[@"medImage"],
//                  object[@"medMerEngName"],
//                  object[@"medMerChiName"],
//                  object[@"medScienceName"],
//                  object[@"medCategory"],
//                  object[@"medIngredient"],
//                  object[@"medUsage"],
//                  object[@"medSideEffect"],
//                  object[@"medNotice"]
                  [object objectForKey:@"medID"],
                  [object objectForKey:@"medImage"],
                  [object objectForKey:@"medMerEngName"],
                  [object objectForKey:@"medMerChiName"],
                  [object objectForKey:@"medScienceName"],
                  [object objectForKey:@"medCategory"],
                  [object objectForKey:@"medIngredient"],
                  [object objectForKey:@"medUsage"],
                  [object objectForKey:@"medSideEffect"],
                  [object objectForKey:@"medNotice"]
                  ]) {
                //
                NSLog(@"Could not insertPFObject data:\n%@", [db lastErrorMessage]);
            }
        }
    }
}



@end
