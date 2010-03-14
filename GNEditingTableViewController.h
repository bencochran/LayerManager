//
//  GNEditingTableViewController.h
//  An editing view controller used in the general implementation of
//    getEditingViewControllerWithLocation:andLandmark: in GNLayer
//  Allows editing of individual fields with a GNInfoInputViewController
//  Adds new or existing landmarks to user editable layers, and updates
//    layer information for both validated and nonvalidated landmarks
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"
#import "GNLandmark.h"
#import "GNTableViewCell.h"

@interface GNEditingTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	NSArray *fields;
	NSInteger currentField;
	NSMutableArray *userInput;
	NSMutableDictionary *_userInputDict;
	GNLayer *selectedLayer;
	CLLocation *selectedLocation;
	GNLandmark *selectedLandmark;
	BOOL previouslyExisted;
	BOOL _adding;
	BOOL tookPhoto;
	UIImagePickerController *photoController;
	UIView *buttonContainer;
	UIImage *photo;
	UIImageView *photoView;
	NSURL *imageURL;
}

@property (assign) BOOL adding;
@property (nonatomic, retain) NSMutableDictionary *userInputDict;

// initializes this GNEditingTableViewController with the given field information
// (the field information will be set to the appropriate fields)
// on the provided layer with the landmark with the given location
// location cannot be nil, but if the landmark is new, landmark must be nil
- (id)initWithFields:(NSArray *)newFields andLayer:(GNLayer *)layer andLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;
// called when the user has finished editing the information in a particular field
// updates that field's information with the provided input
- (void)addUserInput:(NSString *)input toField:(NSInteger)index;
// called when the user clicks on the landmark's associated image
// if the camera is available, allows the user to take a picture
// otherwise, requires the user to select and image from the photo album
- (IBAction)takePhoto:(id) sender;
// returns the index of the field the user is currently editing
- (NSInteger)getCurrentField;

@end