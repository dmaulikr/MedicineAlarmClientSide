//
//  QRCodeVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/13/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "QRCodeVC.h"

@interface QRCodeVC ()

@end

@implementation QRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preferredContentSize = CGSizeMake(300, 300);
    
    _qrcodeImageView.image = _receiveImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end