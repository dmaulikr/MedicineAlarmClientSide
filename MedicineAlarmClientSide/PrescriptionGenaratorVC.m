//
//  PrescriptionGenaratorVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/2/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PrescriptionGenaratorVC.h"

#import "PopDosageVC.h"
#import "PopFrequencyVC.h"
#import "PopDaysVC.h"
#import "PopMealVC.h"
#import "PopQuantityVC.h"
#import "PopHowtouseVC.h"
#import "QRCodeVC.h"

#import "MediDataSingleton.h"

#import <CoreImage/CoreImage.h>


#define TEXTFIELDWIDTH 250
#define TEXTFIELDHEIGHT 30
#define TEXTVIEWHEIGHT 80

@interface PrescriptionGenaratorVC () <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPopoverControllerDelegate> {
    
    NSInteger flag;
    NSInteger compareValue;
    UIButton *generateQRCodeBtn;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIStepper *medQuantityStepper;
@property (retain, nonatomic) IBOutlet UILabel *stepLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *medNoSegment;

@property (retain, nonatomic) UISegmentedControl * control;

@property (retain, nonatomic) UITextField *textField1;

@property (retain, nonatomic) UITextField *medNameTF;

@property (retain, nonatomic) UITextView *textView1;

@property (retain, nonatomic) UIPopoverController *popDosage;
@property (retain, nonatomic) UIPopoverController *popFrequency;
@property (retain, nonatomic) UIPopoverController *popDays;
@property (retain, nonatomic) UIPopoverController *popMeal;
@property (retain, nonatomic) UIPopoverController *popHowtouse;

@property (retain, nonatomic) UIPopoverController *popQRCode;

@property (retain, nonatomic) UITextField *nowTextField;

@end

@implementation PrescriptionGenaratorVC {
    int tx;
    int textfieldTAG;
    int segmentIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // new a button to target generateQRCode action.
    generateQRCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 650, 70, 70)];
    [generateQRCodeBtn addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    [generateQRCodeBtn setImage:[UIImage imageNamed:@"sunming-eye.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:generateQRCodeBtn];
    
    // set scrollview property
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self.scrollView setDelegate:self];
    [self.scrollView setScrollEnabled:YES];
    
    // set self.scrollview frame size
    CGFloat width, height;
    width = self.scrollView.frame.size.width;
    height = self.scrollView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width * 5, height)];
    
    // set stepper size
    _medQuantityStepper = [[UIStepper alloc] initWithFrame:CGRectMake(100, 15, 60, 40)];
    [_medQuantityStepper addTarget:self action:@selector(didStepperClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_medQuantityStepper setMaximumValue:6];
    [_medQuantityStepper setMinimumValue:0];
    [_medQuantityStepper setStepValue:1];
    [_medQuantityStepper setAutorepeat:NO];
    [_medQuantityStepper setHighlighted:YES];
    [_medQuantityStepper setUserInteractionEnabled:YES];


    _stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 30, 30)];
    _stepLabel.text = @"0";

    
    /*
     NSArray *arrayObject = @[@"1"];
    _medNoSegment = [[UISegmentedControl alloc] initWithItems:arrayObject];
    _medNoSegment.frame = CGRectMake(10, 60, TEXTFIELDWIDTH, _medNoSegment.frame.size.height);
    
    [self.scrollView addSubview:_medNoSegment];
     */
    
    [self.scrollView addSubview:_medQuantityStepper];
    [self.scrollView addSubview:_stepLabel];
    
    // listening if pressed add button on master
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressAddButtonFromTVC) name:@"add" object:nil];
    // listening if popover dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopoverController:) name:@"dismissPop" object:nil];
    
    
    tx = 11;
    textfieldTAG = 101;
    segmentIndex = 1;
    compareValue = self.medQuantityStepper.value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - stepper
