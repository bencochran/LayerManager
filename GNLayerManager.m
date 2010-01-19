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
		closestLandmarks = [[NSMutableArray alloc] init];
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

// sets the given layer to the indicated activity
// if the layer is being set to inactive, removes this layer
// from its landmarks' lists of active layers,
// and clears the layer's closestLandmarks list
// if any landmark has no more active layers, removes the
// appropriate GNDistAndLandmark from the distAndLandmarksList,
// removes the landmark from allLandmarks, and releases
// both the GNLandmark and the GNDistAndLandmark
-(void) setLayer:(GNLayer*)layer active:(BOOL)active {
	[layer setActive:active];
	
	if(active == NO)
	{
		NSArray *layerLandmarks = [layer removeSelfFromLandmarks];
		
		for (GNLandmark *landmark in layerLandmarks) {
			if ([landmark getNumActiveLayers] == 0) {
				[allLandmarks removeObjectForKey:
				 [NSNumber numberWithInt:landmark.ID]];
				
				[closestLandmarks removeObject:landmark];
			}
		}
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNToggleManager layers:%@>", layers];
}

- (void)updateToCenterLocation:(CLLocation *)location {
	for (GNLayer *layer in layers) {
		if([layer active]) {
			[layer updateToCenterLocation:location];
		}
	}
}

- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks {
	GNLandmark *landmark;
	
	// merge them into the main array
	for (landmark in landmarks) {
		if (![closestLandmarks containsObject:landmark]) {
			[closestLandmarks addObject:landmark];
		}
	}
	
	NSMutableArray *landmarksToRemove = [NSMutableArray array];
	for (landmark in closestLandmarks) {
		if (landmark.activeLayers.count < 1) {
			[landmarksToRemove addObject:landmark];
		}
	}
	[closestLandmarks removeObjectsInArray:landmarksToRemove];
	
	// Sort the closest landmarks
	[closestLandmarks sortUsingSelector:@selector(compareTo:)];
	
	NSArray* closestN = [closestLandmarks objectsAtIndexes:
						 [NSIndexSet indexSetWithIndexesInRange:
						  NSMakeRange(0, MIN([self maxLandmarks], [closestLandmarks count]))]];
	
	
	// Send a notification that the landmarks list has been updated.
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:closestN,@"landmarks",nil]];
}


// if a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(int)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:[NSNumber numberWithInt:landmarkID]]);
	if(landmark == nil)
	{
		landmark = [GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude];
		[allLandmarks setObject:landmark forKey:[NSNumber numberWithInt:landmarkID]];
	}
	return landmark;
}

- (NSUInteger)getSizeofClosestLandmarks{
	return [closestLandmarks count];
}

-(void)dealloc {
	[layers release];
	[allLandmarks release];
	[closestLandmarks release];
	
	[super dealloc];
}

@end