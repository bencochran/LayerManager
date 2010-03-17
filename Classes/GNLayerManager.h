//
//  GNLayerManager.h
//  Manages all landmarks and layers.
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"
#import "GNLandmark.h"

// Strings for indicating that new validated / unvalidated landmarks are available
extern NSString *const GNLandmarksUpdated;
extern NSString *const GNEditableLandmarksUpdated;

@interface GNLayerManager : NSObject {
	// all layers, in the order they were added to the layer manager
	NSMutableArray *layers;
	// allLandmarks: key = landmark ID, value = GNLandmark
	NSMutableDictionary *allLandmarks;
	// the compiled, sorted list of all validated landmarks
	// returned by all active layers after the last location update
	NSMutableArray *validatedLandmarks;
	// the compiled, sorted list of all landmarks returned
	// by all user-modifiable layers (used when editing landmarks)
	NSMutableArray *userEditableLandmarks;
	// The hard-coded maximum number of landmarks to retreive
	int maxLandmarks;
	// The hard-coded maximum radius in which to retrieve user-modifiable landmarks
	float maxDistance;
	// The most recent center location
	CLLocation *center;
}

@property (readonly, nonatomic) NSArray *closestLandmarks;
@property (readonly, nonatomic) NSArray *userEditableLandmarks;
@property (readonly, nonatomic) NSArray *layers;
@property (readonly) int maxLandmarks;
@property (readonly) float maxDistance;

// ensures that GNLayerManager is a singleton
+ (GNLayerManager *)sharedManager;

// adds the provided layer to this GNLayerManager's list of layers
- (void)addLayer:(GNLayer *)layer;
// adds the provided layer to this GNLayerManager's list of layers
// and sets its activity to the indicated value
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;
// Sets the given layer to the indicated activity.
// If the layer is being set to inactive, clears that layer's
// list of validated landmarks and flushes its nonvalidated info.
// Then removes any landmarks that have no active layers from
// validatedLandmarks and allLandmarks.
// >>> Note: Cannot be called while in editing mode
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;

// flushes nonvalidated information from all layers
- (void)flushAllNonvalidatedInfo;

// Central access point methods for all GNLandmarks stored in GNLayerManager.
// If a GNLayer needs a GNLandmark with certain properties, the GNLayer must call either
// of these methods with the desired landmark information. If this GNLayerManager has
// such a GNLandmark in allLandmarks, that GNLandmark is returned. Otherwise,
// GNLayerManager creates the GNLandmark, adds it to allLandmarks, and then returns it.
- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude;

// sorts validatedLandmarks and returns its first maxLandmarks elements
- (NSArray *)closestLandmarks;

// returns an array of layers that are active and storing validated
// information on the provided GNLandmark
- (NSArray *)activeLayersForLandmark:(GNLandmark *)landmark;
// returns an array of all layers storing information
// on the provided GNLandmark (validated or unvalidated)
- (NSArray *)layersForLandmark:(GNLandmark *)landmark;

// tells each active GNLayer to get the landmarks closest to the
// provided location and compiles the results in validatedLandmarks
- (void)updateToCenterLocation:(CLLocation *)location;
// similar to above, but updates to "center" variable
- (void)updateWithPreviousLocation;
// called when a layer has finished a request to its server
// and has a list of validated landmarks to integrate into validatedLandmarks
- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks;

// updates all user modifiable GNLayers and compiles the returned
// editable landmarks into userEditableLandmarks
- (void)updateEditableLandmarksForLocation:(CLLocation *)location;
// called when a layer has finished a request to its server
// and has a list of editable landmarks to integrate into userEditableLandmarks
- (void)layer:(GNLayer *)layer didUpdateEditableLandmarks:(NSArray *)landmarks;

@end