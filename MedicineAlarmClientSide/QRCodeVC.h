//
//  QRCodeVC.h
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/13/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "ViewController.h"

@interface QRCodeVC : ViewController


@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) UIImage *receiveImage;

@end
