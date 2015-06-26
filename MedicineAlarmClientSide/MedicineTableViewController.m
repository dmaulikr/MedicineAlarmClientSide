//
//  MedicineTableViewController.m
//  MedicineParse
//
//  Created by Stan Liu on 5/11/15.
//  Copyright (c) 2015 Stan Liu. All rights reserved.
//

#import "MedicineTableViewController.h"
#import "MedicineDetailTableViewController.h"
#import "AddMedicineTableViewController.h"
#import "ViewController.h"
#import "Medicine.h"
#import "MediDataBase.h"
#import "MBProgressHUD.h"
#import "DefineiOSVersion.h"
#import "MediDataSingleton.h"

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface MedicineTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UISearchResultsUpdating> {
    
    UIBarButtonItem *optionButton;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *addButton;
    CGRect cgRectLandscap;
    CGRect cgRectPortrait;
    BOOL scopeButtonPressedIndexNumber;
    NSNumber *lastNumber;
}


@property (retain, nonatomic) UIButton *homeButton;
@property (nonatomic) CGPoint homeBtnOriginPoint;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchResults;
// Scope button type
typedef NS_ENUM(NSInteger, UYLWorldFactsSearchScope)
{
    searchScopeEngName = 0,
    searchScopeScienceName = 1
};

@end

@implementation MedicineTableViewController

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

