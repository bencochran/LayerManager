//
//  GNInfoInputViewController.h
//  LayerManager
//
//  Created by Jake Kring on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GNInfoInputViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate> {

	UILabel *label;
	UITextView *textView;
	UITextField *textField;
	NSArray *fieldArray;
	NSString *inputString;
	NSString *savedInput;
	BOOL wasAField;
}

- (id)initWithFieldName:(NSString *)name andContent:(NSString *)input;

@end