// Adjuset Stepper to increase or decrease the number of segment and textfield
-(void)didStepperClicked:(UIStepper *)sender {
    
    // if stepper value, set x coordinate and tag
    if (sender.value == 1) {
        tx = 11;
        textfieldTAG = 101;
    } else if (sender.value == 2) {
        tx = 11 + 251;
        textfieldTAG = 201;
    } else if (sender.value == 3) {
        tx = 11 + 251 + 251;
        textfieldTAG = 301;
    } else if (sender.value == 4) {
        tx = 11 + 251 + 251 + 251;
        textfieldTAG = 401;
    }
    else if (sender.value == 5) {
        tx = 11 + 251 + 251 + 251 + 251 ;
        textfieldTAG = 501;
    } else if (sender.value == 6) {
        tx = 11 + 251 + 251 + 251 + 251 + 251;
        textfieldTAG = 601;
    }
    
#define TEXTORIGINX 11
#define TEXTORIGINY 110
#define TFTAG 101;
    
    // when pressed increasebutton
    if (sender.value > compareValue) {
        compareValue += 1;
//        NSLog(@"compare add :%ld", compareValue);
        
        NSArray *arr = @[@"",@"1",@"2",@"3",@"4",@"5",@"6"];
        NSMutableArray *mArr = [[NSMutableArray alloc] init];
        int a = 0;
        for (int i = 1 ; i <= _medQuantityStepper.value ; i++) {
            
            [mArr insertObject:[arr objectAtIndex:i] atIndex:i-1];
            a = i;
        }
        [_medNoSegment removeFromSuperview];
        _medNoSegment = [[UISegmentedControl alloc] initWithItems:mArr];
        _medNoSegment.frame = CGRectMake(10, 60, TEXTFIELDWIDTH * a, _medNoSegment.frame.size.height);
        [_medNoSegment addTarget:self action:@selector(medNoSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        [self.scrollView addSubview:_medNoSegment];
        
        int ty = TEXTORIGINY;
        
        for (int a = 1; a<= 7; a++) {
            
            _textField1 = [[UITextField alloc] initWithFrame:CGRectMake(tx, ty, TEXTFIELDWIDTH -4, TEXTFIELDHEIGHT -4)];
            
            _textField1.tag = textfieldTAG;
            textfieldTAG += 1;
            [_textField1 setBorderStyle:UITextBorderStyleRoundedRect];
            
            [_textField1 setEnabled:NO];
            _textField1.delegate = self;
            
            [self.scrollView addSubview:_textField1];
            ty += 62;
        }
        
        _textView1 = [[UITextView alloc] initWithFrame:CGRectMake(tx, ty, TEXTFIELDWIDTH -4, TEXTVIEWHEIGHT)];
        _textView1.tag = textfieldTAG;
        _textView1.delegate = self;
        [self.scrollView addSubview:_textView1];
        [_textView1 setEditable:NO];
        
//        tx += 251;
        
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield == nil) {
                tx -= 251;
            }
        }
        if (textfieldTAG == 108) textfieldTAG = 201;
        else if (textfieldTAG == 208) textfieldTAG = 301;
        else if (textfieldTAG == 308) textfieldTAG = 401;
        else if (textfieldTAG == 408) textfieldTAG = 501;
        else if (textfieldTAG == 508) textfieldTAG = 601;
        else if (textfieldTAG == 608) textfieldTAG = 701;
        
        ty = TEXTORIGINY;

    
    } else {
        
        // when pressed decrease button
        compareValue -= 1;
//        NSLog(@"compare dd :%ld", compareValue);
        
            [_medNoSegment removeSegmentAtIndex:_medQuantityStepper.value  animated:NO];
        
        _medNoSegment.frame = CGRectMake(10, 60, TEXTFIELDWIDTH * _medQuantityStepper.value -1, _medNoSegment.frame.size.height);
        [_medNoSegment addTarget:self action:@selector(medNoSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self removeTextField:sender.value + 1];
    }
    // print stepper.value on label
    _stepLabel.text = [NSString stringWithFormat:@"%0.f", _medQuantityStepper.value];
    
}

#pragma mark - popOver when Clicked textfield
// textfield show popover
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
//    NSLog(@"%ld", textField.tag);
#if 1
    
    PopDosageVC *dosageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"dosageVC"];
    _popDosage = [[UIPopoverController alloc] initWithContentViewController:dosageVC];
    [_popDosage setDelegate:self];
    
    PopFrequencyVC *frequencyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"frequencyVC"];
    _popFrequency = [[UIPopoverController alloc] initWithContentViewController:frequencyVC];
    [_popFrequency setDelegate:self];
    
    PopDaysVC *daysVC = [self.storyboard instantiateViewControllerWithIdentifier:@"daysVC"];
    _popDays = [[UIPopoverController alloc] initWithContentViewController:daysVC];
    [_popDays setDelegate:self];
    
    PopMealVC *mealVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mealVC"];
    _popMeal = [[UIPopoverController alloc] initWithContentViewController:mealVC];
    [_popMeal setDelegate:self];
    
    PopHowtouseVC *howtouseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"howtouseVC"];
    _popHowtouse = [[UIPopoverController alloc] initWithContentViewController:howtouseVC];
    [_popHowtouse setDelegate:self];
    
    // Calculate if textfield right or left, set popover not block the sight of textfield
    CGRect leftRect = textField.frame;
    leftRect.size.width = 1;
    leftRect.origin.x = CGRectGetMinX(textField.frame);
    
    CGRect rightRect = textField.frame;
    rightRect.size.width = 1;
    rightRect.origin.x = CGRectGetMaxX(textField.frame);
    
