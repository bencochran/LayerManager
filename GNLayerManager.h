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

@interface GNLayerManager : NSObject {
	NSMutableArray *layers;

	// allLandmarks: key = landmark ID, value = GNLandmark
	NSMutableDictionary *allLandmarks;
	
	// The hard-coded maximum number of landmarks to retreive
	int maxLandmarks;
	
	// The most recent center location
	CLLocation *center;
}

@property (readonly) int maxLandmarks;

+ (GNLayerManager *)sharedManager;

- (void)addLayer:(GNLayer *)layer;
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;

- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (GNLandmark *)getLandmark:(NSString *)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)altitude;


- (void)updateToCenterLocation:(CLLocation *)location;
- (void)updateWithPreviousLocation;
- (void)layerDidUpdate:(GNLayer *)layer withLandmarks:(NSArray *)landmarks;
- (NSArray *)closestLandmarks;

@end