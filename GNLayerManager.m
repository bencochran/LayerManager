//
//  GNLayerManager.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import "GNLayerManager.h"

@implementation GNLayerManager

NSString *const GNLandmarksUpdated = @"GNLandmarksUpdated";
NSString *const GNEditableLandmarksUpdated = @"GNEditableLandmarksUpdated";

@synthesize maxLandmarks, maxDistance, userEditableLandmarks;

static GNLayerManager *sharedManager = nil;

+ (GNLayerManager*)sharedManager {
	if (sharedManager == nil) {
		sharedManager = [[super allocWithZone:nil] init];
	}
	return sharedManager;
}

// Prevent someone from attempting to allocate our class manually
+ (id)allocWithZone:(NSZone *)zone {
	return [[self sharedManager] retain];
}

// Don't copy
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Don't actually retain
- (id)retain {
    return self;
}

// Denotes an object that cannot be released
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (void)release {
    // Never release
}

// Don't actually add yourself to the pool.
// It's gross in there. Kids pee and stuff.
- (id)autorelease {
    return self;
}

-(id)init {
	if (self = [super init]) {
		layers = [[NSMutableArray alloc] init];
		allLandmarks = [[NSMutableDictionary alloc] init];
		validatedLandmarks = [[NSMutableArray alloc] init];
		userEditableLandmarks = [[NSMutableArray alloc] init];
		maxLandmarks = 10;
		maxDistance = 100;
		center = nil;
	}
	return self;
}

- (NSArray *)layers {
	return [[layers copy] autorelease];
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
// If the layer is being set to inactive, clears that layer's
// list of validated landmarks and flushes its nonvalidated info.
// Then removes any landmarks that have no active layers from
// validatedLandmarks and allLandmarks.
// >>> Note: Cannot be called while in editing mode
-(void) setLayer:(GNLayer*)layer active:(BOOL)active {
	[layer setActive:active];
	
	if(active == NO)
	{
		for (GNLandmark *landmark in layer.landmarks) {
			BOOL landmarkInUse = NO;
			for (GNLayer *currLayer in self.layers) {
				if(currLayer != layer && [currLayer containsLandmark:landmark limitToValidated:YES]) {
					landmarkInUse = YES;
					break;
				}
			}
			if (!landmarkInUse) {
				// no layers are storing information on this landmark - remove it
				[validatedLandmarks removeObject:landmark];
				[allLandmarks removeObjectForKey:landmark.ID];
			}
		}
		
		[layer clearValidatedLandmarks];
		[layer flushNonvalidatedInfo];
	}
	
	// Immediately send a notification of updated landmarks in order
	// to remove landmarks that are no longer on an active layer
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.closestLandmarks,@"landmarks",nil]];	
}

// Clears all information on all layers not currently relevant to validated landmarks
// Clears userEditableLandmarks and updates allLandmarks to only contain validated landmarks
- (void)flushAllNonvalidatedInfo {
	for (GNLayer *layer in self.layers) {
		[layer flushNonvalidatedInfo];
	}
	
	[userEditableLandmarks removeAllObjects];
	NSMutableArray *IDsToRemove = [[NSMutableArray alloc] init];
	[IDsToRemove addObjectsFromArray:[allLandmarks allKeys]];
	for (GNLandmark *landmark in validatedLandmarks) {
		[IDsToRemove removeObject:landmark.ID];
	}
	[allLandmarks removeObjectsForKeys:IDsToRemove];
	[IDsToRemove release];
}

// If a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(NSString *)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:landmarkID]);
	if(landmark == nil)
	{
		landmark = [GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude];
		[allLandmarks setObject:landmark forKey:landmark.ID];
	}
	return landmark;
}

// If a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(NSString *)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:landmarkID]);
	if(landmark == nil)
	{
		landmark = [GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude altitude:altitude];
		[allLandmarks setObject:landmark forKey:landmark.ID];
	}
	return landmark;
}

- (NSArray *)closestLandmarks {
	[validatedLandmarks sortUsingSelector:@selector(compareTo:)];
	
	// TODO: Cap to maxDistance?
	NSArray *closest = [validatedLandmarks objectsAtIndexes:
						[NSIndexSet indexSetWithIndexesInRange:
						 NSMakeRange(0, MIN([self maxLandmarks], [validatedLandmarks count]))]];	
	return closest;
}

- (NSArray *)activeLayersForLandmark:(GNLandmark *)landmark {
	NSMutableArray *layersForLandmark = [NSMutableArray array];
	for (GNLayer *layer in self.layers) {
		if (layer.active && [layer containsLandmark:landmark limitToValidated:YES]) {
			[layersForLandmark addObject:layer];
		}
	}
	return layersForLandmark;
}

- (NSArray *)layersForLandmark:(GNLandmark *)landmark {
	NSMutableArray *layersForLandmark = [NSMutableArray array];
	for (GNLayer *layer in self.layers) {
		if ([layer containsLandmark:landmark limitToValidated:NO]) {
			[layersForLandmark addObject:layer];
		}
	}
	return layersForLandmark;
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
	NSLog(@"Layer updated with validated landmarks: %@", layer.name);
	NSLog(@"Layer returned these validated landmarks: %@", landmarks);

	for (GNLandmark *landmark in landmarks) {
		if (![validatedLandmarks containsObject:landmark]) {
			[validatedLandmarks addObject:landmark];
		}
	}
		
	// Send a notification that the landmarks list has been updated.
	[[NSNotificationCenter defaultCenter] postNotificationName:GNLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.closestLandmarks,@"landmarks",nil]];
}

- (void)updateEditableLandmarksForLocation:(CLLocation *)location {
	for (GNLayer *layer in layers) {
		if([layer layerIsUserModifiable]) {
			[layer updateEditableLandmarksForLocation:location];
		}
	}
}

- (void)layer:(GNLayer *)layer didUpdateEditableLandmarks:(NSArray *)landmarks {
	//NSLog(@"Preexisting user editable landmarks: %@", userEditableLandmarks);
	NSLog(@"Layer %@ updated with %i editable landmarks", layer.name, [landmarks count]);
	
	for (GNLandmark *landmark in landmarks) {
		if (![userEditableLandmarks containsObject:landmark]) {
			[userEditableLandmarks addObject:landmark];
		}
	}
	
	// Send a notification that  has been updated.
	[[NSNotificationCenter defaultCenter] postNotificationName:GNEditableLandmarksUpdated
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:userEditableLandmarks,@"landmarks",nil]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNLayerManager layers:%@>", layers];
}

-(void)dealloc {
	[layers release];
	[allLandmarks release];
	[userEditableLandmarks release];
	[super dealloc];
}

@end