//    int dx = CGRectGetMaxX(textField.frame);
//    popDosage.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 1);
    
    CGRect viewRect = self.scrollView.frame;
    viewRect.origin.x = CGRectGetMaxX(self.view.frame) * 3/2 ;

    CGRect rect = textField.frame;
    if (textField.frame.origin.x < viewRect.origin.x) {

        rect.origin.x = leftRect.origin.x;
    }else {
        rect.origin.x = rightRect.origin.x;
    }
//            NSLog(@"rect: %f", rect.origin.x);
//            NSLog(@"LEFTrect: %f", leftRect.origin.x);
//            NSLog(@"Rightrect: %f", rightRect.origin.x);

    if (textField.tag%100 == 2) {
        [_popDosage presentPopoverFromRect:rect inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        NSLog(@"if rect: %f", rect.origin.x);
    } else if (textField.tag%100 == 3) {
        [_popHowtouse presentPopoverFromRect:rect inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else if (textField.tag%100 == 4) {
        [_popFrequency presentPopoverFromRect:rect inView:self.scrollView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else if (textField.tag%100 == 5) {
        [_popMeal presentPopoverFromRect:rect inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    } else if (textField.tag%100 == 6) {
        [_popDays presentPopoverFromRect:rect inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    flag = textField.tag;
    _nowTextField = textField;
//    NSLog(@"%@", textField.description);
#else
    
#endif
    return NO;
}

-(void)dismissPopoverController:(NSNotification *)notification {
    
    if ([[[notification userInfo] valueForKey:@"pass"] isEqualToString:@"dosage"]) {
        
        if (flag%100 == 2) {
            _nowTextField.text = [MediDataSingleton shareInstance].medDosage;
            _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +5];
            _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        }
        [_popDosage dismissPopoverAnimated:YES];
    } else if ([[[notification userInfo] valueForKey:@"pass"] isEqualToString:@"frequency"]) {
        
        _nowTextField.text = [MediDataSingleton shareInstance].medFrequency;
        _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +3];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        [_popFrequency dismissPopoverAnimated:YES];
    } else if ([[[notification userInfo] valueForKey:@"pass"] isEqualToString:@"howtouse"]) {
        
        _nowTextField.text = [MediDataSingleton shareInstance].medHowtouse;
        [_popHowtouse dismissPopoverAnimated:YES];
    } else if ([[[notification userInfo] valueForKey:@"pass"] isEqualToString:@"days"]) {
        
        _nowTextField.text = [MediDataSingleton shareInstance].medDays;
        _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +1];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        [_popDays dismissPopoverAnimated:YES];
    } else if ([[[notification userInfo] valueForKey:@"pass"] isEqualToString:@"meal"]) {
        
        _nowTextField.text = [MediDataSingleton shareInstance].medMeal;
        
        [_popMeal dismissPopoverAnimated:YES];
    }
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
//    if (popoverController == _popDosage) {
//        NSLog(@"123");
//    }
    
    if (flag%100 == 2) {
        _nowTextField.text = [MediDataSingleton shareInstance].medDosage;
        _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +1];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];

    } else if (flag%100 == 3) {
        _nowTextField.text = [MediDataSingleton shareInstance].medHowtouse;
        
    } else if (flag%100 == 4) {
        _nowTextField.text = [MediDataSingleton shareInstance].medFrequency;
        _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +1];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
    } else if (flag%100 == 5) {
        _nowTextField.text = [MediDataSingleton shareInstance].medMeal;
        
    } else if (flag%100 == 6) {
        _nowTextField.text = [MediDataSingleton shareInstance].medDays;
        _textField1 = (UITextField *)[self.scrollView viewWithTag:flag +1];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
    }
}

#pragma mark - Segment
-(IBAction)medNoSegmentChanged:(id)segment {
    
    _control = segment;
    NSInteger selectedIndex = (int)[_control selectedSegmentIndex];
#if 0
#else
    // 1
    if (selectedIndex == 0) {
        
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield.tag != 0) {
                if (textfield.tag >101 && textfield.tag < 107) [textfield setEnabled:YES];
                else if (textfield.tag >601 && textfield.tag <608) [textfield setEnabled:NO];
                else if (textfield.tag >201 && textfield.tag <208) [textfield setEnabled:NO];
                else if (textfield.tag >301 && textfield.tag <308) [textfield setEnabled:NO];
                else if (textfield.tag >401 && textfield.tag <408) [textfield setEnabled:NO];
                else if (textfield.tag >501 && textfield.tag <508) [textfield setEnabled:NO];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag != 0) {
                if (textview.tag == 108) [textview setEditable:YES];
                else if (textview.tag == 608)[textview setEditable:NO];
                else if (textview.tag == 208)[textview setEditable:NO];
                else if (textview.tag == 308)[textview setEditable:NO];
                else if (textview.tag == 408)[textview setEditable:NO];
                else if (textview.tag == 508)[textview setEditable:NO];
            }
        }
    }
    // 2
    if (selectedIndex == 1) {
        
        // fill total quantity of pills
        _nowTextField = (UITextField *)[self.scrollView viewWithTag:107];
        _nowTextField.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
        for (UITextField *textfield in self.scrollView.subviews) {
            // examinate empty textfieldt
            if (textfield.tag != 0) {
                if (textfield.tag >= 101 && textfield.tag <= 106 ) {
                    if ([textfield.text isEqualToString:@""]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            _control.selectedSegmentIndex = 0;
                            _medNoSegment.selectedSegmentIndex = 0;
                            for (UITextField *textfield in self.scrollView.subviews) {
                                if (textfield.tag >101 && textfield.tag <107) [textfield setEnabled:YES];
                                else if (textfield.tag >201 && textfield.tag < 207) [textfield setEnabled:NO];
                            }
                        }];
                        [alert addAction:cancelBtn];
                        [self presentViewController:alert animated:true completion:nil];
                    } else {
                        
                        [self initTotalQuantity];
                        // set disable
                        for (UITextField *textfield in self.scrollView.subviews) {
                            
                            if (textfield.tag >201 && textfield.tag < 207) [textfield setEnabled:YES];
                            else if (textfield.tag >101 && textfield.tag <108) [textfield setEnabled:NO];
                            else if (textfield.tag >301 && textfield.tag <308) [textfield setEnabled:NO];
                            else if (textfield.tag >401 && textfield.tag <408) [textfield setEnabled:NO];
                            else if (textfield.tag >501 && textfield.tag <508) [textfield setEnabled:NO];
                            else if (textfield.tag >601 && textfield.tag <608) [textfield setEnabled:NO];
                        }
                        for (UITextView *textview in self.scrollView.subviews) {
                            if (textview.tag != 0) {
                                if (textview.tag == 208) [textview setEditable:YES];
                                else if (textview.tag == 108)[textview setEditable:NO];
                                else if (textview.tag == 308)[textview setEditable:NO];
                                else if (textview.tag == 408)[textview setEditable:NO];
                                else if (textview.tag == 508)[textview setEditable:NO];
                                else if (textview.tag == 608)[textview setEditable:NO];
                            }
                        }
                    }
                }
            }
        }
    }

    //3
    else if (selectedIndex == 2) {
        
        _textField1 = (UITextField *)[self.scrollView viewWithTag:207];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
        for (UITextField *textfield in self.scrollView.subviews) {
            // examinate empty textfieldt
            if (textfield.tag != 0) {
                if (textfield.tag >= 201 && textfield.tag <= 206 ) {
                    if ([textfield.text isEqualToString:@""]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            _control.selectedSegmentIndex = 1;
                            _medNoSegment.selectedSegmentIndex = 1;
                            for (UITextField *textfield in self.scrollView.subviews) {
                                if (textfield.tag >201 && textfield.tag <207) [textfield setEnabled:YES];
                                else if (textfield.tag >301 && textfield.tag < 307) [textfield setEnabled:NO];
                            }
                        }];
                        [alert addAction:cancelBtn];
                        [self presentViewController:alert animated:true completion:nil];
                    } else {
                        
                        // set disable
                        for (UITextField *textfield in self.scrollView.subviews) {
                            
                            if (textfield.tag >301 && textfield.tag < 307) [textfield setEnabled:YES];
                            else if (textfield.tag >101 && textfield.tag <108) [textfield setEnabled:NO];
                            else if (textfield.tag >201 && textfield.tag <208) [textfield setEnabled:NO];
                            else if (textfield.tag >401 && textfield.tag <408) [textfield setEnabled:NO];
                            else if (textfield.tag >501 && textfield.tag <508) [textfield setEnabled:NO];
                            else if (textfield.tag >601 && textfield.tag <608) [textfield setEnabled:NO];
                        }
                        for (UITextView *textview in self.scrollView.subviews) {
                            if (textview.tag != 0) {
                                if (textview.tag == 208) [textview setEditable:YES];
                                else if (textview.tag == 108)[textview setEditable:NO];
                                else if (textview.tag == 308)[textview setEditable:NO];
                                else if (textview.tag == 408)[textview setEditable:NO];
                                else if (textview.tag == 508)[textview setEditable:NO];
                                else if (textview.tag == 608)[textview setEditable:NO];
                            }
                        }
                    }
                }
            }
        }
    }
    //4
    else if (selectedIndex == 3) {
        
        _textField1 = (UITextField *)[self.scrollView viewWithTag:207];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield.tag != 0) {
                if (textfield.tag >= 301 && textfield.tag <= 306 ) {
                    if ([textfield.text isEqualToString:@""]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            _control.selectedSegmentIndex = 2;
                            _medNoSegment.selectedSegmentIndex = 2;
                            for (UITextField *textfield in self.scrollView.subviews) {
                                if (textfield.tag >301 && textfield.tag <307) [textfield setEnabled:YES];
                                else if (textfield.tag >401 && textfield.tag < 407) [textfield setEnabled:NO];
                            }
                        }];
                        [alert addAction:cancelBtn];
                        [self presentViewController:alert animated:true completion:nil];
                    } else {
                        
                        for (UITextField *textfield in self.scrollView.subviews) {
                            if (textfield.tag != 0) {
                                if (textfield.tag >401 && textfield.tag < 407) [textfield setEnabled:YES];
                                else if (textfield.tag >101 && textfield.tag <108) [textfield setEnabled:NO];
                                else if (textfield.tag >201 && textfield.tag <208) [textfield setEnabled:NO];
                                else if (textfield.tag >301 && textfield.tag <308) [textfield setEnabled:NO];
                                else if (textfield.tag >501 && textfield.tag <508) [textfield setEnabled:NO];
                                else if (textfield.tag >601 && textfield.tag <608) [textfield setEnabled:NO];
                            }
                        }
                        for (UITextView *textview in self.scrollView.subviews) {
                            if (textview.tag != 0) {
                                if (textview.tag == 408) [textview setEditable:YES];
                                else if (textview.tag == 108)[textview setEditable:NO];
                                else if (textview.tag == 208)[textview setEditable:NO];
                                else if (textview.tag == 308)[textview setEditable:NO];
                                else if (textview.tag == 508)[textview setEditable:NO];
                                else if (textview.tag == 608)[textview setEditable:NO];
                            }
                        }
                    }
                }
            }
        }
    }
    // 5
    else if (selectedIndex == 4) {
        
        _textField1 = (UITextField *)[self.scrollView viewWithTag:207];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield.tag != 0) {
                if (textfield.tag >= 401 && textfield.tag <= 406 ) {
                    if ([textfield.text isEqualToString:@""]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            _control.selectedSegmentIndex = 3;
                            _medNoSegment.selectedSegmentIndex = 3;
                            for (UITextField *textfield in self.scrollView.subviews) {
                                if (textfield.tag >401 && textfield.tag <407) [textfield setEnabled:YES];
                                else if (textfield.tag >501 && textfield.tag < 507) [textfield setEnabled:NO];
                            }
                        }];
                        [alert addAction:cancelBtn];
                        [self presentViewController:alert animated:true completion:nil];
                    } else {
                        
                        for (UITextField *textfield in self.scrollView.subviews) {
                            if (textfield.tag != 0) {
                                if (textfield.tag >501 && textfield.tag < 507) [textfield setEnabled:YES];
                                else if (textfield.tag >101 && textfield.tag <108) [textfield setEnabled:NO];
                                else if (textfield.tag >201 && textfield.tag <208) [textfield setEnabled:NO];
                                else if (textfield.tag >301 && textfield.tag <308) [textfield setEnabled:NO];
                                else if (textfield.tag >401 && textfield.tag <408) [textfield setEnabled:NO];
                                else if (textfield.tag >601 && textfield.tag <608) [textfield setEnabled:NO];
                            }
                        }
                        for (UITextView *textview in self.scrollView.subviews) {
                            if (textview.tag != 0) {
                                if (textview.tag == 508) [textview setEditable:YES];
                                else if (textview.tag == 108)[textview setEditable:NO];
                                else if (textview.tag == 208)[textview setEditable:NO];
                                else if (textview.tag == 308)[textview setEditable:NO];
                                else if (textview.tag == 408)[textview setEditable:NO];
                                else if (textview.tag == 608)[textview setEditable:NO];
                                
                            }
                        }
                    }
                }
            }
        }
    }
    // 6
    else if (selectedIndex == 5) {
        
        _textField1 = (UITextField *)[self.scrollView viewWithTag:207];
        _textField1.text = [NSString stringWithFormat:@"%.0f", [MediDataSingleton shareInstance].medTotalQuantity];
        
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield.tag != 0) {
                if (textfield.tag >= 501 && textfield.tag <= 506 ) {
                    if ([textfield.text isEqualToString:@""]) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            _control.selectedSegmentIndex = 4;
                            _medNoSegment.selectedSegmentIndex = 4;
                            for (UITextField *textfield in self.scrollView.subviews) {
                                if (textfield.tag >501 && textfield.tag <507) [textfield setEnabled:YES];
                                else if (textfield.tag >601 && textfield.tag < 607) [textfield setEnabled:NO];
                            }
                        }];
                        [alert addAction:cancelBtn];
                        [self presentViewController:alert animated:true completion:nil];
                    } else {
                        
                        for (UITextField *textfield in self.scrollView.subviews) {
                            if (textfield.tag != 0) {
                                if (textfield.tag >601 && textfield.tag < 607) [textfield setEnabled:YES];
                                else if (textfield.tag >101 && textfield.tag <108) [textfield setEnabled:NO];
                                else if (textfield.tag >201 && textfield.tag <208) [textfield setEnabled:NO];
                                else if (textfield.tag >301 && textfield.tag <308) [textfield setEnabled:NO];
                                else if (textfield.tag >401 && textfield.tag <408) [textfield setEnabled:NO];
                                else if (textfield.tag >501 && textfield.tag <508) [textfield setEnabled:NO];
                            }
                        }
                        for (UITextView *textview in self.scrollView.subviews) {
                            if (textview.tag != 0) {
                                if (textview.tag == 608) [textview setEditable:YES];
                                else if (textview.tag == 108)[textview setEditable:NO];
                                else if (textview.tag == 208)[textview setEditable:NO];
                                else if (textview.tag == 308)[textview setEditable:NO];
                                else if (textview.tag == 408)[textview setEditable:NO];
                                else if (textview.tag == 508)[textview setEditable:NO];
                            }
                        }
                    }
                }
            }
        }
    }
