//
//  GNLayer.h
//  The general layer superclass. Contains information relevant to all layers:
//      a unique string name
//      a BOOL indicating whether or not this layer is active
//      a mutable array of this layer's current closest landmarks
//      a string path to this layer's icon (should be hard-coded into each subclass)
//      a mutable dictionary of the layer information for each landmark
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
	// _closestLandmarks is the last list of closest landmarks
	// returned by the server (stored as GNDistAndLandmarks),
	// sorted in increasing order by distance.
	NSMutableArray* _closestLandmarks;
	
	// the path to the icon that will represent this layer in the main view
	NSString* iconPath;
	// layerInfoByLandmarkID stores the information necessary to generate
	// the final UIViewController for each landmark in _closestLandmarks. 
	// Keys are landmark ID's, values are objects containing
	// layer information that can be parsed to create a UIViewController
	NSMutableDictionary* layerInfoByLandmarkID;
}

@property (nonatomic, copy) NSString* name;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableArray* closestLandmarks;

///////////////////////// MIGHT DELETE LATER - SUBCLASS INITS DON'T CALL THIS
+(GNLayer*)layerWithName:(NSString*)initName;

///////////////////////// TODO: -(NSIcon) getIcon;
-(NSMutableArray*)getNClosestLandmarks:(int)n toLocation:(CLLocation*)location withLM:(GNLayerManager*)layerManager;
-(NSMutableArray*)removeSelfFromLandmarks;
-(NSString*)getSummaryStringForID:(int)landmarkID;
-(UIViewController*)getLayerViewForID:(int)landmarkID;

@end

// An NSObject that packages together a GNLandmark
// and its current floating-point distance from the user
//@interface GNDistAndLandmark : NSObject {
//	float _dist;
//	GNLandmark *_landmark;
//}
//
//@property (nonatomic) float dist;
//@property (nonatomic, retain) GNLandmark *landmark;
//
//+(GNDistAndLandmark*)gndlWithDist:(float)initDist andLandmark:(GNLandmark*)initLandmark;
//-(NSComparisonResult)compareTo:(GNDistAndLandmark*)gndl;    // for sorting
//
//@end