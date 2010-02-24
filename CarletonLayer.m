//
//  CarletonLayer.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "CarletonLayer.h"
#import "JSON.h"

@implementation CarletonLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Carleton";
		iconPath = @"academic.png";
		userModifiable = YES;
		NSArray *nameField = [[NSMutableArray alloc] initWithObjects:@"Name", @"textField", nil];
		NSArray *yearBuiltField = [[NSMutableArray alloc] initWithObjects:@"Year Built", @"textField", nil];
		NSArray* summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *descriptionField = [[NSMutableArray alloc] initWithObjects:@"Description", @"textView", nil];
		layerFields = [[NSArray alloc] initWithObjects:nameField, yearBuiltField, summaryField, descriptionField, nil];
		[nameField release];
		[yearBuiltField release];
		[summaryField release];
		[descriptionField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {	
	// http://dev.gnar.us/getInfo.py/Carleton?lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	///////////////////////// TODO: limitToValidated
	/*NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/Carleton?udid=%@&lat=%f&lon=%f&maxLandmarks=%d", 
						   [[UIDevice currentDevice] uniqueIdentifier], 
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxLandmarks]];
	return [NSURL URLWithString:urlString];*/
	return [self URLForLocation:location limitToValidated:limitToValidated withLayerName:@"Carleton"];
}

- (NSArray *)parseDataIntoLandmarks:(NSData *)data {
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release];
	[parser release];
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	NSMutableArray *landmarks = [NSMutableArray array];
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"yearBuilt"] forKey:@"yearBuilt"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@",[landmarkAndLayerInfo objectForKey:@"id"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
				
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[self.landmarks addObject:landmark];
		[layerInfo release];
		[landmarks addObject:landmark];
	}
	
	return landmarks;
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/carleton"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[info objectAtIndex:0] forKey:@"name"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"yearBuilt"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"description"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setPostValue:landmarkID forKey:@"landmarkID"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
	[request setData:photoData forKey:@"image"];
	[request startAsynchronous];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	CarletonViewController *viewController = [[CarletonViewController alloc] init];
	viewController.title = landmark.name;
	viewController.description = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"description"];
	viewController.summary = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
	viewController.yearBuilt = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"yearBuilt"];
	viewController.layer = self;
	viewController.landmark = landmark;
	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"imageURL"];
	
	if (urlString != nil) {
		viewController.imageURL = [NSURL URLWithString:urlString]; 
	}
	
	NSLog(@"landmark: %@", landmark);
	NSLog(@"layer info: %@", [layerInfoByLandmarkID objectForKey:landmark.ID]);
	NSLog(@"urlString: %@", urlString);
	
	return [viewController autorelease];
}

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	NSDictionary *layerInfo = [layerInfoByLandmarkID objectForKey:landmark.ID];
	NSMutableDictionary *landmarkFieldInfo = [[NSMutableDictionary alloc] init];
	[landmarkFieldInfo setObject:landmark.name forKey:@"Name"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"yearBuilt"] forKey:@"Year Built"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"summary"] forKey:@"Summary"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"description"] forKey:@"Description"];
	[landmarkFieldInfo setObject:[layerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
	
	NSLog(@"fieldInformationForLandmark, landmarkFieldInfo: %@", landmarkFieldInfo);
	
	return [landmarkFieldInfo autorelease];
}

@end

//////////

@implementation CarletonViewController

@synthesize imageURL=_imageURL, descriptionView=_descriptionView, description=_description, summaryView=_summaryView, summary=_summary, yearBuiltView=_yearBuiltView, yearBuilt=_yearBuilt, editPhoto=_editPhoto, landmark=_landmark, layer=_layer;

- (id)init {
	if (self = [super initWithNibName:@"CarletonView" bundle:nil]) {
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
	if (self.description == nil){
		self.descriptionView.text = @"Click 'Edit' to enter a Description.";
	}
	else{
		self.descriptionView.text = self.description;
	}
	if (self.summary == nil){
		self.summaryView.text = @"Click 'Edit' to enter a Summary.";
	}
	else{
		self.summaryView.text = self.summary;
	}
	if (self.yearBuilt == nil){
		self.yearBuiltView.text = @"Click 'Edit' if you know when this was built.";
	}
	else{
		self.yearBuiltView.text = self.yearBuilt;
	}
	if (_imageURL){
		self.editPhoto.text = @"";
	}
	else{
		self.editPhoto.text = @"Click 'Edit' to add Photo";	
	}
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didSelectEditButton)];
	[self.navigationItem setRightBarButtonItem:editButton animated:YES];
}

- (void)didSelectEditButton{
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