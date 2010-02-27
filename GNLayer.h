//
//  GNLayer.h
//  The general layer superclass. Contains information relevant to all layers:
//      a unique string name
//      a mutable array of this layer's current closest landmarks (sorted in increasing order by distance)
//      a mutable dictionary of the layer information for each landmark
//      a BOOL indicating whether or not this layer is active
//      a string path to this layer's icon (should be hard-coded into each subclass)
//
//  Created by iComps on 11/1/09.
//  Copyright 2009 Gnarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLandmark.h"
#import "GNLayerManager.h"
#import "GNEditingTableViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@class GNLayerManager;

extern NSString *const GNLayerUpdateFailed;
extern NSString *const GNLayerDidStartUpdating;
extern NSString *const GNLayerDidFinishUpdating;

@interface GNLayer : NSObject {
	// this layer's name (must be unique)
	NSString *_name;
	// _landmarks is the last list of closest landmarks
	// returned by the server, sorted in increasing order by distance
	NSMutableArray *_landmarks;
	// layerInfoByLandmark stores the information necessary to generate
	// the UIViewController for each landmark in _landmarks
	// Keys are landmark IDs, values are objects containing
	// layer information that can be parsed to create a UIViewController
	NSMutableDictionary *layerInfoByLandmarkID;
	
	// YES when storing information about validated landmarks on this layer
	BOOL _active;
	// the path to the icon that will represent this layer on the toggle bar
	NSString *iconPath;
	
	// Indicates whether a layer can be AUGMENTED by users
	// Allows for both adding new landmarks and editing existing landmarks
	BOOL userModifiable;
	// The fields that are editable when creating a landmark for this layer
	// (nil if userModifiable == NO)
	NSArray *layerFields;
	
	// NSData to hold incoming data from the NSURLConnection as we receive it
	NSMutableData *receivedData;
	// The most recently used center location
	CLLocation *center;

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSMutableArray *landmarks;
@property (nonatomic) BOOL active;
@property (readonly) BOOL layerIsUserModifiable;

// general accessors
- (UIImage *) getIcon;
- (BOOL)layerIsUserModifiable;


///////////////////////// Might remove these two -Wade
- (void)removeSelfFromLandmarks;
// Returns a short summary string of the layer information for this landmark
// Will (theoretically) be displayed below this layer's name in the LayersListViewController
- (NSString *)summaryForLandmark:(GNLandmark *)landmark;


//// Methods for updating and accessing current list of validated landmarks (_landmarks) ////

// Updates the list of closest validated landmarks to the landmarks closest to the provided location
- (void)updateToCenterLocation:(CLLocation *)location;
// Returns the URL that should be called to retrieve the landmarks closest to the provided location
// If limitToValidated == NO and this layer is user modifiable, returns a URL that will retrieve
// all validated and unvalidated landmarks within a radius of the given location
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated;
// A convenience method for Gnarus layers
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated withLayerName:(NSString *)layerName;
// Given the data returned by a call to one of the provided URLs, returns an NSArray
// containing the necessary landmarks retrieved from GNLayerManager. Stores the layer info
// for these landmarks in layerInfoByLandmarkID but does NOT store landmarks in _landmarks
- (NSArray *)parseDataIntoLandmarks:(NSData *)data;
// Stores the provided array of landmarks in _landmarks, and sorts by distance
- (void)ingestLandmarks:(NSArray *)landmarks;
// If limitToValidated == YES, returns YES if the provided landmark is in _landmarks
// Otherwise, returns YES if this layer is currently storing layer information on this landmark
- (BOOL)containsLandmark:(GNLandmark *)landmark limitToValidated:(BOOL)limitToValidated;
// Returns a UIViewController that displays this layer's information for the provided landmark
- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark;


//// Methods for updating information on user-editable landmarks ////
////    Should only be implemented if layer is user modifiable   ////

// Retrieves all validated and unvalidated landmarks within a radius of the provided location
- (void)updateEditableLandmarksForLocation:(CLLocation *)location;
// Returns a UIViewController that allows a user to add a new landmark
// to the provided location if landmark == nil, save/vote for existing information
// on an unvalidated landmark, and edit/update information for both validated
// and unvalidated landmarks
- (UIViewController *)getEditingViewControllerWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;
// Returns a dictionary that maps each string in layerFields
// to the layer information currently stored about this landmark
- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark;
// Uploads the provided layer information, landmark ID, location, and image to the server
// of a user modifiable layer. If the landmark currently exists, the landmarkID must be
// that landmark's ID. If the landmark does not already exist, the landmarkID must be @"0" (for Gnarus layers).
// If the landmark already exists, the location must be that landmark's location.
// If the photo is nil, the layer's existing photo for this landmark is not changed.
- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo;

@end