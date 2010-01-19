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

@synthesize name=_name, active=_active, closestLandmarks=_closestLandmarks;

+(GNLayer*)layerWithName:(NSString*)initName {
	GNLayer *layer = [[[GNLayer alloc] init] autorelease];
	layer.name = initName;
	return layer;
}

-(id)init {
	if (self = [super init]) {
		self.name = nil;
		self.active = NO;
		self.closestLandmarks = [[NSMutableArray alloc] init];
		iconPath = nil;
		layerInfoByLandmark = [[NSMutableDictionary alloc] init];
	}
	return self;
}

//////////////////// -(NSIcon) getIcon;

- (void)updateToCenterLocation:(CLLocation *)location {
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
    // The response has started, clear out the recievedData
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the incoming data
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[connection release];
	[receivedData release];
	
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
}

- (void)ingestNewData:(NSData *)data {
	[self doesNotRecognizeSelector:_cmd];
}

- (NSMutableArray *)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Removes this layer from the active layers list of each of its closest landmarks
// Sets this layer's list of closest landmarks to a new empty NSMutableArray
// and returns the previous closestLandmarks list (autoreleased)
- (NSMutableArray *)removeSelfFromLandmarks {
	for (GNLandmark *landmark in self.closestLandmarks) {
		[landmark removeActiveLayer:self];
	}
	
	NSMutableArray *prev = [self.closestLandmarks copy];
	[self.closestLandmarks removeAllObjects];
	return [prev autorelease];
}

// Returns a short string summarizing the layer information
// for the given landmark
- (NSString *)summaryForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

// Returns a UIViewController displaying the layer information
// for the given landmark
- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayer name: %@, active: %@>", self.name, self.active ? @"YES" : @"NO"];
}

-(void)dealloc {
	[self.name release];
	[self.closestLandmarks release];
	[iconPath release];
	[layerInfoByLandmark release];
	[center release];
	
	[super dealloc];
}

@end


//@implementation GNDistAndLandmark
//
//@synthesize dist=_dist, landmark=_landmark;
//
//+(GNDistAndLandmark*)gndlWithDist:(float)initDist andLandmark:(GNLandmark*)initLandmark {
//	GNDistAndLandmark *gndl = [[[GNDistAndLandmark alloc] init] autorelease];
//	gndl.dist = initDist;
//	gndl.landmark = initLandmark;
//	return gndl;
//}
//
//-(NSComparisonResult)compareTo:(GNDistAndLandmark*)gndl {
//	if(self.dist < gndl.dist)
//		return NSOrderedAscending;
//	else if(self.dist > gndl.dist)
//		return NSOrderedDescending;
//	else
//		return NSOrderedSame;
//}
//
//- (NSString *)description {
//	return [NSString stringWithFormat:@"Distance: %f, Landmark: %@", self.dist, self.landmark];
//}
//
//@end