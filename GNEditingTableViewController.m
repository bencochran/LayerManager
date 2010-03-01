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
#import "ASIHTTPRequest.h"

@implementation GNEditingTableViewController

@synthesize adding=_adding, userInputDict=_userInputDict;

- (id)initWithFields:(NSArray *)newFields andLayer:(GNLayer *)layer andLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		fields = [newFields retain];
		NSLog(@"Fields: %@",fields);
		userInput =[[NSMutableArray alloc] initWithCapacity:([fields count])];
		self.userInputDict = [[NSMutableDictionary alloc] init];
		selectedLocation = [location retain];
		selectedLayer = [layer retain]; 
		selectedLandmark = [landmark retain];
		tookPhoto = NO;
		
		NSLog(@"Creating editing table for landmark: %@", selectedLandmark);
		NSLog(@"Layer name: %@", selectedLayer.name);
		
		if (selectedLandmark) {
			NSLog(@"Landmark already exists");
			if ([selectedLayer containsLandmark:selectedLandmark limitToValidated:NO]) {
				NSLog(@"Layer's landmark info: %@",  [selectedLayer fieldInformationForLandmark:selectedLandmark]);
			}
			else {
				NSLog(@"Layer does not already have landmark info");
			}
		}
		
		if (selectedLandmark && [layer containsLandmark:selectedLandmark limitToValidated:NO]) {
			NSLog(@"Landmark already exists");
			previouslyExisted = YES;
			self.adding = NO;
			
			NSDictionary *fieldDictionary = [selectedLayer fieldInformationForLandmark:selectedLandmark];
			NSLog(@"Field information from layer %@ for landmark: %@", selectedLayer.name, fieldDictionary);
			
			NSLog(@"Entering existing user input");
			for (int i = 0; i < ([fields count]); i++) {
				NSLog(@"%@ -> %@", [[fields objectAtIndex:i] objectAtIndex:0],
									 [fieldDictionary objectForKey:[[fields objectAtIndex:i] objectAtIndex:0]]);
				[userInput insertObject:[fieldDictionary objectForKey:[[fields objectAtIndex:i] objectAtIndex:0]] atIndex:i];
			}
			NSLog(@"Completed existing user input: %@", userInput);
			
			NSLog(@"Finding image for existing landmark. . .");
			if ([[fieldDictionary objectForKey:@"imageURL"] class] == [NSNull class]) {
				NSLog(@"Layer does not support images: set imageURL to nil");
				imageURL = nil;
			}
			else {
				NSLog(@"Layer supports images: get existing image for this landmark");
				imageURL = [[NSURL URLWithString:[fieldDictionary objectForKey:@"imageURL"]] retain];
				if ([imageURL class] == [NSNull class]) {
					NSLog(@"Existing image for this landmark is nil: set imageURL to nil");
					[imageURL release];
					imageURL = nil;
				} else {
					NSLog(@"Successfully set imageURL to existing image");
				}
			}
		}
		else {
			NSLog(@"Layer does not have information for this landmark: adding");
			
			self.adding = YES;
			if (selectedLandmark) {
				NSLog(@"Landmark already exists, set name field (at index 0) to: %@", selectedLandmark.name);
				previouslyExisted = YES;
				self.title = selectedLandmark.name;
				[userInput insertObject:selectedLandmark.name atIndex:0];
			}
			else {
				NSLog(@"Landmark does not already exist, set name field (at index 0) to the empty string");
				previouslyExisted = NO;
				[userInput insertObject:@"" atIndex:0];
			}
			
			// Set all other user inputs to the empty string, and set imageURL to nil 
			for (int i = 1; i < ([fields count]); i++) {
				[userInput insertObject:@"" atIndex:i];
			}
			imageURL = nil;
		}
		
		NSLog(@"Number of elements in user input: %d",[userInput count]);
	}
	return self;
}

- (void)addUserInput:(NSString *)input toField:(NSInteger)index{
	[userInput replaceObjectAtIndex:index withObject:input];
	if (index == 0) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.title = input;
	}
	else{
		[self.userInputDict setObject:input forKey:[selectedLayer.serverNamesForFields objectAtIndex:index-1]];
	}
}
-(NSInteger)getCurrentField {
	return currentField;
}

