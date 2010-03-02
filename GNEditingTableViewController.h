//
//  GNEditingTableViewController.h
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GNLayer.h"
#import "GNLandmark.h"
#import "GNTableViewCell.h"

@interface GNEditingTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	NSArray *_fields;
	NSInteger currentField;
	NSMutableDictionary *_fieldContent;
	NSMutableDictionary *_userInputDict;
	GNLayer *selectedLayer;
	CLLocation *selectedLocation;
	GNLandmark *selectedLandmark;
	BOOL previouslyExisted;
	BOOL _adding;
	BOOL tookPhoto;
	NSMutableData *receivedData;
	UIImagePickerController *photoController;
	UIView *buttonContainer;
	UIImage *_photo;
	UIImageView *photoView;
	GNTableViewCell *_imageViewCell;
	NSString *imageURLString;
	NSURL *_imageURL;
}

@property (assign) BOOL adding;
@property (nonatomic, retain) NSMutableDictionary *userInputDict;
@property (nonatomic, retain) NSMutableDictionary *fieldContent;
@property (nonatomic, retain) GNTableViewCell *imageViewCell;
@property (nonatomic, retain) NSArray *fields;
@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) UIImage *photo;

- (id)initWithLayer:(GNLayer *)layer andLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;
- (void)addUserInput:(NSString *)input toField:(NSInteger)index;
- (void) takePhoto;
- (void) getImageWithURL:(NSURL *)url;
- (NSInteger)getCurrentField;

@end