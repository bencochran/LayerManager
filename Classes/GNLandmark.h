//
//  GNLandmark.h
//  Stores the information relevant to a landmark:
//      a longitude and latitude (inherited from CLLocation)
//      a unique string identifier (should begin with a source-specific string immediately followed by a colon)
//      a string name (not necessarily unique)
//      a float with the value of the last known distance from the user
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
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) float distance;

// To comply with the MKAnnotation interface
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
// title will simply be this landmark's name
@property (nonatomic, readonly) NSString *title;
// subtitle will be a comma-delimited string of all layers
// that are currently storing information on this landmark
// (both validated and unvalidated information)
@property (nonatomic, readonly) NSString *subtitle;

// methods to create landmarks with the indicated information
+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude altitude:(CLLocationDistance)alitiude;
+ (GNLandmark *)landmarkWithID:(NSString *)ID name:(NSString *)name latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

@end