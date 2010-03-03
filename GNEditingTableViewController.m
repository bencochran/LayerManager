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

@synthesize adding=_adding, userInputDict=_userInputDict, fields=_fields, fieldContent=_fieldContent, imageViewCell=_imageViewCell, imageURL=_imageURL, photo=_photo;

- (id)initWithLayer:(GNLayer *)layer andLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark{
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		selectedLayer = [layer retain]; 
		self.fields = selectedLayer.fields;
		selectedLocation = [location retain];
		selectedLandmark = [landmark retain];
		//eNSLog(@"Fields: %@",self.fields);
		self.fieldContent =[[NSMutableDictionary alloc] init];
		self.userInputDict = [[NSMutableDictionary alloc] init];
		tookPhoto = NO;
		previouslyExisted = NO;
		self.adding = NO;
		//NSLog(@"Creating editing table for landmark: %@", selectedLandmark);
		//NSLog(@"Layer name: %@", selectedLayer.name);
		
		if (selectedLandmark) {
			if ([selectedLayer containsLandmark:selectedLandmark limitToValidated:NO]) {
				previouslyExisted = YES;
				NSMutableDictionary *tempDict = (NSMutableDictionary *)[selectedLayer fieldInformationForLandmark:selectedLandmark];
				for (NSString *fieldName in tempDict){
					if ([[tempDict objectForKey:fieldName] isKindOfClass:[NSNull class]]){
						NSLog(@"hello from nilville");
						[self.fieldContent setObject:@"" forKey:fieldName];
					}
					else{
						[self.fieldContent setObject:[tempDict objectForKey:fieldName] forKey:fieldName];
					}
				}
				[tempDict release];
				imageURLString = [self.fieldContent objectForKey:@"imageURL"];
				[self.fieldContent removeObjectForKey:@"imageURL"];
			}
			else {
				self.adding = YES;
				for (NSString *fieldName in self.fields){
					[self.fieldContent setObject:@"" forKey:fieldName];
				}
				[self.fieldContent setObject:(NSString *)selectedLandmark.name forKey:"Name"];
				imageURLString = @"";
			}
		}
		else{
			self.adding = YES;
			for (NSString *fieldName in self.fields){
				[self.fieldContent setObject:@"" forKey:fieldName];
			}
			imageURLString = @"";
		}
	}
	return self;
}

- (void)addUserInput:(NSString *)input toField:(NSInteger)index{
	[self.fieldContent setObject:input forKey:[self.fields objectAtIndex:index]];
	if (index == 0) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.title = input;
	}
	[self.userInputDict setObject:input forKey:[selectedLayer.serverNamesForFields objectAtIndex:index-1]];
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
	NSLog(@"Image URL: %@", imageURLString);
	NSLog(@"Fields: %@", self.fields);
	NSLog(@"Content of Fields: %@", self.fieldContent);

	if (imageURLString == @"") {
		NSLog(@"doesn't have IMage URL");
	}
	else{
		[self getImageWithURL:[NSURL URLWithString:imageURLString]];
	}
		/*		imageURL = [NSURL URLWithString:imageURLString];
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageURL];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(setDidFinishPhotoRequest:)];
		[request startAsynchronous];
		
		NSLog(@"has image URL");
	}
	buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
	UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[takePhotoButton setTitle:@"Photo" forState:UIControlStateNormal];
	takePhotoButton.frame = CGRectMake(10,10,80,80);
	takePhotoButton.alpha = 0.8;
	[takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
	[buttonContainer addSubview:takePhotoButton];
	self.tableView.tableHeaderView = buttonContainer;
	photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,80,80)];
	photoView.contentMode = UIViewContentModeScaleAspectFit;
}
*/
	
}
- (void)getImageWithURL:(NSURL *)url {
	self.imageURL = [url retain];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData that will hold the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} 
	else {
		// inform the user that the download could not be made
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.photo = [UIImage imageWithData:receivedData];
	[self.imageViewCell displayImage:self.photo];
	//self.imageViewCell.backgroundView = imageView;
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}

-(void)takePhoto{
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
	self.photo = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
	[self.imageViewCell displayImage:self.photo];

	[photoController release];
	photoController = nil;
	tookPhoto = YES;
}
- (void)postToServer:(id)sender {
	if (!tookPhoto) {
		self.photo = nil;
	}
	if (selectedLandmark) {
		// The substringFromIndex:7 parameter strips off the "gnarus:" in the beginning of landmarkID's for the gnarus server.
		[selectedLayer postLandmark:self.userInputDict withName:selectedLandmark.name withLocation:selectedLocation withID:[selectedLandmark.ID substringFromIndex:7] andPhoto:self.photo];
		//[selectedLayer postLandmarkArray:userInput withID:[selectedLandmark.ID substringFromIndex:7] withLocation:selectedLocation andPhoto:photo];
	}
	else {
		[selectedLayer postLandmark:self.userInputDict withName:self.title withLocation:selectedLocation withID:@"0" andPhoto:self.photo];
	}
	NSLog(@"Posting photo: %@", self.photo);
	//NSLog(@"Posting user input array : %@", userInput);
	// update selected layer to center location [selectedLayer updateToCenterLocation:[[GNLayerManager sharedManager] center];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0){
		return @"Photo";
	}
	else{
		return [self.fields objectAtIndex:section-1];
	}
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
	return [self.fields count]+1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";	
	GNTableViewCell *cell = (GNTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[GNTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	// UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
    //    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //}
	if (indexPath.section == 0){
		if (imageURLString == @""){
			[cell setContentString:@"Click to take a Photo..." withFrameSize:(CGFloat)40];
		}
		else{
			[cell setContentString:@"" withFrameSize:(CGFloat)5];
			self.imageViewCell = cell;
		}
	}
	else{
	NSString *contentString = [self.fieldContent objectForKey:[self.fields objectAtIndex:indexPath.section-1]];
	[cell setContentString:contentString withFrameSize:(CGFloat)0];
	
	//[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	}
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0)||(previouslyExisted && indexPath.section == 1)){
        return nil;
    }
	return indexPath;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0){
		[self takePhoto];
	}
	currentField = indexPath.section - 1;
	if (!(previouslyExisted && currentField == 0)){
		UIViewController *infoInputViewController = [[GNInfoInputViewController alloc] initWithFieldName:[self.fields objectAtIndex:currentField] andContent:[self.fieldContent objectForKey:[self.fields objectAtIndex:currentField]]];
		[self.navigationController pushViewController:infoInputViewController animated:YES];
		[infoInputViewController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==0 && ((imageURLString != @"")||tookPhoto)){
		return (CGFloat)180;
	}
	else{
		return (CGFloat)40;
	}
}

- (void)dealloc {
	//[self.fields release];
	//[userInput release];
	[selectedLayer release];
	[selectedLocation release];
	[selectedLandmark release];
	//[buttonContainer release];
	//[self.photo release];
	//[photoView release];
	//[self.imageURL release];
	
    [super dealloc];
}

@end