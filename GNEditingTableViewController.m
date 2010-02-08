//
//  GNEditingTableViewController.m
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GNEditingTableViewController.h"
#import "GNLayer.h"
#import "GNInfoInputViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GNEditingTableViewController

- (id)initWithFields:(NSArray *)newFields andLayer:(GNLayer *)layer andLocation:(CLLocation *)location {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		fields = [newFields retain];
		userInput =[[NSMutableArray alloc] initWithCapacity:([fields count])];
		for (int i = 0; i < ([fields count]); i ++){
			[userInput insertObject:@"" atIndex:0];
		}
		selectedLayer = layer;
		selectedLocation = location;
		NSLog(@"%d",[userInput count]);
	}
	return self;
}

- (void)addUserInput:(NSString *)input toField:(NSInteger)index{
	[userInput replaceObjectAtIndex:index withObject:input];
	if (index == 0){
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}
-(NSInteger)getCurrentField {
	return currentField;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(postToServer:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
	NSLog(@"Photo: %@",photo);
	if (photo == nil){
		takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[takePhotoButton setTitle:@"Photo" forState:UIControlStateNormal];
		takePhotoButton.frame = CGRectMake(10,10,80,80);
		takePhotoButton.alpha = 0.8;
		[takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
		[buttonContainer addSubview:takePhotoButton];
	}
	self.tableView.tableHeaderView = buttonContainer;
}

-(IBAction) takePhoto:(id) sender {
	photoController = [[UIImagePickerController alloc] init];
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
		photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else {
		NSLog(@"The camera's not available in simulator");
		photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	photoController.delegate = self;
	[self presentModalViewController:photoController animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)controller didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[controller dismissModalViewControllerAnimated:YES];
	photo = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
	photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,80,80)];
	photoView.image = photo;
	[buttonContainer addSubview:photoView];
	[buttonContainer setNeedsDisplay];
	self.tableView.tableHeaderView = buttonContainer;
}

- (void)postToServer:(id)sender {
	//UIViewController *layersViewController = [self.navigationController.viewControllers objectAtIndex:2];
	//GNLayer *layer = [layersViewController getSelectedLayer];
	//UIViewController *mapViewController = [self.navigationController.viewControllers objectAtIndex:1];
	//CLLocation *location = [mapViewController getSelectedLocation];
	[selectedLayer postLandmarkArray:userInput withLocation:selectedLocation andPhoto:photo];
	[self.navigationController popToRootViewControllerAnimated:YES];

}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // One section is devoted to each field, including the proposed title/name.
	return [fields count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	//if (indexPath.section == 0) {
	//	cell.textLabel.text = [@"Name: " stringByAppendingString:[userInput objectAtIndex:0]];
	//}
	//else {
	NSString *fieldName = [[[fields objectAtIndex:(indexPath.section)]objectAtIndex:0] stringByAppendingString:@": "];
	NSString *inputFields = [userInput objectAtIndex:(indexPath.section)];
	cell.textLabel.text = [fieldName stringByAppendingString: inputFields];
    //}
	//[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	//if (indexPath.section == 0) {
	//	currentField = indexPath.section;
	//	NSArray *nameInfo = [[[NSMutableArray alloc] initWithObjects:@"Name", @"textField",@"", nil]retain];
	//	UIViewController *textEditingViewController =[[[GNInfoInputViewController alloc] initWithFieldArray:nameInfo] autorelease];
	//	[self.navigationController pushViewController:textEditingViewController animated:YES];
	//}
	//else {
	currentField = indexPath.section;
	UIViewController *infoInputViewController =[[[GNInfoInputViewController alloc] initWithFieldArray:[fields objectAtIndex:(indexPath.section)] 
																							 andInput:[userInput objectAtIndex:indexPath.section]] autorelease];
	[self.navigationController pushViewController:infoInputViewController animated:YES];
	//}
	//UIViewController *editingViewController = [layer getEditingViewController];
	//[self.navigationController pushViewController:editingViewController animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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


- (void)dealloc {
    [super dealloc];
}


@end