//
//  PrescriptionGeneratorTVC.m
//  MedicineAlarmClientSide
//
//  Created by Stan Liu on 6/2/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "PrescriptionGeneratorTVC.h"
#import "Medicine.h"
#import "MBProgressHUD.h"
#import "MediDataBase.h"
#import "PrescriptionCell.h"
#import "PrescriptionGenaratorVC.h"

#import "MediDataSingleton.h"

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface PrescriptionGeneratorTVC () {
    
    CGRect cgRectLandscap;
    CGRect cgRectPortrait;
}

@property (retain, nonatomic) UIButton *homeButton;
@property (nonatomic) CGPoint homeBtnOriginPoint;

@end

@implementation PrescriptionGeneratorTVC

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = medicineClassName;
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"medMerEngName";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        // The number of objects to show per page
        //self.objectsPerPage = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    cgRectLandscap = CGRectMake(12, 710, 40, 40);
    cgRectPortrait = CGRectMake(12, 1024, 40, 40);
    
    // floating view
    CGRect tableBounds = self.tableView.bounds;
    
    if (!self.homeButton) {
        self.homeButton = [[UIButton alloc] initWithFrame:cgRectLandscap];
        [self.homeButton addTarget:self action:@selector(homeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.homeButton setImage:[UIImage imageNamed:@"home_button.png"] forState:UIControlStateNormal];
        CGSize homeBtnFrame = self.homeButton.frame.size;
        CGPoint homeBtnPint =
        CGPointMake(cgRectLandscap.origin.x, cgRectLandscap.origin.y);
        
        self.homeButton.frame = CGRectMake(homeBtnPint.x , homeBtnPint.y + tableBounds.origin.y , homeBtnFrame.width, homeBtnFrame.height);
        
        self.homeBtnOriginPoint = homeBtnPint;
        [self.view addSubview:self.homeButton];
    }

    
    // refresh data from parse
    [self loadObjects];
    [self.tableView reloadData];
}

-(void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
    
    return query;
}


-(void)homeBtnPressed {
    
    UIDeviceOrientation deviceOrientation  = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        //
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
        
    } else {
        
        [self.splitViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect tableBounds = self.tableView.bounds;
    CGRect homeBtnFrame = self.homeButton.frame;
    self.homeButton.frame =
    CGRectMake(self.homeBtnOriginPoint.x, self.homeBtnOriginPoint.y + tableBounds.origin.y,
               homeBtnFrame.size.width, homeBtnFrame.size.height);
}

- (void)didClickOnCellAtIndex:(NSInteger)cellIndex withData:(id)data {
    
    [MediDataSingleton shareInstance].medName = data;
    // Do additional actions as required.
    NSLog(@"Cell at Index: %ld clicked.\n Data received : %@", (long)cellIndex, data);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"add" object:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(nullable PFObject *)object {
    
    static NSString *simpleTableIdentifier = @"PrescriptionCell";
    static NSString *two = @"preCells";
    
//    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    PrescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"preCells" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[PrescriptionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:two];

    }
    
    // Configure the cell...
    /*
    cell.textLabel.text = [object objectForKey:@"medMerEngName"];
    cell.detailTextLabel.text = [object objectForKey:@"medMerChiName"];
     */
    
    cell.delegate = self;
    cell.cellIndex = indexPath.row;
    
    /*
    UILabel *medMerEngLB = (UILabel *)[cell viewWithTag:301];
    medMerEngLB.text = [object objectForKey:@"medMerEngName"];
    UILabel *medMerChiLB = (UILabel *)[cell viewWithTag:302];
    medMerChiLB.text = [object objectForKey:@"medMerChiName"];
    */
    
    cell.medMerEngLabel.text = [object objectForKey:@"medMerEngName"];
    cell.medMerChiLabel.text = [object objectForKey:@"medMerChiName"];
    cell.medScienceLabel.text = [object objectForKey:@"medScienceName"];
    cell.medCategoryLabel.text = [object objectForKey:@"medCategory"];
    
    return cell;
}
/*
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}
*/
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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
