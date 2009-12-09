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

@protocol GNLayerManagerDelegate;

extern NSString *const GNLandmarksUpdated;

@interface GNLayerManager : NSObject {
	NSMutableArray *layers;
	// distAndLandmarkList is a list of GNDistAndLandmarks, compiled from
	// the lists of closest landmarks returned by each layer on the previous
	// call to getNClosestLandmarks, sorted in increasing order by distance
	NSMutableArray *distAndLandmarkList;
	// allLandmarks: key = landmark ID, value = GNLandmark
	NSMutableDictionary *allLandmarks;
}

+ (GNLayerManager *)sharedManager;

- (void)addLayer:(GNLayer *)layer;
- (void)setLayer:(GNLayer *)layer active:(BOOL)active;
- (void)addLayer:(GNLayer *)layer active:(BOOL)active;
- (NSMutableArray *)getNClosestLandmarks:(int)n toLocation:(CLLocation *)location maxDistance:(float)maxDistance;
- (GNLandmark *)getLandmark:(int)landmarkID name:(NSString *)landmarkName latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

@end