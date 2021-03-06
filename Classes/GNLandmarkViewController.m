//
//  SportsViewController.m
//  LayerManager
//
//  Created by Jake Kring on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNLandmarkViewController.h"

@implementation GNLandmarkViewController
@synthesize imageViewCell=_imageViewCell, imageURL=_imageURL, photo=_photo, fieldInfo=_fieldInfo, fieldNames=_fieldNames, layer=_layer, landmark=_landmark;

- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
	//if (self = [super initWithNibName:@"SportsViewController" bundle:nil]) {
		self.fieldInfo = [[NSMutableDictionary alloc]init];
	}
	return self;
}

- (void)setImageURL:(NSURL *)url {
	_imageURL = [url retain];
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
/*
-(void)setFieldInfo:(NSMutableDictionary *)newFieldInfo{
	for (NSString *field in self.fieldNames){
		[self.fieldInfo setObject:@"" forKey:field];
	}
	[self.fieldInfo setObject:@"" forKey:@"imageURL"];
	NSLog(@"Field Info: %@", self.fieldInfo);
	for (NSString *newField in newFieldInfo){
		if ([newFieldInfo objectForKey:newField]){
			[self.fieldInfo setObject:[newFieldInfo objectForKey:newField] forKey:newField];
		}
	}
}
*/
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	self.photo = [UIImage imageWithData:receivedData];
	[self.imageViewCell displayImage:self.photo];
	//self.imageViewCell.backgroundView = imageView;
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	if ([self.layer layerIsUserModifiable]) {
		UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelectEditButton)];
		[self.navigationItem setRightBarButtonItem:editButton animated:YES];
	}
}

-(void)didSelectEditButton {
	GNEditingTableViewController *editingViewController = (GNEditingTableViewController *)[self.layer getEditingViewControllerWithLocation:self.landmark andLandmark:self.landmark];
	[self.navigationController pushViewController:editingViewController animated:YES];	
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *headerString = [NSString stringWithString:@""];
	if (section == 0){
		headerString = @"Photo";
	}
	else {
		headerString = [self.fieldNames objectAtIndex:section];
	}
	return headerString;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fieldNames count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)getFrameSizeForString:(NSString *)string {
	//Anyone know how to do MOD in a better way!!!???
	CGFloat numberOfLines = (CGFloat)(([string length]-([string length]%40))/40);
	return numberOfLines;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    GNTableViewCell *cell = (GNTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //GNTableViewCell *cell = (GNTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GNTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
	}
    
	if (indexPath.section == 0) {
		if (_imageURL == nil) {
			CGFloat stringFrameSize = [self getFrameSizeForString:@"Click 'Edit' to take a Photo..."];
			[cell setContentString:@"Click 'Edit' to take a Photo..." withFrameSize:stringFrameSize];
		}
		else {
			[cell setContentString:@"" withFrameSize:(CGFloat)5];
			self.imageViewCell = cell;
			/// Display spinner here!
		}
	}
	else {
		NSString *contentString = [self.fieldInfo objectForKey:[self.fieldNames objectAtIndex:indexPath.section]];
		if ([contentString length]== 0) {
			[cell setContentString:[NSString stringWithFormat:@"Click 'Edit' to enter a %@...",[self.fieldNames objectAtIndex:indexPath.section]]
					 withFrameSize:(CGFloat)0];
		}
		else {
			CGFloat stringFrameSize = [self getFrameSizeForString:contentString];
			[cell setContentString:contentString withFrameSize:(CGFloat)stringFrameSize];
		}
	}

/*	
	else if (indexPath.section == 1){
		NSString *tring = 
		if ([self.summaryString length]== 0){
			[cell setContentString:@"Click 'Edit' to enter a Summary..." withFrameSize:(CGFloat)1];
		}
		else{
			CGFloat stringFrameSize = [self getFrameSizeForString:self.summaryString];
			[cell setContentString:self.summaryString withFrameSize:(CGFloat)stringFrameSize];
		}

	}
	
	else if(indexPath.section == 2){
		if ([self.usedByString length]== 0){
			[cell setContentString:@"Click 'Edit' to enter a List of Teams..." withFrameSize:(CGFloat)1];
		}
		else{
			CGFloat stringFrameSize = [self getFrameSizeForString:self.usedByString];
			[cell setContentString:self.usedByString withFrameSize:stringFrameSize];
		}
	}
    
	else{
		if ([self.scheduleURLString length] == 0){
			[cell setContentString:@"Click 'Edit' to enter a URL for the Schedule..." withFrameSize:(CGFloat)1];
		}
		else{
			CGFloat stringFrameSize = [self getFrameSizeForString:self.scheduleURLString];
			[cell setContentString:self.scheduleURLString withFrameSize:stringFrameSize];
		}
	}
 */
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
		if (_imageURL == nil) {
			return (CGFloat)40;
		}
		else {
			return (CGFloat)180;
		}
	}
	else {
		NSString *contentString = [self.fieldInfo objectForKey:[self.fieldNames objectAtIndex:indexPath.section]];
		CGFloat stringFrameSize = [self getFrameSizeForString:contentString];
		return (CGFloat)(stringFrameSize*(CGFloat)15)+(CGFloat)40;
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self.fieldNames objectAtIndex:indexPath.section] rangeOfString:@"URL"].length && [self.fieldInfo objectForKey:[self.fieldNames objectAtIndex:indexPath.section]]){
		return indexPath;
	}
	else {
		return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	UIViewController *viewController = [[UIViewController alloc] init];
	UIWebView *webView = [[UIWebView alloc] init];
	NSString *urlString = [self.fieldInfo objectForKey:[self.fieldNames objectAtIndex:indexPath.section]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	viewController.title = self.landmark.name;
	viewController.view = webView;
	[webView release];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];	
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