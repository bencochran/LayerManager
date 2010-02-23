//
//  FlickrLayer.m
//  LayerManager
//
//  Created by Jake Kring on 2/20/10.
//  Copyright 2010 Gnarus. All rights reserved.
//

#import "FlickrLayer.h"

@implementation FlickrLayer 

-(id)init {
	if (self = [super init]) {
		self.name = @"Flickr";
		iconPath = @"flickr.png";
		userModifiable = NO;
	}
	return self;
}

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	NSTimeInterval minUploadDate = [[NSDate date] timeIntervalSince1970]-1*60*60*24*100;
	NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&has_geo=1&lat=%f&lon=%f&radius=2&api_key=508f5e95cf2b731546019a71fbcbe992&min_upload_date=%f&extras=geo,url_sq,url_m&format=json",
					   [location coordinate].latitude,
					   [location coordinate].longitude,
						   minUploadDate];
	NSLog(@"url: %@", urlString);
	return [NSURL URLWithString:urlString];
}

- (NSArray *)parseDataIntoLandmarks:(NSData *)data {	
	NSString *reply = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	// Hacky hacky hacky
	// Take off the jsonFlickrApi() wrapper
	reply = [reply substringWithRange:NSMakeRange(14, [reply length] - 15)];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSDictionary *layerInfoList = [parser objectWithString:reply error:nil];
	[parser release]; parser = nil;
	
	// load the distance and landmark info
	NSMutableDictionary *layerInfo;
	GNLandmark *landmark;
	NSString *landmarkName;
	NSString *photoID;
	NSString *photoOwner;
	CLLocationDegrees landmarkLon;
	CLLocationDegrees landmarkLat;
	NSURL *imageURL;
	NSURL *thumbnailURL;
	NSMutableArray *landmarks = [NSMutableArray array];
	NSLog(@"number of photos: %i", [[[layerInfoList objectForKey:@"photos"] objectForKey:@"photo"] count]);
	
	for (NSDictionary *landmarkAndLayerInfo in [[layerInfoList objectForKey:@"photos"] objectForKey:@"photo"])
	{
		layerInfo = [[NSMutableDictionary alloc] init];
		landmarkName = [landmarkAndLayerInfo objectForKey:@"title"];
		landmarkLat = [(NSNumber *)[landmarkAndLayerInfo objectForKey:@"latitude"] doubleValue];
		landmarkLon = [(NSNumber *)[landmarkAndLayerInfo objectForKey:@"longitude"] doubleValue];
		photoID = [landmarkAndLayerInfo objectForKey:@"id"];
		photoOwner = [landmarkAndLayerInfo objectForKey:@"owner"];
		imageURL = [NSURL URLWithString:[landmarkAndLayerInfo objectForKey:@"url_m"]];
		thumbnailURL = [NSURL URLWithString:[landmarkAndLayerInfo objectForKey:@"url_sq"]]; 
		NSLog(@"Title: %@",landmarkName);
		NSLog(@"ID: %@",photoID);
		NSLog(@"Owner: %@",photoOwner);
		NSLog(@"Long: %f",landmarkLon);
		NSLog(@"Lat: %f",landmarkLat);
		NSLog(@"Image URL: %@",imageURL);
		NSLog(@"Thumbnail ULR: %@",thumbnailURL);
		
		[layerInfo setObject:photoID forKey:@"photoID"];
		[layerInfo setObject:photoOwner forKey:@"photoOwner"];
		[layerInfo setObject:imageURL forKey:@"imageURL"];
		[layerInfo setObject:thumbnailURL forKey:@"thumbnailURL"];	
		
		landmark = [[GNLayerManager sharedManager] getLandmark:[NSString stringWithFormat:@"flickr:%@", photoID]
														  name:landmarkName
													  latitude:landmarkLat
													 longitude:landmarkLon
													  altitude:center.altitude];
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		
		// calculate distance
		landmark.distance = [landmark getDistanceFrom:center];
		
		[layerInfoByLandmarkID setObject:layerInfo forKey:landmark.ID];
		[layerInfo release]; layerInfo = nil;
		[landmarks addObject:landmark];
	}	
	return landmarks;
}

- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	return @"Flickr photos have no Summary";
}

- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	FlickrViewController *viewController = [[FlickrViewController alloc] init];
	[viewController setImageURL:[[layerInfoByLandmarkID objectForKey:landmark.ID] objectForKey:@"imageURL"]];
	viewController.title = landmark.name;
	return viewController;
}

@end

//////////

@implementation FlickrViewController

@synthesize imageURL=_imageURL, landmark=_landmark, layer=_layer;

- (id)init {
	if (self = [super initWithNibName:@"FlickrView" bundle:nil]) {
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
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[super viewDidLoad];
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