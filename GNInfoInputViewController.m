//
//  GNInfoInputViewController.m
//  LayerManager
//
//  Created by Jake Kring on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNInfoInputViewController.h"


@implementation GNInfoInputViewController

UILabel *label;
UITextView *textView;
UITextField *textField;
NSArray *fieldArray;
NSString *inputString;

-(id)initWithFieldArray:(NSArray *)newFieldArray {
	if (self = [super init]) {
		fieldArray = [newFieldArray retain];
	}
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	self.title = [fieldArray objectAtIndex:0];
	if([fieldArray objectAtIndex:1] == @"longString"){
		textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
		textView.delegate = self;
		textView.textAlignment = UITextAlignmentLeft;
		[self.view addSubview:textView];
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		[textView becomeFirstResponder];
		[textView release];
	}
	else{
		textField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,300,25)];
		textField.textAlignment = UITextAlignmentLeft;
		textField.borderStyle = UITextBorderStyleRoundedRect;
		[self.view addSubview:textField];
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
		[textField becomeFirstResponder];
		[textField release];
	}	
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
