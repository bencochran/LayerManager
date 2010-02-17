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

- (UIImage *)getIcon {
	if (!iconPath) {
		[self doesNotRecognizeSelector:_cmd];
		return nil;
	}
	return [UIImage imageNamed:iconPath];
}

// Compile a NSURL that will be used to request new data.
// limitToValidated is YES when we're using the resulting
// landmarks to allow a user to add new landmarks
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)updateToCenterLocation:(CLLocation *)location {
	if (self.active != YES) {
		// Well, this shouldn't have happened.
		NSLog(@"updateToCenterLocation: was called on %s, which is inavtive", [self name]);
		return;
	}
	
	NSLog(@"called update to center location on %@", self.name);
	
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:YES]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishUpdateRequest:)];
	[request startAsynchronous];
}

- (void)didFinishUpdateRequest:(ASIHTTPRequest *)request {
	NSLog(@"called didFinishUpdateRequest on %@", self.name);
	NSLog(@"request data %s", [request responseString]);

	if (self.active) {
		NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
		[self ingestLandmarks:landmarks];
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

- (void)requestEditableLandmarksForLocation:(CLLocation *)location {	
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:NO]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishEditableLandmarksRequest:)];
	[request startAsynchronous];
}

- (void)didFinishEditableLandmarksRequest:(ASIHTTPRequest *)request {
	NSArray *landmarks = [self parseDataIntoLandmarks:[request responseData]];
	
	[[GNLayerManager sharedManager] layer:self didUpdateEditableLandmarks:landmarks];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
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