//
//  GNLayerManager.m
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GNLayerManager.h"

@implementation GNLayerManager

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
		distAndLandmarkList = [[NSMutableArray alloc] init];
		allLandmarks = [[NSMutableDictionary alloc] init];
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
		NSMutableArray *layerLandmarks = [layer removeSelfFromLandmarks];
		GNDistAndLandmark *gndl;
		int i;
		for(i = 0; i < [layerLandmarks count]; i++)
		{
			gndl = (GNDistAndLandmark*) [layerLandmarks objectAtIndex:i];
			if([gndl.landmark getNumActiveLayers] == 0)
			{
				[allLandmarks removeObjectForKey:[NSNumber numberWithInt:[gndl.landmark ID]]];
				[distAndLandmarkList removeObject:gndl];
				[gndl.landmark release];
				[gndl release];
			}
		}
	}
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GNToggleManager layers:%@>", layers];
}

// calls getNClosestLandmarks on each layer in the list of layers simultaneously
// returns a list of GNDistAndLandmarks, sorted in increasing order by distance,
// of the n closest landmarks (closer than maxDistance) returned by at least one layer
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location maxDistance:(float)maxDistance {
	NSMutableArray *result;
	GNDistAndLandmark *gndl;
	int i;
	
	// clear active layers for all landmarks
	NSArray *allLandmarksList = [allLandmarks allValues];
	for(i = 0; i < [allLandmarksList count]; i++)
		[(GNLandmark*) [allLandmarksList objectAtIndex:i] clearActiveLayers];
	
	// release all GNDistAndLandmarks and clear last list of closest landmarks
	for(i = 0; i < [distAndLandmarkList count]; i++)
		[[distAndLandmarkList objectAtIndex:i] release];
	[distAndLandmarkList removeAllObjects];
	
	///////////////////////////// TODO: ADD THREADING HERE 
	// add all GNDistAndLandmarks to distAndLandmarkList
	GNLayer *layer;
	for(layer in layers)
		if([layer active])
			[distAndLandmarkList addObjectsFromArray:[layer getNClosestLandmarks:n toLocation:location withLM:self]];
		//////////////////////// PROBLEM: CURRENTLY ADDING DUPLICATE LANDMARKS (if landmark is part of 2 layers, will be added twice)
		//////////////////////// ALSO, WANT ALL LAYERS THAT HAVE A POINTER TO THE SAME LANDMARK TO HAVE POINTERS TO THE SAME GNDistAndLandmark
	
	// sort distAndLandmarkList
	[distAndLandmarkList sortUsingSelector:@selector(compareTo:)];
	
	// return top n closest landmarks that are closer than maxDistance
	result = [[NSMutableArray alloc] init];
	for(i = 0; i < MIN(n,[distAndLandmarkList count]); i++)
	{
		gndl = [distAndLandmarkList objectAtIndex:i];
		if(gndl.dist <= maxDistance)
			[result addObject:gndl];
		else
			break;
	}
	
	return result;
}

// if a landmark with the given ID exists in the allLandmarks NSMutableDictionary, returns that GNLandmark
// otherwise, creates the GNLandmark with the given attributes, adds it to allLandmarks, and returns it
-(GNLandmark*)getLandmark:(int)landmarkID name:(NSString*)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
	GNLandmark *landmark = (GNLandmark*) ([allLandmarks objectForKey:[NSNumber numberWithInt:landmarkID]]);
	if(landmark == nil)
	{
		landmark = [[GNLandmark landmarkWithID:landmarkID name:landmarkName latitude:latitude longitude:longitude] autorelease];
		[allLandmarks setObject:landmark forKey:[NSNumber numberWithInt:landmarkID]];
	}
	return landmark;
}

-(void)dealloc {
	NSArray *allLandmarksList;
	int i;
	
	// release each layer and the layer list
	for(i = 0; i < [layers count]; i++)
		[[layers objectAtIndex:i] release];
	[layers release];
	
	// release each GNDistAndLandmark
	for(i = 0; i < [distAndLandmarkList count]; i++)
		[[distAndLandmarkList objectAtIndex:i] release];
	[distAndLandmarkList release];
	
	// dealloc each GNLandmark
	allLandmarksList = [allLandmarks allValues];
	
	for(i = 0; i < [allLandmarksList count]; i++)
		[[allLandmarksList objectAtIndex:i] release];
	[allLandmarks dealloc];
	
	[super dealloc];
}

@end