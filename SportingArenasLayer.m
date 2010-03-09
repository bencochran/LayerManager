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
		self.tableNameOnServer=@"SportingArenas";
		iconPath = @"sports.png";
		userModifiable = YES;
		NSArray *nameField = [[NSMutableArray alloc] initWithObjects:@"Name", @"textField", nil];
		NSArray *summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *usedByField = [[NSMutableArray alloc] initWithObjects:@"Used By", @"textField", nil];
		NSArray *scheduleURLField = [[NSMutableArray alloc] initWithObjects:@"Schedule URL", @"textField", nil];
		layerFields = [[NSArray alloc] initWithObjects:nameField, summaryField, usedByField, scheduleURLField, nil];
		self.fields = [[NSArray alloc] initWithObjects:@"Name",@"Summary",@"Used By",@"Schedule URL", nil];
		self.serverNamesForFields = [[NSArray alloc] initWithObjects:@"summary",@"usedBy",@"scheduleURL", nil];
		[nameField release];
		[summaryField release];
		[usedByField release];
		[scheduleURLField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
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
	NSMutableArray *parsedLandmarks = [NSMutableArray array];
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"usedBy"] forKey:@"usedBy"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"scheduleURL"] forKey:@"scheduleURL"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"id"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		[parsedLandmarks addObject:landmark];
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[layerInfo release];
	}
	
	return parsedLandmarks;
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo {
	NSLog(@"Posting info: %@", info);
	
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/sportingArenas"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[info objectAtIndex:0] forKey:@"name"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"usedBy"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"scheduleURL"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setPostValue:landmarkID forKey:@"landmarkID"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
	
	if(photo) {
		NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
		[request setData:photoData forKey:@"image"];
	}
	else {
		[request setPostValue:@"" forKey:@"image"];
	}
	request.delegate = self;
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	// Use when fetching text data
	NSString *responseString = [request responseString];
	NSLog(@"Finished: %@", responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"Error: %@", error);
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	GNLandmarkViewController *viewController = [[GNLandmarkViewController alloc] init];
	viewController.title = landmark.name;
	viewController.layer = self;
	viewController.landmark = landmark;
	viewController.fieldNames = self.fields;
	viewController.fieldInfo = (NSMutableDictionary *)[self fieldInformationForLandmark:landmark];
	for (NSString *name in viewController.fieldNames){
		if ([[viewController.fieldInfo objectForKey:name]isKindOfClass:[NSNull class]]){
			[viewController.fieldInfo setObject:@"" forKey:name];
		}
	}
	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"imageURL"];
	if (urlString != nil && (![urlString isKindOfClass:[NSNull class]])) {
		viewController.imageURL = [NSURL URLWithString:urlString]; 
	}
	return [viewController autorelease];
}

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	NSDictionary *layerInfo = [layerInfoByLandmarkID objectForKey:landmark.ID];
	NSMutableDictionary *landmarkFieldInfo = [[NSMutableDictionary alloc] init];
	[landmarkFieldInfo setObject:landmark.name forKey:@"Name"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"summary"] forKey:@"Summary"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"usedBy"] forKey:@"Used By"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"scheduleURL"] forKey:@"Schedule URL"];
	//NSLog(@"Field Info: %@", landmarkFieldInfo);
	return [landmarkFieldInfo autorelease];
}

@end

//////////

@implementation SportingArenasViewController

@synthesize imageURL=_imageURL, summaryView=_summaryView, usedByView=_usedByView, scheduleURLView=_scheduleURLView, editPhoto=_editPhoto, photoFrame=_photoFrame, photoLoading=_photoLoading, summary=_summary, usedBy=_usedBy, scheduleURL=_scheduleURL, layer=_layer, landmark=_landmark;

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
	UIImage *image = [UIImage imageWithData:receivedData];
	imageView.image = image;
	[self.photoLoading stopAnimating];
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
	if (self.summary == nil) {
		self.summaryView.text = @"Click 'Edit' to enter a Summary.";
	}
	else {
		self.summaryView.text = self.summary;
	}
	if (self.usedBy == nil) {
		self.usedByView.text = @"Click 'Edit' to enter a list of Sports Teams who use this Facility.";
	}
	else {
		self.usedByView.text = self.usedBy;
	}
	if (self.scheduleURL == nil) {
		self.scheduleURLView.text = @"Click 'Edit' to enter a URL for this Facility's schedule.";
	}
	else {
		self.scheduleURLView.text = self.scheduleURL;
	}
	if (_imageURL) {
		self.editPhoto.text = @"";
		[self.photoFrame setAlpha:0];
	}
	else {
		[self.photoLoading stopAnimating];
		self.editPhoto.text = @"Click 'Edit' to add Photo";
	}
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelectEditButton)];
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

-(void)didSelectEditButton {
	GNEditingTableViewController *editingViewController = (GNEditingTableViewController *)[self.layer getEditingViewControllerWithLocation:self.landmark andLandmark:self.landmark];
	[self.navigationController pushViewController:editingViewController animated:YES];	
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