-(void)viewDidLoad {
    
    [super viewDidLoad];
    // no seperate search results controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame = CGRectMake(_searchController.searchBar.frame.origin.x, _searchController.searchBar.frame.origin.y, self.searchBar.frame.size.width, 44.0);
    
    // use table view controller to update the search results
    self.searchController.searchResultsUpdater = self;
    // do not want to dim the underlying content as we want to show the filtered results as the user types into searh bar
    self.searchController.dimsBackgroundDuringPresentation = NO;
    // UISearchController takes care of creating the search bar
    self.searchController.searchBar.scopeButtonTitles =
    @[NSLocalizedString(@"Merchadise Name", "英文商品名"),
      NSLocalizedString(@"Science Name",@"英文學名")];
    
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    self.searchController.delegate = self;

    self.searchResults = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePreferredContentSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    UIButton *optionViewbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [optionViewbtn addTarget:self action:@selector(optionActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [optionViewbtn setBackgroundImage:[UIImage imageNamed:@"Menu-50-2.png"] forState:UIControlStateNormal];
     
    optionButton = [[UIBarButtonItem alloc] initWithCustomView:optionViewbtn];
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddItemPage)];
    


    cgRectLandscap = CGRectMake(12, 710, 40, 40);
    cgRectPortrait = CGRectMake(12, 1024, 40, 40);
    
    // floating view
    CGRect tableBounds = self.tableView.bounds;
    
    if (!self.homeButton) {
        self.homeButton = [[UIButton alloc] initWithFrame:cgRectLandscap];
        [self.homeButton addTarget:self action:@selector(homeBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.homeButton setImage:[UIImage imageNamed:@"Home-50-2.png"] forState:UIControlStateNormal];
        CGSize homeBtnFrame = self.homeButton.frame.size;
        CGPoint homeBtnPint =
        CGPointMake(cgRectLandscap.origin.x, cgRectLandscap.origin.y);
        
        self.homeButton.frame = CGRectMake(homeBtnPint.x , homeBtnPint.y + tableBounds.origin.y , homeBtnFrame.width, homeBtnFrame.height);
        
        self.homeBtnOriginPoint = homeBtnPint;
        [self.view addSubview:self.homeButton];
    }

    
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = optionButton;
    // refresh table
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"refreshTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshParse:) name:@"refreshParse" object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // refresh data from parse
    [self loadObjects];
    [self.tableView reloadData];
}

-(void)viewDidUnload {
    
//    [self viewDidUnload];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTable" object:nil];
    [super viewDidUnload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGRect tableBounds = self.tableView.bounds;
    CGRect homeBtnFrame = self.homeButton.frame;
    self.homeButton.frame =
    CGRectMake(self.homeBtnOriginPoint.x, self.homeBtnOriginPoint.y + tableBounds.origin.y,
               homeBtnFrame.size.width, homeBtnFrame.size.height);
}

-(PFQuery *)queryForTable{
    
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    
    // If Pull To Refresh is enabled, query against the network by default.
    /*
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
     */
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    /*
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    */
    
    // load data from local ***the only way***
    [query fromLocalDatastore];
    [query orderByAscending:@"medMerEngName"];
    

    return query;
}
/*
-(void)orientationChanged:(NSNotification *)notification {
    
    UIDevice *device = [UIDevice currentDevice];
//    UIImage *image = [UIImage imageNamed:@"home_button.png"];
//    [_homeBtn setImage:image forState:UIControlStateNormal];
    CGRect tableBounds = self.tableView.bounds;
    CGSize homeBtnFrame = self.homeBtn.frame.size;
    
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            //
            NSLog(@"portrait");
            [_homeBtn removeFromSuperview];
            [self.view addSubview:_homeBtn];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            //
            [_homeBtn removeFromSuperview];
            [self.view addSubview:_homeBtn];
            break;
        case UIDeviceOrientationLandscapeLeft:
            //
            [_homeBtn removeFromSuperview];
            [self.view addSubview:_homeBtn];
            NSLog(@"landscapeleft");
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"landscaperight");
            [_homeBtn removeFromSuperview];
            [self.view addSubview:_homeBtn];
            break;
        default:
            break;
    }
}
*/
-(void)homeBtnPressed {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
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

#pragma mark - NavigationItem
// open a page for insert new item
- (void)showAddItemPage{
    AddMedicineTableViewController *amtvc = [self.storyboard instantiateViewControllerWithIdentifier:@"addEditItemRootTVC"];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [self.splitViewController showDetailViewController:amtvc sender:nil];
    } else if (UIDeviceOrientationIsPortrait(deviceOrientation)){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"增加資料時"
                                                        message:@"請保持裝置橫向" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
//    [addButton setEnabled:false];
}

// download from parse and pin it to PFObject
// set editing : NO
-(void)setTableUnediting {
    [self setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = optionButton;
}
-(void)syncFromParseAndLocal {
    
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];
    
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
// class method
+(void)downloadAnimation {
    
    MedicineTableViewController *mtvc = [[MedicineTableViewController alloc] init];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:mtvc.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        /*
         // customer MBProgressHUD view
         hud.mode = MBProgressHUDModeCustomView;
         hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Ironman head.png"]];
         hud.labelText = @"Downloading...";
         */
        [hud showAnimated:YES whileExecutingBlock:^{
            
            // Main download call
            [mtvc syncFromParseAndLocal];
            float progress = 0.0f;
            while (progress < 1.0f) {
                
                progress += 0.01f;
                hud.progress = progress;
                usleep(5000);
            }
        } completionBlock:^{

            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshParse" object:nil];
            }];
    
}

-(void)upload {
    //
}
// for ios8 AlertSheet of left barbuttonitem
-(void)optionActionSheet {
    
    if ([UIAlertController class]) {
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Options" message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self setEditing:YES animated:YES];
            
            self.navigationItem.leftBarButtonItem = doneButton;
        }];
        // upload to parse
        UIAlertAction *syncAction = [UIAlertAction actionWithTitle:@"Sync" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

            NSLog(@"%@",[[MediDataBase shareInstance] queryMedi]);
            [MedicineTableViewController downloadAnimation];
            //TODO:test
            [self syncFromParseAndLocal];
            [self.tableView reloadData];
            
        }];
        // delete all from local
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete All" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self deleteFromLocal];
        }];
        /*
        // only download
        UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"Download" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [MedicineTableViewController downloadAnimation];
        }];*/
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:editAction];
        [alertController addAction:deleteAction];
        [alertController addAction:syncAction];
        [alertController addAction:cancelAction];
        /*
        [alertController addAction:downloadAction];
        */
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        //
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sync" otherButtonTitles:@"Edit", @"Delete All", nil];
        
        [actionSheet showInView:self.view];
    }
}
// for ios7
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self.tableView reloadData];
            break;
            
        case 1:
            [self setEditing:YES animated:YES];
            self.navigationItem.leftBarButtonItem = doneButton;
            break;
            
        case 2:
            [self deleteFromLocal];
            break;
            
        default:
            break;
    }
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    [tableView bringSubviewToFront:self.homeButton];
    
    static NSString *simpleTableIdentifier = @"MedicineDBCell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    //TODO: UI and data ID
    //Configure the cell
    PFFile *thumbnail = [object objectForKey:@"medImageFile"];
    PFImageView *thumbnailImageView = (PFImageView *)[cell viewWithTag:100];
    thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    thumbnailImageView.file = thumbnail;
    [thumbnailImageView loadInBackground:^(UIImage *image, NSError *error){
        if (error == nil) {
//            NSLog(@"UIImage image: %@", image);
        } else {
            NSLog(@"loadInBackground Error: %@", error);
        }
    }progressBlock:^(int percentDone){
        
    }];
    
    UILabel *engNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *chiNameLabel = (UILabel *)[cell viewWithTag:102];
    
    // 三元運算 判別 原本資料跟搜尋後的資料
    
    object = (!self.searchController.active) ? self.objects[indexPath.row] : self.searchResults[indexPath.row];
    
        engNameLabel.text = [object objectForKey:@"medMerEngName"];
        chiNameLabel.text = [object objectForKey:@"medMerChiName"];
    
    [tableView bringSubviewToFront:self.homeButton];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // define objects or searchResult
    if (self.searchController.active) {
        
        return self.searchResults.count;
        
    } else {
        // get row number for next medId.
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        lastNumber = [formatter numberFromString:[NSString stringWithFormat:@"%lu", self.objects.count +1 ]];
        [MediDataSingleton shareInstance].lastNumber = lastNumber;
        
        return self.objects.count;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Remove the row from data model
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
            [self refreshParse:nil];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }

        }];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// segue to MedicineDetailViewController by code
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    Medicine *medicine = [[Medicine alloc] init];
    
    // convert medID(NSNumber) to NSString first
    medicine.medID = [NSString stringWithFormat:@"%@",[object objectForKey:@"medID"]];
    medicine.medImageFile = [object objectForKey:@"medImageFile"];
    //        medicine.medCode = [object objectForKey:@"MedCode"];
    
    medicine.medMerEngName = [object objectForKey:@"medMerEngName"];
    medicine.medMerChiName = [object objectForKey:@"medMerChiName"];
    medicine.medScienceName = [object objectForKey:@"medScienceName"];
    medicine.medCategory = [object objectForKey:@"medCategory"];
    
    medicine.medIngredient = [object objectForKey:@"medIngredient"];
    medicine.medUsage = [object objectForKey:@"medUsage"];
    medicine.medAdaptation = [object objectForKey:@"medAdaptation"];
    medicine.medSideEffect = [object objectForKey:@"medSideEffect"];
    medicine.medNotice = [object objectForKey:@"medNotice"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        //TODO: here need to be edited
//        UISplitViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailTableViewRootVC"];
        UINavigationController *unc = [self.storyboard instantiateViewControllerWithIdentifier:@"detailTableViewRootVC"];
        // TODO: splitviewcontroller for ios 7 test
        NSArray *nc = @[self.splitViewController.viewControllers[0],unc];
        self.splitViewController.viewControllers = nc;
        
        // segue to rootvc of MedicineDetailViewController
        
        MedicineDetailTableViewController *detailTableVC = (MedicineDetailTableViewController *)[unc topViewController];
        
        //    mdvc.mediDetail = medicine;
        detailTableVC.mediDetail = medicine;
        detailTableVC.receiveObjectId = object.objectId;
        // TODO: check dismiss 1
        [self.splitViewController showDetailViewController:unc sender:self];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        //
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailTableViewRootVC"];
        
        MedicineDetailTableViewController *detailTableVC = (MedicineDetailTableViewController *)[navigationController topViewController];
        
        // segue to rootvc of MedicineDetailViewController
        detailTableVC.mediDetail = medicine;
        detailTableVC.receiveObjectId = object.objectId;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fromMedicineTableView" object:nil];
        // TODO: check dismiss 1
        [self.splitViewController showDetailViewController:navigationController sender:self];
    }
    

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
    NSLog(@"objectDidLoadError: %@", [error localizedDescription]);
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

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}


