//
// GNLayerManager.h
//  
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"
#import "GNLandmark.h"

@interface LayerManager : NSObject {

	NSMutableArray *layers;
	NSMutableArray *distAndLandmarkList;
	NSDictionary *allLandmarks; // Landmark IDs to Landmark pointers
	
}

-(void) addLayer:(GNLayer*)layer;
-(NSMutableArray*) getNClosestLandmarks:(int)n toLocation:(CLLocation*)location maxDistance:(float)maxDistance;
-(GNLandmark*) getLandmark:(int)landmarkID name:(NSString*)landmarkName location:(CLLocation*)landmarkLocation;
-(void) setLayer:(GNLayer*)layer active:(bool)active;


@end
