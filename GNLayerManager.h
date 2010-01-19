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
	// closestLandmarks is a list of GNLandmarks, compiled from
	// the lists of closest landmarks returned by each layer on the previous
	// call to getNClosestLandmarks, sorted in increasing order by distance
	NSMutableArray *closestLandmarks;
	// allLandmarks: key = landmark ID, value = GNLandmark
	NSMutableDictionary *allLandmarks;
}

+ (GNLayerManager *)sharedManager;

- (void)addLayer:(GNLayer *)layer;
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;
- (NSArray *)getNClosestLandmarks:(int)n toLocation:(CLLocation *)location maxDistance:(float)maxDistance;
- (GNLandmark *)getLandmark:(int)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (NSUInteger)getSizeofClosestLandmarks;

@end