//
//  GNTextViewEditor.m
//  LayerManager
//
//  Created by Jake Kring on 2/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNTextViewEditor.h"


@implementation GNTextViewEditor

UILabel *label;
UITextView *textView;
UITextField *textField;
NSArray *fieldArray;
NSString *inputString;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
-(id)initWithFieldArray:(NSArray *)newFieldArray {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		fieldArray = [newFieldArray retain];
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	self.title = [fieldArray objectAtIndex:0];
	[saveButton release];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)save:(id)sender {
	if([fieldArray objectAtIndex:1] == @"longString"){
		inputString = textView.text;
	}
	else{
		inputString = textField.text;
	}
	UIViewController *previousViewController = [self.navigationController.viewControllers objectAtIndex:3];
	[previousViewController addUserInput:inputString toField:[previousViewController getCurrentField]];
	[[previousViewController tableView] reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

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
    return 1;
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
	
	if([fieldArray objectAtIndex:1] == @"longString"){
		textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
		textView.delegate = self;
		textView.textAlignment = UITextAlignmentLeft;
		[self.view addSubview:textView];
		[textView becomeFirstResponder];
		[textView release];
	}
	else{
		textField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,300,25)];
		textField.textAlignment = UITextAlignmentLeft;
		textField.borderStyle = UITextBorderStyleRoundedRect;
		[self.view addSubview:textField];
		[textField becomeFirstResponder];
		[textField release];
	}
	//else if([fieldArray objectAtIndex:1] == @"longString")
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
	//[label release];
    [super dealloc];
}


@end
