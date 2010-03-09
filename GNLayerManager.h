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

+ (GNLayerManager *)sharedManager;

- (void)addLayer:(GNLayer *)layer;
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;

- (void)flushAllNonvalidatedInfo;

- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude;

- (NSArray *)closestLandmarks;

- (NSArray *)activeLayersForLandmark:(GNLandmark *)landmark;
- (NSArray *)layersForLandmark:(GNLandmark *)landmark;

- (void)updateToCenterLocation:(CLLocation *)location;
- (void)updateWithPreviousLocation;
- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks;

- (void)updateEditableLandmarksForLocation:(CLLocation *)location;
- (void)layer:(GNLayer *)layer didUpdateEditableLandmarks:(NSArray *)landmarks;

@end