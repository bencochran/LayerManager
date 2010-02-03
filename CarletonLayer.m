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
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location {	
	// http://dev.gnar.us/getInfo.py/CarletonBuildings?lat=44.46055309703&lon=-93.1566672394&maxLandmarks=2
	NSString *urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/CarletonBuildings?lat=%f&lon=%f&maxLandmarks=%d",
						   [location coordinate].latitude, [location coordinate].longitude, [[GNLayerManager sharedManager] maxLandmarks]];
	return [NSURL URLWithString:urlString];
}

- (void)ingestNewData:(NSData *)data {
	[self removeSelfFromLandmarks];
	[layerInfoByLandmarkID removeAllObjects];
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	SBJSON *parser = [[SBJSON alloc] init];
	NSArray *layerInfoList = [parser objectWithString:reply error:nil];
	[reply release];
	[parser release];
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	
	for (NSDictionary *landmarkAndLayerInfo in layerInfoList)
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"imageURL"] forKey:@"imageURL"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"summary"] forKey:@"summary"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"yearBuilt"] forKey:@"yearBuilt"];
		[layerInfo setObject:[landmarkAndLayerInfo objectForKey:@"description"] forKey:@"description"];
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"gnarus:%@",[landmarkAndLayerInfo objectForKey:@"ID"]]
														  name:[landmarkAndLayerInfo objectForKey:@"name"]
													  latitude:[[landmarkAndLayerInfo objectForKey:@"latitude"] floatValue]
													 longitude:[[landmarkAndLayerInfo objectForKey:@"longitude"] floatValue]
													  altitude:center.altitude];
  		landmark.distance = [[landmarkAndLayerInfo objectForKey:@"distance"] floatValue];
		
		if (self.active) {
			[landmark addActiveLayer:self];
			NSLog(@"Added %@", landmark.name);
		} else {
			NSLog(@"Ignored %@", landmark.name);
		}
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[self.landmarks addObject:landmark];
		[layerInfo release];
	}
	
	[self.landmarks sortUsingSelector:@selector(compareTo:)];
	// Inform the LayerManager that we've got new landmarks
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return [(NSDictionary*) [layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"summary"];
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	CarletonViewController *viewController = [[CarletonViewController alloc] init];
//	CarletonBuildingsViewController *viewController = [[CarletonBuildingsViewController alloc] initWithCoder:nil];
	
	viewController.buildingName = landmark.name;
	viewController.description = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"description"];
	
	NSString *urlString = [[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"imageURL"];
	
	if (urlString != nil) {
		viewController.imageURL = [NSURL URLWithString:urlString]; 
	}
	
	NSLog(@"landmark: %@", landmark);
	NSLog(@"all layer info: %@", layerInfoByLandmarkID);
	NSLog(@"layer info: %@", [layerInfoByLandmarkID objectForKey:landmark.ID]);
	NSLog(@"urlString: %@", urlString);
	
	return [viewController autorelease];
}

@end

//////////

@implementation CarletonViewController

@synthesize imageURL=_imageURL, buildingName=_buildingName, description=_description;

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
		// Create the NSMutableData that will hold
		// the received data
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

- (void)setBuildingName:(NSString *)name {
	if (_buildingName != nil) [_buildingName release];
	_buildingName = [name copy];
	buildingNameLabel.text = _buildingName;
}

- (void)description:(NSString *)description {
	if (_description != nil) [_description release];
	_description = [description copy];
	if (_description != nil) {
		descriptionView.text = _description;
	} else {
		descriptionView.text = @"I'll assume this building is great."; 
	}

}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	buildingNameLabel.text = self.buildingName;
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