#endif
}

-(void)initTotalQuantity {
    
    [MediDataSingleton shareInstance].medFrequencyValue = 0;
    [MediDataSingleton shareInstance].medDaysValue = 0;
    [MediDataSingleton shareInstance].medTotalQuantity = 0;
}

-(void)didPressAddButtonFromTVC {

    if ([_control selectedSegmentIndex] == 0) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:101];

    } else if ([_control selectedSegmentIndex] == 1) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:201];

    } else if ([_control selectedSegmentIndex] == 2) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:301];

    } else if ([_control selectedSegmentIndex] == 3) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:401];

    } else if ([_control selectedSegmentIndex] == 4) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:501];

    } else if ([_control selectedSegmentIndex] == 5) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:601];

    }
    _medNameTF.text = [MediDataSingleton shareInstance].medName;
}

#pragma mark - create textfield, textview
-(void)createTextFieldWithNSArray:(NSArray *)array {
    
#define TEXTORIGINX 11
#define TEXTORIGINY 110
#define TFTAG 101;
    
    int ty = TEXTORIGINY;
    
    for (int a = 1; a<= 7; a++) {
        
        _textField1 = [[UITextField alloc] initWithFrame:CGRectMake(tx, ty, TEXTFIELDWIDTH -4, TEXTFIELDHEIGHT -4)];
        
        _textField1.tag = textfieldTAG;
        textfieldTAG += 1;
        [_textField1 setBorderStyle:UITextBorderStyleRoundedRect];
        
        [_textField1 setEnabled:NO];
        _textField1.delegate = self;
        
        [self.scrollView addSubview:_textField1];
        ty += 62;
    }
    
    _textView1 = [[UITextView alloc] initWithFrame:CGRectMake(tx, ty, TEXTFIELDWIDTH -4, TEXTVIEWHEIGHT)];
    _textView1.tag = textfieldTAG;
    _textView1.delegate = self;
    [self.scrollView addSubview:_textView1];
    [_textView1 setEditable:NO];
    
    if (textfieldTAG == 108) textfieldTAG = 201;
    else if (textfieldTAG == 208) textfieldTAG = 301;
    else if (textfieldTAG == 308) textfieldTAG = 401;
    else if (textfieldTAG == 408) textfieldTAG = 501;
    else if (textfieldTAG == 508) textfieldTAG = 601;
    else if (textfieldTAG == 608) textfieldTAG = 701;
    tx += 251;
    ty = TEXTORIGINY;
}

