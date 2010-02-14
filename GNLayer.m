//
//  GNLayer.m
//  A generalized layer implementation. Does not recognize all methods - must be subclassed.
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "GNLayer.h"
@implementation GNLayer

NSString *const GNLayerUpdateFailed = @"GNLayerUpdateFailed";

@synthesize name=_name, active=_active, landmarks=_landmarks;

-(id)init {
	if (self = [super init]) {
		self.name = nil;
		self.active = NO;
		self.landmarks = [[[NSMutableArray alloc] init] autorelease];
		iconPath = nil;
		layerInfoByLandmarkID = [[NSMutableDictionary alloc] init];
		userModifiable = NO;
		layerFields = nil;
	}
	return self;
}

- (UIImage *) getIcon {
	if (!iconPath) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [UIImage imageNamed:iconPath];
}

- (void)updateToCenterLocation:(CLLocation *)location {
	if (receivedData != nil) {
		// We're already updating, don't start another request
		return;
	}
	
	center = [location retain];
	NSURLRequest *request = [NSURLRequest requestWithURL:[self URLForLocation:location]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		receivedData = [[NSMutableData data] retain];
	} else {
		NSLog(@"Could not create connection");
	}
}

- (NSURL *)URLForLocation:(CLLocation *)location {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // The response has started, clear out the receivedData
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the incoming data
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	[receivedData release];
	receivedData = nil;
	
	// Log it
	NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	// Also fire off a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerUpdateFailed
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error,@"error",nil]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self ingestNewData:receivedData];
	[connection release];
    [receivedData release];
	receivedData = nil;
}

- (void)ingestNewData:(NSData *)data {
	[self doesNotRecognizeSelector:_cmd];
}

// Removes this layer from the active layers list of each of its closest landmarks
// Clears this layer's set of landmarks
- (void)removeSelfFromLandmarks {
	for (GNLandmark *landmark in self.landmarks) {
		[landmark removeActiveLayer:self];
	}
	
	[self.landmarks removeAllObjects];
}

// Returns a short string summarizing the layer information for the given landmark
- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Returns a UIViewController displaying the layer information for the given landmark
- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)layerIsUserModifiable;{
	return userModifiable;
}

- (UIViewController *)getEditingViewControllerWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark; {
	if (![self layerIsUserModifiable])
	{
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [[[GNEditingTableViewController alloc] initWithFields:layerFields andLayer:self andLocation:location andLandmark:landmark] autorelease];
}

- (void) postLandmarkArray:(NSArray *)info withLocation:(CLLocation *)location andPhoto:(UIImage *)photo{
	[self doesNotRecognizeSelector:_cmd];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayer name: %@, active: %@>", self.name, self.active ? @"YES" : @"NO"];
}

-(void)dealloc {
	[self.name release];
	[self.landmarks release];
	[iconPath release];
	[layerInfoByLandmarkID release];
	[layerFields release];
	[center release];	
	[super dealloc];
}

@end