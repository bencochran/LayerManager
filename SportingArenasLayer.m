//
//  SportingArenasLayer.m
//  LayerManager
//
//  Created by Eric Alexander on 2/20/10.
//  Copyright 2010 Gnarus. All rights reserved.
//

#import "SportingArenasLayer.h"
#import "JSON.h"

@implementation SportingArenasLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Sports";
		iconPath = @"sports.png";
		userModifiable = YES;
		NSArray *nameField = [[NSMutableArray alloc] initWithObjects:@"Name", @"textField", nil];
		NSArray *summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *usedByField = [[NSMutableArray alloc] initWithObjects:@"Used By", @"textField", nil];
		NSArray *scheduleURLField = [[NSMutableArray alloc] initWithObjects:@"Schedule", @"textField", nil];
		layerFields = [[NSArray alloc] initWithObjects:nameField, summaryField, usedByField, scheduleURLField, nil];
		[nameField release];
		[summaryField release];
		[usedByField release];
		[scheduleURLField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	// http://dev.gnar.us/getInfo.py/SportingArenas?udid=3&lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	// TODO: add limitToValidated stuff
	/*NSString *urlString = nil;
	if (limitToValidated == YES) {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/SportingArenas?udid=%@&lat=%f&lon=%f&maxLandmarks=%d",
						   [[UIDevice currentDevice] uniqueIdentifier], 
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxLandmarks]];
	}
	else {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/Vote.py/AddingToSportingArenas?lat=%f&lon=%f&maxDistance=%f",
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxDistance]];
	}
	return [NSURL URLWithString:urlString];*/
	return [self URLForLocation:location limitToValidated:limitToValidated withLayerName:@"SportingArenas"];
}

- (NSArray *)parseDataIntoLandmarks:(NSData *) data {
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release]; reply = nil;
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	NSMutableArray *landmarks = [NSMutableArray array];
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"usedBy"] forKey:@"usedBy"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"scheduleURL"] forKey:@"scheduleURL"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"id"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[layerInfo release];
		[landmarks addObject:landmark];
	}
	
	return landmarks;
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/sportingarenas"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	NSLog(@"Info: %@", info);
	[request setPostValue:[info objectAtIndex:0] forKey:@"name"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"usedBy"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"scheduleURL"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setPostValue:landmarkID forKey:@"landmarkID"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
	[request setData:photoData forKey:@"sportingArenasImage"];
	request.delegate = self;
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"Finished: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}


- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	SportingArenasViewController *viewController = [[SportingArenasViewController alloc] init];
	viewController.name = landmark.name;
	viewController.layer = self;
	viewController.landmark = landmark;
	viewController.summary = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
	viewController.usedBy = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"usedBy"];
	viewController.scheduleURL = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"scheduleURL"];
	//	UIWebView *webView = [[UIWebView alloc] init];
	//	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"menuURL"];
	//
	//	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	//	
	//	viewController.title = self.name;
	//	viewController.view = webView;
	//	[webView release];
	
	return [viewController autorelease];
}

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	NSDictionary *layerInfo = [layerInfoByLandmarkID objectForKey:landmark.ID];
	NSMutableDictionary *landmarkFieldInfo = [[NSMutableDictionary alloc] init];
	[landmarkFieldInfo setObject:landmark.name forKey:@"Name"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"summary"] forKey:@"Summary"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"usedBy"] forKey:@"Used By"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"scheduleURL"] forKey:@"Schedule"];	
	return [landmarkFieldInfo autorelease];
}

@end

//////////

@implementation SportingArenasViewController

@synthesize imageURL=_imageURL, nameLabel=_nameLabel, summaryView=_summaryView, usedByView=_usedByView, scheduleURLView=_scheduleURLView, name=_name, summary=_summary, usedBy=_usedBy, scheduleURL=_scheduleURL, layer=_layer, landmark=_landmark;

- (id)init {
	if (self = [super initWithNibName:@"SportingArenasView" bundle:nil]) {
		
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
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.nameLabel.text = self.name;
	if (self.summary == nil){
		self.summaryView.text = @"Click 'Edit' to enter a Summary.";
	}
	else{
		self.summaryView.text = self.summary;
	}
	if (self.usedBy == nil){
		self.usedByView.text = @"Click 'Edit' to enter a list of Sports Teams who use this Facility.";
	}
	else{
		self.usedByView.text = self.usedBy;
	}
	if (self.scheduleURL == nil){
		self.scheduleURLView.text = @"Click 'Edit' to enter a URL for this Facility's schedule.";
	}
	else{
		self.scheduleURLView.text = self.scheduleURL;
	}
	//UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelectEditButton:)];
	//[self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

-(void)didSelectEditButton{
	[self.navigationController pushViewController:[self.layer getEditingViewControllerWithLocation:self.landmark andLandmark:self.landmark] animated:YES];	
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