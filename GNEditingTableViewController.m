//
//  GNEditingTableViewController.m
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNEditingTableViewController.h"
#import "GNLayer.h"
#import "GNInfoInputViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GNEditingTableViewController

-(id)initWithFields:(NSArray *)newFields {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		//GNTextFieldCell *nameField = [[GNTextFieldCell alloc] initWithLabel:@"Name:"];
		fields = [newFields retain];
		userInput =[[NSMutableArray alloc] initWithCapacity:([fields count]+1)];
		for (int i = 0; i < ([fields count]+1); i ++){
			[userInput insertObject:@"" atIndex:0];
		}
		NSLog(@"%d",[userInput count]);
	}
	return self;
}

- (void)addUserInput:(NSString *)input toField:(NSInteger)index;{
	[userInput replaceObjectAtIndex:index withObject:input];
	NSLog(@"%@",userInput);
	self.navigationItem.rightBarButtonItem.enabled = YES;
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
	[doneButton release];
	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)postToServer:(id)sender {
	NSLog(@"Posting to server...");
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
	return [fields count] + 1;
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
    
	NSLog(@"IndexPath.section: %i", indexPath.section);
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Name: ";
	}
	else {
		NSString *fieldName = [[[fields objectAtIndex:(indexPath.section - 1)]objectAtIndex:0] stringByAppendingString:@": "];
		NSString *inputFields = [userInput objectAtIndex:(indexPath.section)];
		cell.textLabel.text = [fieldName stringByAppendingString: inputFields];
    }
	//[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.section == 0){
		NSLog(@"Instantiate Name Editing Interface Here");
	}
	else{
		currentField = indexPath.section;
		UIViewController *textEditingViewController =[[[GNInfoInputViewController alloc] initWithFieldArray:[fields objectAtIndex:(indexPath.section-1)]] autorelease];
		[self.navigationController pushViewController:textEditingViewController animated:YES];
	}
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