-(void)removeTextField:(NSInteger)section {
    if (section == 6) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 601 && textfiled.tag<= 607) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 608) [textview removeFromSuperview];
        }
    } else if (section == 5) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 501 && textfiled.tag<= 507) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 508) [textview removeFromSuperview];
        }
    } else if (section == 4) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 401 && textfiled.tag<= 407) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 408) [textview removeFromSuperview];
        }
    }
    else if (section == 3) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 301 && textfiled.tag<= 307) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 308) [textview removeFromSuperview];
        }
    }
    else if (section == 2) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 201 && textfiled.tag<= 207) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 208) [textview removeFromSuperview];
        }
    }
    else if (section == 1) {
        for (UITextField *textfiled in self.scrollView.subviews) {
            if (textfiled.tag >= 101 && textfiled.tag<= 107) {
                [textfiled removeFromSuperview];
            }
        }
        for (UITextView *textview in self.scrollView.subviews) {
            if (textview.tag == 108) [textview removeFromSuperview];
        }
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return YES;
}

-(void)examinateTextFieldIsEmpty {
    
    
}

-(NSString *)prescriptionAppendBySlash:(NSInteger)number {
    
    
    NSMutableString *string = [[NSMutableString alloc] init];
    UITextView *textView = [[UITextView alloc] init];
    UITextField *textfield = [[UITextField alloc] init];
    int t = 101;
    for (int i = 1; i <= number; i++) {
        for (int j = 1 ; j<= 8; j++) {
            
            if (t%100 >= 1 && t%100 <= 7) {
                textfield = (UITextField *)[self.scrollView viewWithTag:t];
                string = (NSMutableString *)[string stringByAppendingString:textfield.text];
                string = (NSMutableString *)[string stringByAppendingString:@"|"];
            } else if (t%100 == 8) {
                textView = (UITextView *)[self.scrollView viewWithTag:t];
                string = (NSMutableString *)[string stringByAppendingString:textView.text];
                string = (NSMutableString *)[string stringByAppendingString:@"|"];
            }
            t += 1;
        }
        string = (NSMutableString *)[string stringByAppendingString:@"*"];
        if (t == 109) t = 201;
        else if (t == 209) t = 301;
        else if (t == 309) t = 401;
        else if (t == 409) t = 501;
        else if (t == 509) t = 601;
        else if (t == 609) t = 701;
    }
    
    return string;
}

