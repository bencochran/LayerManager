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

@synthesize name=_name, landmarks=_landmarks, active=_active, fields=_fields, serverNamesForFields=_serverNamesForFields, tableNameOnServer=_tableNameOnServer;

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

-(void)postLandmark:(NSMutableDictionary *)updatedInfo withName:(NSString *)landmarkName withLocation:(CLLocation *)location withID:(NSString *)landmarkID andPhoto:(UIImage *)photo{
	NSURL *url = [NSURL URLWithString:@"http://dev.gnar.us/post.py/generalLayer"];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	NSMutableDictionary *landmarkDict = [[NSMutableDictionary alloc]init];
	NSMutableDictionary *layerDict = [[NSMutableDictionary alloc]init];
	//for (NSString *fieldName in self.serverNamesForFields){
	//	[layerDict setObject:@"None" forKey:fieldName];
	//}
	for (NSString *field in updatedInfo){
		NSString *info = [updatedInfo objectForKey:field];
		[layerDict setObject:info forKey:field];
	}
	[layerDict setObject:landmarkID forKey:@"landmarkID"];
	NSString *layerDictString = [layerDict JSONRepresentation];
	//NSLog(@"JSON Layer: %@", layerDictString);
	[request setPostValue:layerDictString forKey:@"layerDict"];
	[request setPostValue:self.tableNameOnServer forKey:@"tableName"];
	[request setPostValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"UDID"];
	[request setPostValue:@"True" forKey:@"hasImage"];
	if(photo) {
		NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(photo, 0.8)];
		[request setData:photoData forKey:@"image"];
	}
	[landmarkDict setObject:landmarkName forKey:@"name"];
	[landmarkDict setObject:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"latitude"];
	[landmarkDict setObject:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"longitude"];
	NSString *landmarkDictString = [landmarkDict JSONRepresentation];
	//NSLog(@"JSON Landmark: %@", landmarkDictString);
	[request setPostValue:landmarkDictString forKey:@"landmarkDict"];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(postRequestDidFail:)];
	[request setDidFinishSelector:@selector(postRequestDidFinish:)];
	//NSLog(@"request postData: %@", [request postData]);
	[request startAsynchronous];
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
#pragma mark Updating and accessing validated landmarks

// Clears this layer's list of closest validated landmarks
- (void)clearValidatedLandmarks {
	[self.landmarks removeAllObjects];
}

// Clears all data stored by this layer that is not currently
// relevant to a validated landmark in _landmarks
- (void)flushNonvalidatedInfo {
	NSMutableArray *IDsToRemove = [[NSMutableArray alloc] init];
	[IDsToRemove addObjectsFromArray:[layerInfoByLandmarkID allKeys]];
	for (GNLandmark *landmark in self.landmarks) {
		[IDsToRemove removeObject:landmark.ID];
	}
	[layerInfoByLandmarkID removeObjectsForKeys:IDsToRemove];
	[IDsToRemove release];
}

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

// Returns an NSURL when given the name of the layer.
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
	//NSLog(@"URL: %@", urlString);
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
	
	// Send out a notification
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
	[self clearValidatedLandmarks];
	[self.landmarks addObjectsFromArray:landmarks];
	[[GNLayerManager sharedManager] layerDidUpdate:self withLandmarks:self.landmarks];	
}

- (BOOL)containsLandmark:(GNLandmark *)landmark limitToValidated:(BOOL)limitToValidated {
	if (limitToValidated) {
		return [self.landmarks containsObject:landmark];
	} else {
		return ([layerInfoByLandmarkID objectForKey:landmark.ID] != nil);
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
	NSLog(@"updateEditableLandmarksForLocation on %@", self.name);
	center = [location retain];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URLForLocation:location limitToValidated:NO]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(didFinishEditableLandmarksRequest:)];
	[request startAsynchronous];
}

- (void)didFinishEditableLandmarksRequest:(ASIHTTPRequest *)request {
	//NSLog(@"Getting editable landmarks for %@ got this response: %@", [self name], [request responseString]);
	NSArray *editableLandmarks = [self parseDataIntoLandmarks:[request responseData]];
	[[GNLayerManager sharedManager] layer:self didUpdateEditableLandmarks:editableLandmarks];
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

- (void)postRequestDidFail:(ASIHTTPRequest *)request {
	NSLog(@"Post request failed with error: %@ %@",
          [[request error] localizedDescription],
          [[[request error] userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)postRequestDidFinish:(ASIHTTPRequest *)request {
	NSLog(@"Post request finished with response: %@", [request responseString]);
}

@end