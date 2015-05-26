//
//  MedicineTableViewController.m
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MedicineTableViewController.h"
#import "MedicineDetailViewController.h"
#import "MedicineDetailTableViewController.h"
#import "AddMedicineViewController.h"
#import "Medicine.h"
#import "MediDataBase.h"
#import "MBProgressHUD.h"

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface MedicineTableViewController () <UISearchBarDelegate> {
    
    NSMutableArray *meds;
    PFObject *obj;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *doneButton;
}

@end

@implementation MedicineTableViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"MedicineMerchadiseName";
        
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

-(void)viewDidLoad {
    
    [super viewDidLoad];
    // add barbuttonitem
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddItemPage)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(setTableUnediting)];
     refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionActionSheet)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = refreshButton;
    // refresh table
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"refreshTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshParse:) name:@"refreshParse" object:nil];
    // refresh data from parse
    [self loadObjects];
}

-(void)viewDidUnload {
    
    [self viewDidUnload];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTable" object:nil];
}

-(BOOL)shouldAutorotate {
    
    return NO;
}

-(PFQuery *)queryForTable{
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
//    if ([self.objects count] == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    } else {
//    }
    // load data from local
    [query fromLocalDatastore];
    [query orderByAscending:@"medID"];

//    [query getFirstObjectInBackground];

    return query;
}

#pragma mark - NavigationItem
// open a page for insert new item
- (void)showAddItemPage{
    
     AddMedicineViewController *amvc = [self.storyboard instantiateViewControllerWithIdentifier:@"addEditItemRootVC"];
     
     [self.splitViewController showDetailViewController:amvc sender:nil];
}

// download from parse and pin it to PFObject
// set editing : NO
-(void)setTableUnediting {
    [self setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = refreshButton;
}
-(void)syncFromParseAndLocal {
    
    PFQuery *query = [PFQuery queryWithClassName:@"MedicineMerchadiseName"];
    
    NSArray *array = [query findObjects];
    //
    //    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
    //        NSLog(@"DownloadPFObject:%@", [object objectForKey:@"medScienceName"]);
    //    }];
    
    // Store in local datestore by pinning it
    [PFObject pinAllInBackground:array];
    
    [query whereKeyExists:@"medID"];
    [query fromLocalDatastore];
    [self loadObjects];
    
}
-(void)download {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    /*
     // customer MBProgressHUD view
     hud.mode = MBProgressHUDModeCustomView;
     hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ironman head.png"]];
     hud.labelText = @"Downloading...";
     */
    [hud showAnimated:YES whileExecutingBlock:^{
        
        // Main download call
        [self syncFromParseAndLocal];
        float progress = 0.0f;
        while (progress < 1.0f) {
            
            progress += 0.01f;
            hud.progress = progress;
            usleep(5000);
        }
    } completionBlock:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshParse" object:nil];
        /*
         UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Download Successfully" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         [view show];
         */
    }];
}

-(void)upload {
    //
}
// AlertSheet of left barbuttonitem
-(void)optionActionSheet {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"Options" message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self setEditing:YES animated:YES];

        self.navigationItem.leftBarButtonItem = doneButton;
    }];
    // upload to parse
    UIAlertAction *syncAction = [UIAlertAction actionWithTitle:@"Sync" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        //TODO:test
        [self.tableView reloadData];
        
    }];
    // delete all from local
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self deleteFromLocal];
    }];
    // only download
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self download];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:editAction];
    [alertController addAction:deleteAction];
    [alertController addAction:syncAction];
    [alertController addAction:cancelAction];
    [alertController addAction:downloadAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)deleteFromLocal {
    /*
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
    NSArray *array = [query findObjects];
    [PFObject unpinAll:array];
     */
    [PFObject unpinAllObjectsInBackgroundWithBlock:^(BOOL successed, NSError *error){
        if (successed == YES) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"Delete Successfully";
            [hud hide:YES afterDelay:0.5f];
        } else NSLog(@"unpinAll Error:%@", error);
    }];
    
    [self syncFromParseAndLocal];
}

#pragma mark - tableview
// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *simpleTableIdentifier = @"MedicineCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    //TODO: UI and data ID
    // Configure the cell
//    PFFile *thumbnail = [object objectForKey:@"medImage"];
//    PFImageView *thumbnailImageView = (PFImageView *)[cell viewWithTag:100];
//    thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
//    thumbnailImageView.file = thumbnail;
//    [thumbnailImageView loadInBackground];
    
    UILabel *engNameLabel = (UILabel *)[cell viewWithTag:101];
    engNameLabel.text = [object objectForKey:@"medMerEngName"];
