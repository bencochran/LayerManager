//
//  GNLandmark.h
//  Stores the information relevant to a landmark:
//      a unique integer identifier
//      a float with the value of the last known distance of this landmark from the user
//      a string name (not necessarily unique)
//      a longitude and latitude (inherited from CLLocation)
//      a list of the active layers that are currently storing information on this landmark
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class GNLayer;

@interface GNLandmark : CLLocation <MKAnnotation> {
	NSString *_id;
	float _distance;
	NSString* _name;
	NSMutableArray* _activeLayers;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic) float distance;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, retain) NSMutableArray* activeLayers;

// We need to provide a title property to comply with the MKAnnotation interface
@property (nonatomic, readonly) NSString *title;

+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)alitiude;
+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

- (void)addActiveLayer:(GNLayer *)layer;
- (void)removeActiveLayer:(GNLayer *)layer;
- (void)clearActiveLayers;

@end