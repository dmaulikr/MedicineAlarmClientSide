//
//  ViewController.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 5/18/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "ViewController.h"
#import "MedicineTableViewController.h"
#import "MedicineDetailTableViewController.h"

@interface ViewController ()<UITextViewDelegate> {

}

//@property (nonatomic, retain) UIView *viewTable;
//@property (nonatomic, retain) UIView *viewForm;

//@property (nonatomic, retain) UIButton *chatButton;
@property (strong, nonatomic) IBOutlet UITextView *chatBox;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *generateDescriptionBtn;
@property (strong, nonatomic) IBOutlet UIButton *medicineDataBaseBtn;
@property (strong, nonatomic) IBOutlet UIButton *readMeBtn;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageBtn;

@property (retain, nonatomic) IBOutlet UIToolbar *testToolBar;
@property (retain, nonatomic) IBOutlet UIInputView *inputView;
@property (retain, nonatomic) IBOutlet UIPickerView *textPickerView;

@end

@implementation ViewController

-(void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set notification when keyboard shows/hides
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    
//    // set notification for when a key is pressed
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyPressed:) name:UITextViewTextDidChangeNotification object:nil];
//    
//    UITapGestureRecognizer *resignGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
//    UITapGestureRecognizer *begunEditGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardShow)];
//    
//    [self.view addGestureRecognizer:resignGesture];
//    [self.chatBox addGestureRecognizer:begunEditGesture];
//    [self.containerView addSubview:_chatBox];
    self.chatBox.delegate = self;

    
#define BUTTONRADIUS 10;
    _sendMessageBtn.layer.cornerRadius = BUTTONRADIUS;
    _sendMessageBtn.clipsToBounds = YES;
    
    _generateDescriptionBtn.layer.cornerRadius = BUTTONRADIUS;
    _generateDescriptionBtn.clipsToBounds = YES;
    
    _medicineDataBaseBtn.layer.cornerRadius = BUTTONRADIUS;
    _generateDescriptionBtn.clipsToBounds = YES;
    
    _readMeBtn.layer.cornerRadius = BUTTONRADIUS;
    _readMeBtn.clipsToBounds = YES;
    
}
/*
-(void)test {
    // create a uitoolbar
    self.testToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 367, 320, 44)];
    // cretae a pickerview
    self.textPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 367, 320, 216)];
    // picker insert to textView's keyboard
    [self.chatBox setInputView:self.textPickerView];
    
    self.chatBox.inputAccessoryView = self.testToolBar;
    
    UIBarButtonItem *barBtnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnCancelIsClicked)];
    UIBarButtonItem *barBtnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonItemStyleDone target:self action:@selector(barBtnDoneIsClicked)];
    
    self.testToolBar.items = @[barBtnCancel, barBtnDone];
    
    self.textPickerView.delegate = self;
    self.textPickerView.dataSource = self;
}
 */

-(void)keyboardShow {
    
    [self.chatBox becomeFirstResponder];
}

-(void)keyboardHide
{
    [self.chatBox resignFirstResponder];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)notification{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
    

}

-(void) keyboardWillHide:(NSNotification *)notification{
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.containerView.frame = containerFrame;

    // commit animations
    [UIView commitAnimations];
    
}

-(void)keyPressed:(NSNotification *)notification {
    //
    
    NSLog(@"keypressed");
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 1;
}


- (void)growingTextView:(UITextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.containerView.frame = r;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.chatBox resignFirstResponder];
//        [PFPush sendPushMessageToChannelInBackground:@"MedicalClinic" withMessage:@"Hello World!"];
        PFPush *push = [[PFPush alloc] init];
        PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"channels" equalTo:@"MedicalPersonal"];
        [push setQuery:pushQuery];
        [push setMessage:[NSString stringWithFormat:@"%@", self.chatBox.text]];
        [push sendPushInBackground];
        self.chatBox.text = @"";

        return NO;
    }
    return YES;
}




@end
