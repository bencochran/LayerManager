//
//  SportsViewController.m
//  LayerManager
//
//  Created by Jake Kring on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SportsViewController.h"

@implementation SportsViewController
@synthesize summaryCell=_summaryCell, summary=_summary, summaryString=_summaryString, usedByCell=_usedByCell, usedBy=_usedBy, usedByString=_usedByString, scheduleURLCell=_scheduleURLCell, scheduleURL=_scheduleURL, scheduleURLString=_scheduleURLString, imageViewCell=_imageViewCell, imageURL=_imageURL, layer=_layer, landmark=_landmark;

- (id)init {
	//if (self = [super initWithStyle:UITableViewStyleGrouped]){
	if (self = [super initWithNibName:@"SportsViewController" bundle:nil]) {
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
	} else {
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
	UIImage *image = [UIImage imageWithData:receivedData];
	imageView.image = image;
	//self.imageViewCell.backgroundView = imageView;
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString *headerString = [NSString stringWithString:@""];
	if (section == 0){
		headerString = @"Photo";
	}
	else if (section == 1){
		headerString = @"Summary";

	}
	else if (section ==2) {
		headerString = @"Used By";
	}
	else{
		headerString = @"Schedule URL";
	}
	return headerString;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //GNTableViewCell *cell = (GNTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
		//cell = [[[GNTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section == 0){
		//[cell.cellView setContentString:self.summaryString];
		//return cell;
		return self.imageViewCell;
	}
	
	else if (indexPath.section == 1){
		//[cell.cellView setContentString:self.summaryString];
		//return cell;
		self.summary.text = self.summaryString;
		return self.summaryCell;

	}
	
	else if(indexPath.section == 2){
		//[cell.cellView setContentString:self.usedByString];
		//return cell;
		self.usedBy.text = self.usedByString;
		return self.usedByCell;
	}
    
	else{
		//[cell.cellView setContentString:self.scheduleURLString];
		//return cell;
		self.scheduleURL.text = self.scheduleURLString;
		return self.scheduleURLCell;
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
		return 180;
	}
	else if (indexPath.section == 1){
		return 90;
	}
	else{
		return 45;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if (indexPath.section == 3){
		//if (! self.scheduleURLString == nil){
			UIViewController *viewController = [[UIViewController alloc] init];
			UIWebView *webView = [[UIWebView alloc] init];
			NSString *urlString = self.scheduleURLString;
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
			viewController.title = self.landmark.name;
			viewController.view = webView;
			[webView release];
			[self.navigationController pushViewController:viewController animated:YES];
			[viewController release];	
		//}
	}
	
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

