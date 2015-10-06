//
//  VerticalTrafficLightsWindowDelegate.h
//  miniPlayer
//
//  Created by Peter Burkimsher on 12/02/2014.
//  Copyright (c) 2014 Peter Burkimsher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VerticalTrafficLightsWindowDelegate : NSObject <NSWindowDelegate> {
    __unsafe_unretained NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

- (void)verticalizeButtonsForWindow:(NSWindow *)aWindow;

@end
