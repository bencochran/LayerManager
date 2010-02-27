//
//  GNLandmark.h
//  Stores the information relevant to a landmark:
//      a longitude and latitude (inherited from CLLocation)
//      a unique string identifier
//      a string name (not necessarily unique)
//      a float with the value of the last known distance from the user
//      a list of the active layers that are currently storing information on this landmark
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class GNLayer, GNLayerManager;

@interface GNLandmark : CLLocation <MKAnnotation> {
	NSString *_id;
	NSString *_name;
	float _distance;
	NSMutableArray* _activeLayers;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString* name;
@property (nonatomic) float distance;
@property (nonatomic, retain) NSMutableArray* activeLayers;

// To comply with the MKAnnotation interface
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString* subtitle;

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)alitiude;
+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

- (void)addActiveLayer:(GNLayer *)layer;
- (void)removeActiveLayer:(GNLayer *)layer;
- (void)clearActiveLayers;

@end