//    engNameLabel.text = [[self refreshFromParse] objectAtIndex:1];
//    engNameLabel.text = meds[@"medMerEngName"];
//    engNameLabel.text = [meds objectAtIndex:indexPath.row];
    
    UILabel *chiNameLabel = (UILabel *)[cell viewWithTag:102];
    chiNameLabel.text = [object objectForKey:@"medMerChiName"];
//    chiNameLabel.text = [[[self refreshFromParse] objectAtIndex:indexPath.row] objectForKey:@"medMerChiName"];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Remove the row from data model
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self refreshTable:nil];
        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// segue to MedicineDetailViewController by code
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // no need
//    MedicineDetailViewController *mdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailViewVC"];
    
    UINavigationController *unc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailTableViewRootVC"];
    // segue to rootvc of MedicineDetailViewController
    
    MedicineDetailTableViewController *detailTableVC = (MedicineDetailTableViewController *)[unc topViewController];
    MedicineDetailViewController *detailVC = (MedicineDetailViewController *)[unc topViewController];
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    NSLog(@"objectid: %@", object.objectId);
    
    Medicine *medicine = [[Medicine alloc] init];
    
    // convert medID(NSNumber) to NSString first
    medicine.medID = [NSString stringWithFormat:@"%@",[object objectForKey:@"medID"]];
    medicine.medImage = [object objectForKey:@"medImage"];
    //        medicine.medCode = [object objectForKey:@"MedCode"];
    
    medicine.medMerEngName = [object objectForKey:@"medMerEngName"];
    medicine.medMerChiName = [object objectForKey:@"medMerChiName"];
    medicine.medScienceName = [object objectForKey:@"medScienceName"];
    medicine.medCategory = [object objectForKey:@"medCategory"];
    
    medicine.medIngredient = [object objectForKey:@"medIngredient"];
    medicine.medUsage = [object objectForKey:@"medUsage"];
    medicine.medSideEffect = [object objectForKey:@"medSideEffect"];
    medicine.medNotice = [object objectForKey:@"medNotice"];
    
    detailVC.title = [object objectForKey:@"medMerEngName"];
//    mdvc.mediDetail = medicine;
//    detailVC.mediDetail = medicine;
    // TODO: check dismiss 1
//    [self.splitViewController showDetailViewController:unc sender:self];
    
    //    mdvc.mediDetail = medicine;
    detailTableVC.mediDetail = medicine;
    detailTableVC.receiveObjectId = object.objectId;
    // TODO: check dismiss 1
    [self.splitViewController showDetailViewController:unc sender:self];
}

-(void)refreshTable:(NSNotification *)notification {
    // only refresh tableview
    [self.tableView reloadData];
}

-(void)refreshParse:(NSNotification *)notification {
    
    // Reload the Medicines
    [self loadObjects];
    [self.tableView reloadData];
}

-(void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"error: %@", [error localizedDescription]);
}

#pragma mark - Segue by storyboard
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//
//    if ([segue.identifier isEqualToString:@"showMedicineDetail"]) {
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        
//        PFObject *object = [self.objects objectAtIndex:indexPath.row];
//        
//        Medicine *medicine = [[Medicine alloc] init];
//        
//        MedicineDetailViewController *medDetailViewController = (MedicineDetailViewController *)[segue.destinationViewController topViewController];
////
//        // convert medID(NSNumber) to NSString first
//        medicine.medID = [NSString stringWithFormat:@"%@",[object objectForKey:@"medID"]];
//        medicine.medImage = [object objectForKey:@"medImage"];
////        medicine.medCode = [object objectForKey:@"MedCode"];
//
//        medicine.medMerEngName = [object objectForKey:@"medMerEngName"];
//        medicine.medMerChiName = [object objectForKey:@"medMerChiName"];
//        medicine.medScienceName = [object objectForKey:@"medScienceName"];
//        medicine.medCategory = [object objectForKey:@"medCategory"];
//        
//        medicine.medIngredient = [object objectForKey:@"medIngredient"];
//        medicine.medUsage = [object objectForKey:@"medUsage"];
//        medicine.medSideEffect = [object objectForKey:@"medSideEffect"];
//        medicine.medNotice = [object objectForKey:@"medNotice"];
//        
//
//        NSLog(@"*****medicine******: %@", medicine.medID);
//
//        medDetailViewController.mediDetail = medicine;
//        
//    }
//}






@end
