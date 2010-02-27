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
NSString *const GNLayerDidStartUpdating = @"GNLayerDidStartUpdating";
NSString *const GNLayerDidFinishUpdating = @"GNLayerDidFinishUpdating";

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

- (UIImage *)getIcon {
	if (!iconPath) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [UIImage imageNamed:iconPath];
}

// Compile an NSURL that will be used to request new data.
// limitToValidated is YES when we're using the resulting
// landmarks to allow a user to add new landmarks
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Returns an NSURL when given the name of the Layer.
// Subclasses will implement URLForLocation simply by calling URLForLocation withLayerName
// FOR USE ONLY BY LAYERS USING THE GNARUS SERVER.
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated withLayerName:(NSString *)layerName {
	NSString *urlString = nil;
	if (limitToValidated == YES) {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/getInfo.py/%@?udid=%@&lat=%f&lon=%f&maxLandmarks=%d",
					 layerName,
					 [[UIDevice currentDevice] uniqueIdentifier], 
					 [location coordinate].latitude, 
					 [location coordinate].longitude,
					 [[GNLayerManager sharedManager] maxLandmarks]];
	}
	else {
		urlString = [NSString stringWithFormat:@"http://dev.gnar.us/Vote.py/AddingTo%@?lat=%f&lon=%f&maxDistance=%f",
					 layerName,
					 [location coordinate].latitude, 
					 [location coordinate].longitude, 
					 [[GNLayerManager sharedManager] maxDistance]];
	}
	NSLog(@"url: %@", urlString);
	return [NSURL URLWithString:urlString];
}

- (void)updateToCenterLocation:(CLLocation *)location {
	if (self.active != YES) {
		// Well, this shouldn't have happened.
		NSLog(@"updateToCenterLocation: was called on %s, which is inactive", [self name]);
		return;
	}
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:YES]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishUpdateRequest:)];
	[request setDidFailSelector:@selector(updateRequestFailed:)];
	[request startAsynchronous];
	
	// Let it be known that this layer started updating
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerDidStartUpdating
														object:self];
}

- (void)didFinishUpdateRequest:(ASIHTTPRequest *)request {
	if (self.active) {
		NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
		[self ingestLandmarks:landmarks];
	}
	// Let it be known that this layer finished updating
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerDidFinishUpdating
														object:self];	
}

- (BOOL)containsLandmark:(GNLandmark *)landmark limitToValidated:(BOOL)limitToValidated {
	if (limitToValidated) {
		return [self.landmarks containsObject:landmark];
	} else {
		return ([self.landmarks containsObject:landmark] || [layerInfoByLandmarkID objectForKey:landmark.ID] != nil);
	}
}

// Parse the NSData and return an NSArray of landmarks the layer should not
// store the landmarks created in this step, that will happen elsewhere
-(NSArray *)parseDataIntoLandmarks:(NSData *)data {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)ingestLandmarks:(NSArray *)landmarks {
	[self removeSelfFromLandmarks];
	
	for (GNLandmark *landmark in landmarks)
	{		
		[landmark addActiveLayer:self];
		[self.landmarks addObject:landmark];
	}
	
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];	
}

- (void)updateEditableLandmarksForLocation:(CLLocation *)location {
	NSLog(@"updateEditableLandmarksForLocation on layer %@", self);
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:NO]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishEditableLandmarksRequest:)];
	[request startAsynchronous];
}

- (void)didFinishEditableLandmarksRequest:(ASIHTTPRequest *)request {
	NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
	NSLog(@"got this response: %@", [request responseString]);
	[[GNLayerManager sharedManager] layer:self didUpdateEditableLandmarks:landmarks];
}

- (void)updateRequestFailed:(ASIHTTPRequest *)request {
	// Log it
	NSLog(@"Connection failed! Error - %@ %@",
          [[request error] localizedDescription],
          [[[request error] userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	// Also fire off a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerUpdateFailed
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[request error], @"error", request, @"request", nil]];
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
// (Should be displayed below the layer name in the LayersListViewController)
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

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayer name: %@, active: %@>", self.name, self.active ? @"YES" : @"NO"];
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo {
	[self doesNotRecognizeSelector:_cmd];
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