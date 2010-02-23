//
//  GNLayer.h
//  The general layer superclass. Contains information relevant to all layers:
//      a unique string name (should begin with a source-specific string immediately followed by a colon)
//      a BOOL indicating whether or not this layer is active
//      a mutable array of this layer's current closest landmarks (sorted in increasing order by distance)
//      a string path to this layer's icon (should be hard-coded into each subclass)
//      a mutable dictionary of the layer information for each landmark
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

@interface GNLayer : NSObject {
	NSString *_name;
	BOOL _active;
	// _landmarks is the last list of closest landmarks
	// returned by the server, sorted in increasing order by distance.
	NSMutableArray *_landmarks;
	
	// the path to the icon that will represent this layer in the main view
	NSString *iconPath;
	// layerInfoByLandmark stores the information necessary to generate
	// the UIViewController for each landmark in _landmarks. 
	// Keys are landmark IDs, values are objects containing
	// layer information that can be parsed to create a UIViewController
	NSMutableDictionary *layerInfoByLandmarkID;
	
	// Indicates whether a layer can be AUGMENTED by users
	BOOL userModifiable;
	// The fields that are editable when creating a landmark
	NSArray *layerFields;
	
	// NSData to hold incoming data from the NSURLConnection as we receive it
	NSMutableData *receivedData;
	// The most recent center location
	CLLocation *center;

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) NSMutableArray *landmarks;
@property (readonly) BOOL layerIsUserModifiable;

- (UIImage *) getIcon;
- (void)removeSelfFromLandmarks;
- (NSString *)summaryForLandmark:(GNLandmark *)landmark;
- (UIViewController *)viewControllerForLandmark:(GNLandmark *)landmark;
- (BOOL)layerIsUserModifiable;
- (void) postLandmarkArray:(NSArray *)info withID:(NSString *)landmarkID withLocation:(CLLocation *)location andPhoto:(UIImage *)photo;
- (UIViewController *)getEditingViewControllerWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;

- (BOOL)containsLandmark:(GNLandmark *)landmark limitToValidated:(BOOL)limitToValidated;

- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated;
- (NSURL *)URLForLocation:(CLLocation *)location limitToValidated:(BOOL)limitToValidated withLayerName:(NSString *)layerName;
- (NSArray *)parseDataIntoLandmarks:(NSData *)data;

- (void)updateToCenterLocation:(CLLocation *)location;
- (void)ingestLandmarks:(NSArray *)landmarks;

- (void)updateEditableLandmarksForLocation:(CLLocation *)location;

- (NSDictionary *)fieldInformationForLandmark:(GNLandmark *)landmark;

@end