-(void)generateQRCode {
    
    QRCodeVC *qrcodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qrcode"];
    _popQRCode = [[UIPopoverController alloc] initWithContentViewController:qrcodeVC];
    [_popQRCode setDelegate:self];
    qrcodeVC.receiveImage = nil;
    
    CGRect rect;
    
    // examinate textfield segment 6
    NSInteger t = 0;
    NSInteger min = 0;
    NSInteger max = 0;
    NSInteger y = 0;
    
    for (UITextField *textfield in self.scrollView.subviews) {
        if (textfield.tag % 100 == 1) {
            if (![textfield.text isEqualToString:@""]) {
                y = textfield.tag;
                y -= 101;
                y = y / 100;
                
                t = y;;
                if (t == 0) {
                    min = 100 +1;
                    max = 100 +6;

                } else {
                    t += 1;
                    min = t * 100 +1;
                    max = t * 100 +6;
                }
//                for (UITextField *textfield in self.scrollView.subviews) {
                    if (textfield.tag >= min && textfield.tag <= max ) {
                        if ([textfield.text isEqualToString:@""]) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                _control.selectedSegmentIndex = t - 1;
                                _medNoSegment.selectedSegmentIndex = t - 1;
                            }];
                            
                            [alert addAction:cancelBtn];
                            [self presentViewController:alert animated:true completion:nil];
                            
                        } else {
                            
//                            NSLog(@"QRCODE: %@", [self prescriptionAppendBySlash:y]);
                            
                            CIFilter *fiter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
                            
                            NSLog(@"filterAttributes: %@", fiter.attributes);
                            
                            NSData *data = [[self prescriptionAppendBySlash:y + 1] dataUsingEncoding:NSUTF8StringEncoding];
                            NSLog(@"QRCODE2: %@", [self prescriptionAppendBySlash:y + 1 ]);
                            
                            [fiter setValue:data forKey:@"inputMessage"];
                            
                            CIImage *outputImage = [fiter outputImage];
                            
                            CIContext *context = [CIContext contextWithOptions:nil];
                            CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
                            
                            UIImage *image = [UIImage imageWithCGImage:cgImage scale:1. orientation:UIImageOrientationUp];
                            
                            // Resize without interpolating
                            UIImage *resized = [self resizeImage:image withQuality:kCGInterpolationNone rate:5.0];
                            
                            //    self.imageView.image = resized;

                            qrcodeVC.receiveImage = resized;
                            
                            rect = generateQRCodeBtn.frame;
                            rect.origin.x = CGRectGetMinX(generateQRCodeBtn.frame);
//                            buttonRect.origin.y = CGRectGetMinY(generateQRCodeBtn.frame);
                            rect.size.width = 2;
                            
                            
                            
                            CGImageRelease(cgImage);
                            
//                        }
                    }
                }
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing" message:@"Blank" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    _control.selectedSegmentIndex = t - 1;
                    _medNoSegment.selectedSegmentIndex = t - 1;
//                    for (UITextField *textfield in self.scrollView.subviews) {
                        if (textfield.tag > min && textfield.tag < max) [textfield setEnabled:YES];
//                    }
                }];
                
                [alert addAction:cancelBtn];
                [self presentViewController:alert animated:true completion:nil];
            }
        }
    }
    [_popQRCode presentPopoverFromRect:rect inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    /*
    if (_medNoSegment.selectedSegmentIndex == y) {
    }
    else {
        
        NSLog(@"QRCODE: %@", [self prescriptionAppendBySlash:6]);
        
        CIFilter *fiter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        NSLog(@"filterAttributes: %@", fiter.attributes);
        
        NSData *data = [[self prescriptionAppendBySlash:6] dataUsingEncoding:NSUTF8StringEncoding];
        [fiter setValue:data forKey:@"inputMessage"];
        
        CIImage *outputImage = [fiter outputImage];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *image = [UIImage imageWithCGImage:cgImage scale:1. orientation:UIImageOrientationUp];
        
        // Resize without interpolating
        UIImage *resized = [self resizeImage:image withQuality:kCGInterpolationNone rate:5.0];
        
        //    self.imageView.image = resized;
        
        CGImageRelease(cgImage);
        
        
        NSLog(@"QRCODE HERE...");
    }
     */
}

