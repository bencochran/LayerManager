//
//  GNLayer.m
//  A generalized layer implementation. Does not recognize all methods - must be subclassed.
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "GNLayer.h"

@interface GNLayer ()

- (void)didFinishUpdateRequest:(ASIHTTPRequest *)request;
- (void)updateRequestFailed:(ASIHTTPRequest *)request;
- (void)didFinishEditableLandmarksRequest:(ASIHTTPRequest *)request;

@end


@implementation GNLayer

NSString *const GNLayerUpdateFailed = @"GNLayerUpdateFailed";
NSString *const GNLayerDidStartUpdating = @"GNLayerDidStartUpdating";
NSString *const GNLayerDidFinishUpdating = @"GNLayerDidFinishUpdating";

@synthesize name=_name, landmarks=_landmarks, active=_active;

-(id)init {
	if (self = [super init]) {
		self.name = nil;
		self.landmarks = [[NSMutableArray alloc] init];
		self.active = NO;
		layerInfoByLandmarkID = [[NSMutableDictionary alloc] init];
		iconPath = nil;
		userModifiable = NO;
		layerFields = nil;
		center = nil;
	}
	return self;
}

#pragma mark -
#pragma mark General accessors

- (UIImage *)getIcon {
	if (iconPath == nil) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [UIImage imageNamed:iconPath];
}

- (BOOL)layerIsUserModifiable {
	return userModifiable;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayer name: %@, active: %@>", self.name, self.active ? @"YES" : @"NO"];
}

-(void)dealloc {
	[self.name release];
	[self.landmarks release];
	[layerInfoByLandmarkID release];
	[iconPath release];
	[layerFields release];
	[center release];	
	[super dealloc];
}

#pragma mark -
#pragma mark Might delete
///////////////////////////////// MIGHT DELETE vvvvvvvvvvv

// Removes this layer from the active layers list of each of its closest landmarks
// Clears this layer's list of closest validated landmarks
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

////////////////////////////////// MIGHT DELETE ^^^^^^^^^^^^


#pragma mark -
#pragma mark Updating and accessing validated landmarks

- (void)updateToCenterLocation:(CLLocation *)location {
	if (self.active != YES) {
		// This method should not be called on inactive layers
		NSLog(@"updateToCenterLocation: called on inactive layer %s", [self name]);
		return;
	}
	
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:YES]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishUpdateRequest:)];
	[request setDidFailSelector:@selector(updateRequestFailed:)];
	[request startAsynchronous];
	
	// Send out a notification that this layer started updating
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerDidStartUpdating
														object:self];
}

// Compile an NSURL that will be used to request new data.
// limitToValidated == NO when the landmarks returned by
// this request should be user-modifiable
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Returns an NSURL when given the name of the Layer.
// Gnarus layer subclasses will implement URLForLocation
// simply by calling URLForLocation withLayerName
// >> FOR USE ONLY BY LAYERS USING THE GNARUS SERVER. <<
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
	NSLog(@"URL: %@", urlString);
	return [NSURL URLWithString:urlString];
}

- (void)didFinishUpdateRequest:(ASIHTTPRequest *)request {
	if (self.active) {
		NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
		[self ingestLandmarks:landmarks];
	}
	// Send out a notification that this layer finished updating
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerDidFinishUpdating
														object:self];	
}

- (void)updateRequestFailed:(ASIHTTPRequest *)request {
	// Log the error
	NSLog(@"Connection failed! Error - %@ %@",
          [[request error] localizedDescription],
          [[[request error] userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	// Also send a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLayerUpdateFailed
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[request error], @"error", request, @"request", nil]];
}

// Parse the NSData and return an NSArray of landmarks. The layer should not
// store the landmarks created in this step, but it should store the parsed
// layer information in layerInfoByLandmarkID
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

- (BOOL)containsLandmark:(GNLandmark *)landmark limitToValidated:(BOOL)limitToValidated {
	if (limitToValidated) {
		return [self.landmarks containsObject:landmark];
	} else {
		return ([layerInfoByLandmarkID objectForKey:landmark.ID] != nil);//([self.landmarks containsObject:landmark] || [layerInfoByLandmarkID objectForKey:landmark.ID] != nil);
	}
}

// Returns a UIViewController displaying the layer information for the given landmark
- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

#pragma mark -
#pragma mark Updating and accessing user-modifiable landmarks

- (void)updateEditableLandmarksForLocation:(CLLocation *)location {
	NSLog(@"updateEditableLandmarksForLocation on layer %@", self);
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:NO]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishEditableLandmarksRequest:)];
	[request startAsynchronous];
}

- (void)didFinishEditableLandmarksRequest:(ASIHTTPRequest *)request {
	NSLog(@"Getting editable landmarks for %@ got this response: %@", [self name], [request responseString]);
	NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
	[[GNLayerManager sharedManager] layer:self didUpdateEditableLandmarks:landmarks];
}

- (UIViewController *)getEditingViewControllerWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark; {
	if (![self layerIsUserModifiable])
	{
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [[[GNEditingTableViewController alloc] initWithFields:layerFields andLayer:self andLocation:location andLandmark:landmark] autorelease];
}

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void) postLandmarkArray:(NSArray *)info withLocation:(CLLocation *)location andPhoto:(UIImage *)photo {
	[self doesNotRecognizeSelector:_cmd];
}

- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo {
	[self doesNotRecognizeSelector:_cmd];
}

@end