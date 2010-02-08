//
//  GNInfoInputViewController.m
//  LayerManager
//
//  Created by Jake Kring on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNInfoInputViewController.h"


@implementation GNInfoInputViewController

-(id)initWithFieldArray:(NSArray *)newFieldArray andInput:(NSString *)input{
	if (self = [super init]) {
		fieldArray = newFieldArray;
		savedInput = input;
		NSLog(@"Fields: %@",[fieldArray objectAtIndex:0]);
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	self.title = [fieldArray objectAtIndex:0];
	if([fieldArray objectAtIndex:1] == @"textView"){
		textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
		textView.delegate = self;
		textView.textAlignment = UITextAlignmentLeft;
		[self.view addSubview:textView];
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		textView.text = savedInput;
		[textView becomeFirstResponder];
		[textView release];
	}
	else{
		textField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,300,25)];
		textField.textAlignment = UITextAlignmentLeft;
		textField.borderStyle = UITextBorderStyleRoundedRect;
		[self.view addSubview:textField];
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		textField.text = savedInput;
		[textField becomeFirstResponder];
		[textField release];
	}
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)save:(id)sender {
	if([fieldArray objectAtIndex:1] == @"textView"){
		inputString = textView.text;
	}
	else{
		inputString = textField.text;
	}
	UIViewController *editingTableViewController = [self.navigationController.viewControllers objectAtIndex:3];
	[editingTableViewController addUserInput:inputString toField:[editingTableViewController getCurrentField]];
	[[editingTableViewController tableView] reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

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


- (void)dealloc {
    [super dealloc];
}


@end