- (void)setAdding:(BOOL)adding {
	_adding = adding;
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
	NSLog(@"Adding: %@", self.adding ? @"yes" : @"no");
	if (self.adding){
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(postToServer:)];
		self.navigationItem.rightBarButtonItem = doneButton;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[doneButton release];
	}
	else {
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postToServer:)];
		self.navigationItem.rightBarButtonItem = doneButton;
		if (previouslyExisted) {
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
		else{
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
		[doneButton release];
	}
	buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
	NSLog(@"Photo: %@",photo);
	if (photo == nil) {
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[takePhotoButton setTitle:@"Photo" forState:UIControlStateNormal];
		takePhotoButton.frame = CGRectMake(10,10,80,80);
		takePhotoButton.alpha = 0.8;
		[takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
		[buttonContainer addSubview:takePhotoButton];
	}
	if (imageURL) {
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageURL];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(setDidFinishPhotoRequest:)];
		[request startAsynchronous];
	}
	self.tableView.tableHeaderView = buttonContainer;
	photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,80,80)];
	photoView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setDidFinishPhotoRequest:(ASIHTTPRequest *)request{	
	// Use when fetching binary data
	NSData *responseData = [request responseData];
	photo = [[UIImage imageWithData:responseData] retain];
	photoView.image = photo;
	[buttonContainer addSubview:photoView];
	[buttonContainer setNeedsDisplay];
	
}

- (void)requestFailed:(ASIHTTPRequest *)request{
//	NSError *error = [request error];
}

-(IBAction)takePhoto:(id)sender {
	NSLog(@"In takePhoto");
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
	
	NSLog(@"End of takePhoto, photoController: %@", photoController);
}


- (void)imagePickerController:(UIImagePickerController *)controller didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"In imagePickerController, controller: %@", controller);
	
	[controller dismissModalViewControllerAnimated:YES];
	photo = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
	photoView.image = photo;
	[buttonContainer addSubview:photoView];
	[buttonContainer setNeedsDisplay];
	self.tableView.tableHeaderView = buttonContainer;
	[photoController release];
	photoController = nil;
	tookPhoto = YES;
}

- (void)postToServer:(id)sender {
	if (!tookPhoto) {
		photo = nil;
	}
	if (selectedLandmark) {
		// The substringFromIndex:7 parameter strips off the "gnarus:" in the beginning of landmarkID's for the gnarus server.
		[selectedLayer postLandmark:self.userInputDict withName:selectedLandmark.name withLocation:selectedLocation withID:[selectedLandmark.ID substringFromIndex:7] andPhoto:photo];
		//[selectedLayer postLandmarkArray:userInput withID:[selectedLandmark.ID substringFromIndex:7] withLocation:selectedLocation andPhoto:photo];
	}
	else {
		[selectedLayer postLandmark:self.userInputDict withName:self.title withLocation:selectedLocation withID:@"0" andPhoto:photo];
	}
	NSLog(@"Posting photo: %@", photo);
	NSLog(@"Posting user input array : %@", userInput);
	// update selected layer to center location [selectedLayer updateToCenterLocation:[[GNLayerManager sharedManager] center];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[fields objectAtIndex:section] objectAtIndex:0];
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
	
	NSString *inputFields = [userInput objectAtIndex:(indexPath.section)];
	cell.textLabel.text = inputFields;
	
	//[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (previouslyExisted && indexPath.section == 0){
        return nil;
    }
	return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	currentField = indexPath.section;
	if (!(previouslyExisted && currentField == 0)){
		UIViewController *infoInputViewController = [[GNInfoInputViewController alloc] initWithFieldArray:[fields objectAtIndex:(indexPath.section)] 
																								 andInput:[userInput objectAtIndex:indexPath.section]];
		[self.navigationController pushViewController:infoInputViewController animated:YES];
		[infoInputViewController release];
	}
}

- (void)dealloc {
	[fields release];
	[userInput release];
	[selectedLayer release];
	[selectedLocation release];
	[selectedLandmark release];
	[buttonContainer release];
	[photo release];
	[photoView release];
	[imageURL release];
	
    [super dealloc];
}

@end