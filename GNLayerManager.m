//
//  GNLayerManager.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayerManager.h"

@implementation GNLayerManager

NSString *const GNLandmarksUpdated = @"GNLandmarksUpdated";

@synthesize maxLandmarks;

static GNLayerManager *sharedManager = nil;

+ (GNLayerManager*)sharedManager {
	if (sharedManager == nil) {
		sharedManager = [[super allocWithZone:NULL] init];
	}
	return sharedManager;
}

// Prevent someone from attempting to allocate
// our class manually
+ (id)allocWithZone:(NSZone *)zone {
	return [[self sharedManager] retain];
}

// Don't copy
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// Don't actually retain
- (id)retain
{
    return self;
}

// Denotes an object that cannot be released
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (void)release
{
    // Never release
}

// Don't actually add yourself to the pool.
// It's gross in there. Kids pee and stuff.
- (id)autorelease
{
    return self;
}

-(id)init {
	if (self = [super init]) {
		layers = [[NSMutableArray alloc] init];
		allLandmarks = [[NSMutableDictionary alloc] init];
		maxLandmarks = 10;
	}
	return self;
}

// adds the provided layer to the list of layers
-(void)addLayer:(GNLayer*)layer {
	[layers removeObject:layer];
	[layers addObject:layer];
}

// convenience method for adding a layer and simultaneously
// setting its active status
- (void)addLayer:(GNLayer *)layer active:(BOOL)active {
	[self addLayer:layer];
	[self setLayer:layer active:active];
}

// Sets the given layer to the indicated activity.
// If the layer is being set to inactive, removes the layer
// from the landmark's list of active layers. Then remove
// any of that layer's landmarks that have no active layers.
-(void) setLayer:(GNLayer*)layer active:(BOOL)active {
	[layer setActive:active];
	
	if(active == NO)
	{
		for (GNLandmark *landmark in layer.landmarks) {
			if (landmark.activeLayers.count == 0) {
				[allLandmarks removeObjectForKey: landmark.ID];
			}
		}		
		
		[layer removeSelfFromLandmarks];
	}
	
	// Immediately send a notification of updated landmarks in order
	// to remove landmarks that are no longer on an active layer
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.closestLandmarks,@"landmarks",nil]];	
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNToggleManager layers:%@>", layers];
}

- (void)updateToCenterLocation:(CLLocation *)location {
	center = location;
	for (GNLayer *layer in layers) {
		if([layer active]) {
			[layer updateToCenterLocation:location];
		}
	}
}

- (void)updateWithPreviousLocation {
	if (center == nil) {
		// Send an error notification in the future
		return;
	}
	
	for (GNLayer *layer in layers) {
		if([layer active]) {
			[layer updateToCenterLocation:center];
		}
	}
}

- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks {	
	// Send a notification that the landmarks list has been updated.
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.closestLandmarks,@"landmarks",nil]];
}

- (NSArray *)closestLandmarks {
	NSMutableArray* activeLandmarks = [[NSMutableArray alloc] init];
	
	for (GNLandmark *landmark in [allLandmarks allValues]) {
		if (landmark.activeLayers.count > 0) {
			[activeLandmarks addObject:landmark];
		}
	}
	
	[activeLandmarks sortUsingSelector:@selector(compareTo:)];
	
	NSArray* closest = [activeLandmarks objectsAtIndexes:
						 [NSIndexSet indexSetWithIndexesInRange:
						  NSMakeRange(0, MIN([self maxLandmarks], [activeLandmarks count]))]];
	
	NSLog(@"closest: %@", closest);
	
	[activeLandmarks release];
	
	return closest;
}


// if a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(NSString *)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:landmarkID]);
	if(landmark == nil)
	{
		landmark = [GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude];
		[allLandmarks setObject:landmark forKey:landmarkID];
	}
	return landmark;
}

// if a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(NSString *)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:landmarkID]);
	if(landmark == nil)
	{
		landmark = [GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude altitude:altitude];
		[allLandmarks setObject:landmark forKey:landmarkID];
	}
	return landmark;
}

-(void)dealloc {
	[layers release];
	[allLandmarks release];
	
	[super dealloc];
}

@end