-(UIImage *)resizeImage:(UIImage *)image
            withQuality:(CGInterpolationQuality)quality
                   rate:(CGFloat)rate {
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetImageFromCurrentImageContext();
    
    return resized;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    NSArray *subViews = self.scrollView.subviews;
    
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[UITextField class]]) {
        } else if ([view isKindOfClass:[UIStepper class]]) {
        } else if ([view isKindOfClass:[UILabel class]]) {
        } else if ([view isKindOfClass:[UITextView class]]) {
        } else {
            [view removeFromSuperview];
        }
    }
    
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.scrollView];
        
        UIView *touchView = [[UIView alloc] init];
        [touchView setBackgroundColor:[UIColor lightGrayColor]];
        touchView.frame = CGRectMake(touchPoint.x, touchPoint.y, 30, 30);
        touchView.layer.cornerRadius = 15;
        [self.scrollView addSubview:touchView];
    }];
     */

}


/*
 -(UITextField *)defineTextField:(NSInteger)tag {
 
 _medNameTF = (UITextField *)[self.scrollView viewWithTag:tag];
 
 NSLog(@"%ld", _medNameTF.tag);
 return _medNameTF;
 }
 
 -(void) setTextFieldWhenClickedAdd:(UITextField *)sender {
 
 sender.text = [MediDataSingleton shareInstance].medName;
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
