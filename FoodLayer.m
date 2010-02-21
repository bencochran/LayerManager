//
//  FoodLayer.m
//  LayerManager
//
//  Created by iComps on 11/16/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "FoodLayer.h"
#import "JSON.h"

@implementation FoodLayer

-(id)init {
	if (self = [super init]) {
		self.name = @"Food";
		iconPath = @"food.png";
		userModifiable = YES;
		NSArray *nameField = [[NSMutableArray alloc] initWithObjects:@"Name", @"textField", nil];
		NSArray *hoursField = [[NSMutableArray alloc] initWithObjects:@"Hours", @"textView", nil];
		NSArray *summaryField = [[NSMutableArray alloc] initWithObjects:@"Summary", @"textField", nil];
		NSArray *descriptionField = [[NSMutableArray alloc] initWithObjects:@"Description", @"textView", nil];
		NSArray *menuField = [[NSMutableArray alloc] initWithObjects:@"Menu", @"textView", nil];
		layerFields = [[NSArray alloc] initWithObjects:nameField, hoursField, summaryField, descriptionField, menuField, nil];
		[nameField release];
		[hoursField release];
		[summaryField release];
		[descriptionField release];
		[menuField release];
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	// http://dev.gnar.us/getInfo.py/Food?lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	// TODO: add limitToValidated stuff
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/Food?udid=%@&lat=%f&lon=%f&maxLandmarks=%d", 
						   [[UIDevice currentDevice] uniqueIdentifier], 
						   [location coordinate].latitude, 
						   [location coordinate].longitude, 
						   [[GNLayerManager sharedManager] maxLandmarks]];
	return [NSURL URLWithString:urlString];
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
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"menu"] forKey:@"menu"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@", [landmarkAndLayerInfo objectForKey:@"ID"]]
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

- (void) postLandmarkArray:(NSArray *)info withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/food"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	NSLog(@"Info: %@", info);
	[request setPostValue:[info objectAtIndex:0] forKey:@"name"];
	[request setPostValue:[info objectAtIndex:1] forKey:@"hours"];
	[request setPostValue:[info objectAtIndex:2] forKey:@"summary"];
	[request setPostValue:[info objectAtIndex:3] forKey:@"description"];
	[request setPostValue:[info objectAtIndex:4] forKey:@"menu"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
	[request setPostValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"lon"];
	[request setData:photoData forKey:@"foodImage"];
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
	UIViewController *viewController = [[UIViewController alloc] init];
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
	NSMutableDictionary *landmarkInfo = [[NSMutableDictionary alloc] init];
	NSLog(@"fieldInformationForLandmark, entire dictionary: %@", layerInfoByLandmarkID);
	NSLog(@"fieldInformationForLandmark, hours value: %@", [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"hours"]);
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"hours"] forKey:@"Hours"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"] forKey:@"Summary"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"description"] forKey:@"Description"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"menu"] forKey:@"Menu"];
	//[landmarkInfo setObject:[(NSDictionary*)[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"name"] forKey:@"Name"];	
	return [landmarkInfo autorelease];
}

@end

//////////

@implementation FoodViewController

@synthesize imageURL=_imageURL, name=_name, hours=_hours, summary=_summary, description=_description, menu=_menu;

- (id)init {
	if (self = [super initWithNibName:@"FoodView" bundle:nil]) {
		
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
	nameLabel.text = self.name;
	if (self.description != nil) {
		descriptionView.text = self.description;
	}
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