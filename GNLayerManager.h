//
// GNLayerManager.h
//  Manages all landmarks and layers
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
	NSMutableArray *layers;
	// allLandmarks: key = landmark ID, value = GNLandmark
	NSMutableDictionary *allLandmarks;
	NSMutableArray *validatedLandmarks;
	NSMutableArray *userEditableLandmarks;
	// The hard-coded maximum number of landmarks to retreive
	int maxLandmarks;
	// The most recent center location
	CLLocation *center;
}

@property (readonly, nonatomic) NSArray *layers;
@property (readonly) int maxLandmarks;
@property (readonly, nonatomic) NSArray *userEditableLandmarks;
@property (readonly, nonatomic) NSArray *closestLandmarks;

+ (GNLayerManager *)sharedManager;

- (void)addLayer:(GNLayer *)layer;
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;

- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude;

- (void)updateToCenterLocation:(CLLocation *)location;
- (void)updateWithPreviousLocation;
- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks;

- (void)updateEditableLandmarksForLocation:(CLLocation *)location;
- (void)layer:(GNLayer *)layer didUpdateEditableLandmarks:(NSArray *)landmarks;

- (NSArray *)closestLandmarks;

@end