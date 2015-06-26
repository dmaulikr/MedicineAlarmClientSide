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

#import "PrescriptionGenaratorVC.h"
#import "DefineiOSVersion.h"
#import "PrescriptionGenaratorVC.h"

#import "MediDataSingleton.h"

static NSString *medicineClassName = @"MedicineMerchadiseName";

@interface PrescriptionGeneratorTVC () {
    
    CGRect cgRectLandscap;
    CGRect cgRectPortrait;
}

@property (retain, nonatomic) UIButton *homeButton;
@property (nonatomic) CGPoint homeBtnOriginPoint;

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UISearchController *searchController;
@property (retain, nonatomic) IBOutlet NSMutableArray *searchResults;

@property (retain, nonatomic) NSMutableDictionary *sections;
@property (retain, nonatomic) NSMutableDictionary *sectionToMap;


// Scope button type
typedef NS_ENUM(NSInteger, UYLWorldFactsSearchScope)
{
    searchScopeEngName = 0,
    searchScopeScienceName = 1
};

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
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToMap = [NSMutableDictionary dictionary];
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
        [self.homeButton setImage:[UIImage imageNamed:@"Home-50-2.png"] forState:UIControlStateNormal];
        CGSize homeBtnFrame = self.homeButton.frame.size;
        CGPoint homeBtnPint =
        CGPointMake(cgRectLandscap.origin.x, cgRectLandscap.origin.y);
        
        self.homeButton.frame = CGRectMake(homeBtnPint.x , homeBtnPint.y + tableBounds.origin.y , homeBtnFrame.width, homeBtnFrame.height);
        
        self.homeBtnOriginPoint = homeBtnPint;
        [self.view addSubview:self.homeButton];
        
    }

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
    
    // refresh data from parse
//    [self loadObjects];
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
    /*
    if (self.objects.count == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;

    }*/
    
    [query fromLocalDatastore];
    [query orderByAscending:@"medMerEngName"];
    
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

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.sections.allKeys.count;;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if (self.searchController.active) {
        return  self.searchResults.count;
    
    } else {
        
        return self.objects.count;
    }
    /*
    NSString *sportType = [self titleForSection:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:sportType];
    return rowIndecesInSection.count;
     */
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    //static NSString *simpleTableIdentifier = @"PrescriptionCell";
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
    
#warning TODO: HERE fucking needs to do
    object = (!self.searchController.active) ? self.objects[indexPath.row] : self.searchResults[indexPath.row];
    
    cell.medMerEngLabel.text = [object objectForKey:@"medMerEngName"];
    cell.medMerChiLabel.text = [object objectForKey:@"medMerChiName"];
    cell.medScienceLabel.text = [object objectForKey:@"medScienceName"];
    cell.medCategoryLabel.text = [object objectForKey:@"medCategory"];
    
    [tableView bringSubviewToFront:self.homeButton];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    
    Medicine *medicine = [[Medicine alloc] init];
    medicine.medMerChiName = [object objectForKey:@"medMerChiName"];
    
    [MediDataSingleton shareInstance].medName = medicine.medMerChiName;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"add" object:nil];
}
#pragma mark - UISearchController

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    [self updateSearchResultsForSearchController:self.searchController];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = [searchController.searchBar text];
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}


- (void)searchForText:(NSString *)searchText scope:(UYLWorldFactsSearchScope)scopeOption
{
    [self.searchResults removeAllObjects];
    
    NSPredicate *predicate;
    
    // Query the Local Datastore
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
#warning unlock this for section title
/*
// make the search bar frame visible when scroll the table view.
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    if (tableView == self.tableView) {
        if (index > 0 ) {
            return [self.fetchrequestcontroller sectionindexTitles atIndex:index-1];
        } else {
            //self.tableView.contentOffset = CGPointZero;
            CGRect searchBarFrame = self.searchController.searchBar.frame;
            [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
            return NSNotFound;
        }
    } else {
        return 0;
    }
    
}
// show first element is the table view index search icon.
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == self.tableView) {
        //...
        NSMutableArray *index = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        NSArray *initials = [self.fetchrequestcontroller sectionindexTitles];
        [index addObjectsFromArray:initials];
        
        return index;
    } else {
        return  nil;
    }
}
*/
/*
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = [self titleForSection:section];
    return title;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
}
 
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 0;
}
*/


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
/*
-(NSString *)titleForSection:(NSInteger)section {
    
    return [self.sectionToMap objectForKey:[NSNumber numberWithInteger:section]];
}

-(void)objectsDidLoad:(NSError *)error {
    
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery.
    [self.sections removeAllObjects];
    [self.sectionToMap removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    for (PFObject *object in self.objects) {
        NSString *title = [object objectForKey:@"medMerEngName"];
        NSMutableArray *objectsInSection = [self.sections objectForKey:title];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this title - increment the section index.
            [self.sectionToMap setObject:title forKey:[NSNumber numberWithInteger:section++]];
        }
        [objectsInSection addObject:[NSNumber numberWithInteger:rowIndex++]];
        [self.sections setObject:objectsInSection forKey:title];
    }
}

-(PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = [self titleForSection:indexPath.section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:title];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}
 */

@end
