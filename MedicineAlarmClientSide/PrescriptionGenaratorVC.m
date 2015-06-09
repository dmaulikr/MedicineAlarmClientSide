//
//  PrescriptionGenaratorVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/2/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PrescriptionGenaratorVC.h"

#import "PopDosageVC.h"
#import "Medicine.h"

#import "MediDataSingleton.h"


#define TEXTFIELDWIDTH 250
#define TEXTFIELDHEIGHT 30
#define TEXTVIEWHEIGHT 80

@interface PrescriptionGenaratorVC () <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIStepper *medQuantityStepper;
@property (retain, nonatomic) IBOutlet UILabel *stepLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *medNoSegment;

@property (retain, nonatomic) UISegmentedControl * control;

@property (retain, nonatomic) UITextField *textField1;

@property (retain, nonatomic) UITextField *medNameTF;

@property (retain, nonatomic) UITextView *textView1;
/*
@property (weak, nonatomic) UITextField *medName1;
@property (weak, nonatomic) UITextField *medName2;

@property (weak, nonatomic) UITextField *medName3;
@property (weak, nonatomic) UITextField *medName4;
@property (weak, nonatomic) UITextField *medName5;
@property (weak, nonatomic) UITextField *medName6;

@property (weak, nonatomic) UITextField *dosage1;
@property (weak, nonatomic) UITextField *dosage2;
@property (weak, nonatomic) UITextField *dosage3;
@property (weak, nonatomic) UITextField *dosage4;
@property (weak, nonatomic) UITextField *dosage5;
@property (weak, nonatomic) UITextField *dosage6;

@property (weak, nonatomic) UITextField *quantity1;
@property (weak, nonatomic) UITextField *quantity2;
@property (weak, nonatomic) UITextField *quantity3;
@property (weak, nonatomic) UITextField *quantity4;
@property (weak, nonatomic) UITextField *quantity5;
@property (weak, nonatomic) UITextField *quantity6;

@property (weak, nonatomic) UITextField *days1;
@property (weak, nonatomic) UITextField *days2;
@property (weak, nonatomic) UITextField *days3;
@property (weak, nonatomic) UITextField *days4;
@property (weak, nonatomic) UITextField *days5;
@property (weak, nonatomic) UITextField *days6;

@property (weak, nonatomic) UITextField *howtouse1;
@property (weak, nonatomic) UITextField *howtouse2;
@property (weak, nonatomic) UITextField *howtouse3;
@property (weak, nonatomic) UITextField *howtouse4;
@property (weak, nonatomic) UITextField *howtouse5;
@property (weak, nonatomic) UITextField *howtouse6;

@property (weak, nonatomic) UITextField *frequency1;
@property (weak, nonatomic) UITextField *frequency2;
@property (weak, nonatomic) UITextField *frequency3;
@property (weak, nonatomic) UITextField *frequency4;
@property (weak, nonatomic) UITextField *frequency5;
@property (weak, nonatomic) UITextField *frequency6;

@property (weak, nonatomic) UITextField *meal1;
@property (weak, nonatomic) UITextField *meal2;
@property (weak, nonatomic) UITextField *meal3;
@property (weak, nonatomic) UITextField *meal4;
@property (weak, nonatomic) UITextField *meal5;
@property (weak, nonatomic) UITextField *meal6;

@property (weak, nonatomic) UITextView *note1;
@property (weak, nonatomic) UITextView *note2;
@property (weak, nonatomic) UITextView *note3;
@property (weak, nonatomic) UITextView *note4;
@property (weak, nonatomic) UITextView *note5;
@property (weak, nonatomic) UITextView *note6;
*/
@end

