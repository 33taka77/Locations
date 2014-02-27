//
//  RootViewController.m
//  Locaion
//
//  Created by 相澤 隆志 on 2014/02/26.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "RootViewController.h"
#import "Event.h"


@interface RootViewController ()

@end

@implementation RootViewController

@synthesize eventsArray;
@synthesize managedObjectContext;
@synthesize locationManager;
@synthesize addButton;

- (CLLocationManager*)locationManager
{
    if( locationManager != nil )
    {
        return locationManager;
    }
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.delegate = self;
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    addButton.enabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    addButton.enabled = NO;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"Locations";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    self.navigationItem.rightBarButtonItem = addButton;
    //eventsArray = [[NSMutableArray alloc] init];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor* sortDescripter = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescripter, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError* error = nil;
    NSMutableArray* mutableFeychResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if( mutableFeychResults == nil )
    {
        NSLog(@"Fetch error");
    }
    [self setEventsArray:mutableFeychResults];
    
    [[self locationManager]startUpdatingLocation];
}

- (void)addEvent
{
    CLLocation* location = [locationManager location];
    if( location == nil )
    {
        return;
    }
    Event* event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:managedObjectContext];
    CLLocationCoordinate2D coordinate = [location coordinate];
    event.latitude = [NSNumber numberWithDouble:coordinate.latitude];
    event.longitude = [NSNumber numberWithDouble:coordinate.longitude];
    event.creationDate = [NSDate date];
    
    NSError* error = nil;
    if( ![managedObjectContext save:&error] )
    {
        NSLog(@"save error");
        abort();
    }
    
    [eventsArray insertObject:event atIndex:0];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [eventsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
 
    static NSDateFormatter* dateFormatter = nil;
    if( dateFormatter == nil )
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    static NSNumberFormatter* numberFormatter = nil;
    if( numberFormatter == nil )
    {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:3];
    }
    
    Event* event = [eventsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dateFormatter stringFromDate:[event creationDate]];
    NSString* string = [NSString stringWithFormat:@"%@, %@", [numberFormatter stringFromNumber: event.latitude],
                        [numberFormatter stringFromNumber:event.longitude] ];
    cell.detailTextLabel.text = string;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObject* eventDelete = [eventsArray objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:eventDelete];
        
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath ] withRowAnimation:UITableViewRowAnimationFade];
        
        //ここで落ちる!!! 原因不明
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath ] withRowAnimation:YES];
        NSError* error = nil;
        if( ![managedObjectContext save:&error] )
        {
            
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
