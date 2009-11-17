//
//  GNLayer.h
//  The general layer superclass. Contains information relevant to all layers:
//      a unique name
//      a BOOL indicating whether or not this layer is active
//      a string path to this layer's icon (should be hard-coded into each subclass)
//      a mutable array of this layer's current closest landmarks
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLandmark.h"
#import "GNLayerManager.h"

@class GNLayerManager;

@interface GNLayer : NSObject {
	NSString* _name;
	BOOL _active;
	NSMutableArray* _closestLandmarks;
	
	NSString* iconPath;
	// layerInfoByLandmarkID stores the information necessary
	// to generate the final UIViewController for a landmark. 
	// Keys are landmark ID's, values are objects containing
	// layer information that can be parsed to create the UIViewController
	NSMutableDictionary* layerInfoByLandmarkID;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableArray* closestLandmarks;

+(GNLayer*)layerWithName:(NSString*)initName;

///////////////////////// TODO: -(NSIcon) getIcon;
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager;
-(NSMutableArray*)removeSelfFromLandmarks;
-(NSString*)getSummaryStringForID:(int)landmarkID;
-(UIViewController*)getLayerViewForID:(int)landmarkID;

@end

// An NSObject that packages together a GNLandmark
// and its current floating-point distance from the user
@interface GNDistAndLandmark : NSObject {
	float _dist;
	GNLandmark *_landmark;
}

@property (nonatomic) float dist;
@property (nonatomic, retain) GNLandmark *landmark;

+(GNDistAndLandmark*)gndlWithDist:(float)initDist andLandmark:(GNLandmark*)initLandmark;
-(NSComparisonResult)compareTo:(GNDistAndLandmark*)gndl;    // for sorting

@end