@implementation PrescriptionGenaratorVC {
    int tx;
    int textfieldTAG;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self.scrollView setDelegate:self];
    [self.scrollView setScrollEnabled:YES];
    
    CGFloat width, height;
    width = self.scrollView.frame.size.width;
    height = self.scrollView.frame.size.height;
    [self.scrollView setContentSize:CGSizeMake(width * 4, height)];
    
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
    [_stepLabel setBackgroundColor:[UIColor grayColor]];
    
    /*
    NSArray *arrayObject = @[@"1"];
    _medNoSegment = [[UISegmentedControl alloc] initWithItems:arrayObject];
    _medNoSegment.frame = CGRectMake(10, 60, TEXTFIELDWIDTH, _medNoSegment.frame.size.height);
    
    [self.scrollView addSubview:_medNoSegment];
     */
    
    [self.scrollView addSubview:_medQuantityStepper];
    [self.scrollView addSubview:_stepLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressAddButtonFromTVC) name:@"add" object:nil];
    
    
    tx = 11;
    textfieldTAG = 101;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - stepper
-(void)didStepperClicked:(UIStepper *)sender {
//    _medNoSegment = nil;
//    [_medNoSegment removeFromSuperview];
    
    
    _stepLabel.text = [NSString stringWithFormat:@"%0.f", _medQuantityStepper.value];
    NSArray *arr = @[@"",@"1",@"2",@"3",@"4",@"5",@"6"];
    NSMutableArray *mArr = [[NSMutableArray alloc] init];
    int a;
    for (int i = 1 ; i <= _medQuantityStepper.value ; i++) {
        
        [mArr insertObject:[arr objectAtIndex:i] atIndex:i-1];
        
            NSLog(@"%lu",(unsigned long)[_medNoSegment numberOfSegments]);
        a = i;
    }
    [_medNoSegment removeFromSuperview];
    _medNoSegment = [[UISegmentedControl alloc] initWithItems:mArr];
    _medNoSegment.frame = CGRectMake(10, 60, TEXTFIELDWIDTH * a, _medNoSegment.frame.size.height);
    [_medNoSegment addTarget:self action:@selector(medNoSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:_medNoSegment];

    [self createTextFieldWithNSArray:nil];
    
    if (sender.value == 6) {
        [_medQuantityStepper setEnabled:NO];
        [_medQuantityStepper setExclusiveTouch:NO];
        [_medQuantityStepper setUserInteractionEnabled:NO];

    }
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSLog(@"%ld", textField.tag);
#if 0
    
    PopDosageVC *dosageVC = [[PopDosageVC alloc] init];
    UIPopoverController *popDosage = [[UIPopoverController alloc] initWithContentViewController:dosageVC];
    [popDosage setDelegate:self];
    if (textField.tag/100 == 1) {
        NSLog(@"%@", textField.description);
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(textField.frame.origin.x-130, textField.frame.origin.y -120, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else if (textField.tag/200 == 1) {
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(textField.frame.origin.x-130, textField.frame.origin.y -120, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else if (textField.tag/300 == 1) {
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(450, 100, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (textField.tag/400 == 1) {
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(650, 100, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (textField.tag/500 == 1) {
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(850, 100, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (textField.tag/600 == 1) {
        [textField setBackgroundColor:[UIColor yellowColor]];
        [popDosage presentPopoverFromRect:CGRectMake(1000, 100, 200, 200) inView:self.scrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
#else
    
    
    
#endif
    return YES;
}

-(IBAction)medNoSegmentChanged:(id)segment {
    
    _control = segment;
    int selectedIndex = (int)[_control selectedSegmentIndex];
    
#if 1
    // 1
    if (selectedIndex == 0) {
        int i = 0;
        for (UITextField *textfield in self.scrollView.subviews) {
            i += 1;
            _textField1 = textfield;
            
            if (_textField1.tag >101 && _textField1.tag < 107) {
                
                [_textField1 setEnabled:YES];
            } else if (_textField1.tag >108 && _textField1.tag <608){
                [_textField1 setEnabled:NO];
            }
        }
        _textView1 = (UITextView *)[self.scrollView viewWithTag:108];
        [_textView1 setEditable:YES];
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:101];

    }
    // 2
    if (selectedIndex == 1) {
        for (UITextField *textfield in self.scrollView.subviews) {
            _textField1 = textfield;
            if (_textField1.tag > 201 && _textField1.tag < 207) {
                [_textField1 setEnabled:YES];
            } else if (_textField1.tag < 202 && _textField1.tag > 301){
                [_textField1 setEnabled:NO];
            }
        }
        _textView1 = (UITextView *)[self.scrollView viewWithTag:208];
        [_textView1 setEditable:YES];
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:101];
    }

    //3
    else if (selectedIndex == 2) {
        for (UITextField *textfield in self.scrollView.subviews) {
            if (textfield.tag > 301 &&textfield.tag < 307) {
                [textfield setEnabled:YES];
            } else if (textfield.tag < 302 && textfield.tag > 401) [textfield setEnabled:NO];
        }/*
        for (UITextView *textView in self.scrollView.subviews) {
            if (textView.tag == 308) {
                [textView setEditable:YES];
            } else [textView setEditable:NO];
        }*/
        
    }
    //4
    else if (selectedIndex == 3) {
        for (UITextField *textfield in self.scrollView.subviews) {
            
            if (textfield.tag > 401 && textfield.tag < 407) {
                [textfield setEnabled:YES];
            } else if (textfield.tag < 402 && textfield.tag > 501) [textfield setEnabled:NO];
        }/*
        for (UITextView *textView in self.scrollView.subviews) {
            if (textView.tag == 408) {
                [textView setEditable:YES];
            } else [textView setEditable:NO];
        }*/
    }
    // 5
    else if (selectedIndex == 4) {
        for (UITextField *textfield in self.scrollView.subviews) {
            
            if (textfield.tag > 501 && textfield.tag < 507) {
                [textfield setEnabled:YES];
            } else if (textfield.tag < 502 && textfield.tag > 601)[textfield setEnabled:NO];
        }/*
        for (UITextView *textView in self.scrollView.subviews) {
            if (textView.tag == 508) {
                [textView setEditable:YES];
            } else [textView setEditable:NO];
        }*/
    }
    // 6
    else if (selectedIndex == 5) {
        for (UITextField *textfield in self.scrollView.subviews) {
            
            if (textfield.tag > 601 && textfield.tag < 607) {
                [textfield setEnabled:YES];
            } else if (textfield.tag > 102 && textfield.tag < 601) [textfield setEnabled:NO];
        }/*
        for (UITextView *textView in self.scrollView.subviews) {
            if (textView.tag == 608) {
                [textView setEditable:YES];
            } else [textView setEditable:NO];
        }*/
    }
#else
    
#endif
}

-(void)didPressAddButtonFromTVC {

    if ([_control selectedSegmentIndex] == 0) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:101];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    } else if ([_control selectedSegmentIndex] == 1) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:201];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    } else if ([_control selectedSegmentIndex] == 2) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:301];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    } else if ([_control selectedSegmentIndex] == 3) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:401];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    } else if ([_control selectedSegmentIndex] == 4) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:501];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    } else if ([_control selectedSegmentIndex] == 5) {
        _medNameTF = (UITextField *)[self.scrollView viewWithTag:601];
        _medNameTF.text = [MediDataSingleton shareInstance].medName;
    }

}


-(UITextField *)defineTextField:(NSInteger)tag {
    
    _medNameTF = (UITextField *)[self.scrollView viewWithTag:tag];
    
    NSLog(@"%ld", _medNameTF.tag);
    return _medNameTF;
}

-(void) setTextFieldWhenClickedAdd:(UITextField *)sender {
    
    sender.text = [MediDataSingleton shareInstance].medName;
}


-(void)createSegment {
    
    
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

-(void)removeTextField {
    
    for (UITextField *textfield in self.scrollView.subviews) {
        if (textfield.tag != 0) {
            _textField1 = (UITextField *)[self.scrollView viewWithTag:textfield.tag];
            NSLog(@"remove: %ld", _textField1.tag);
            [_textField1 removeFromSuperview];
        }
    }
    
    for (UITextView *view in self.scrollView.subviews) {
        if (view.tag != 0) {
            _textView1 = (UITextView *)[self.scrollView viewWithTag:view.tag];
            NSLog(@"remove: %ld", _textField1.tag);
            [_textView1 removeFromSuperview];
        }
    }
    
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (textView.tag == 108) {
        [textView setBackgroundColor:[UIColor greenColor]];
    } else if (textView.tag == 208) {
        [textView setBackgroundColor:[UIColor redColor]];
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *subViews = [self.scrollView subviews];
    
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