-(void)didChangePreferredContentSize:(NSNotification *)notification {
    
    [self.tableView reloadData];
}

#pragma mark - UISearchResultUpdating
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString =[searchController.searchBar text];
    // need to declare typedef NS_ENUM to identify the selectedScopeButtonIndex
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];

}

- (void)searchForText:(NSString *)searchText scope:(UYLWorldFactsSearchScope)scopeOption
{
    [self.searchResults removeAllObjects];

    NSPredicate *predicate;
    
    PFQuery *query = [self queryForTable];
    
    NSMutableArray *results = (NSMutableArray *)[query findObjects];
    
    if ([searchText  isEqualToString: @""]) {
        
        //...
        
    } else {
        
        if (scopeOption == searchScopeEngName) {
            
            predicate = [NSPredicate predicateWithFormat:@"(medMerEngName CONTAINS[cd] %@)", searchText];
            
        } else if (scopeOption == searchScopeScienceName) {
            
            predicate = [NSPredicate predicateWithFormat:@"(medScienceName CONTAINS[cd] %@)", searchText];
        }
        results = (NSMutableArray *)[results filteredArrayUsingPredicate:predicate];
    }
    
    NSLog(@"%@", results);
    NSLog(@"%lu", (unsigned long)[results count]);
    
    [self.searchResults addObjectsFromArray:results];
    
    NSError *error = nil;
    
    if (error)
    {
        NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
    }
}

#pragma mark - implement searchbar by my will
#warning TODO: delete if no needed
-(NSArray *)filterResults:(NSString *)searchTerm {
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:medicineClassName];

    [query whereKeyExists:@"medMerEngName"];
    [query whereKeyExists:@"medMerChiName"];
    [query whereKeyExists:@"medScienceName"];
    [query whereKey:@"medMerEngName" containsString:searchTerm];
    
    NSArray *results = [query findObjects];
    
    NSLog(@"%@", results);
    NSLog(@"%lu", (unsigned long)[results count]);
    
    
    [self.searchResults addObjectsFromArray:results];
    
    return self.searchResults;
}


#pragma mark- UISearchBarDelegate Methods

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setText:nil];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSString *query = searchBar.text;
    
    if ([query length]== 0) {
        
        
        
    } else {
        
        
    }
    
    [self.tableView reloadData];
}






@end
