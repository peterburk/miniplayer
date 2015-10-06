//VerticalTrafficLightsWindowDelegate.h

#import <Cocoa/Cocoa.h>

//VerticalTrafficLightsWindowDelegate.m

#import "VerticalTrafficLightsWindowDelegate.h"

@implementation VerticalTrafficLightsWindowDelegate

@synthesize window;

- (void)awakeFromNib {
    [self verticalizeButtonsForWindow:window];
}

- (void)windowDidResize:(NSNotification *)notification {
    [self verticalizeButtonsForWindow:window];
}

- (void)verticalizeButtonsForWindow:(NSWindow *)aWindow {
    NSArray *contentSuperViews = [[[aWindow contentView] superview] subviews];
    
    NSView *closeButton = [contentSuperViews objectAtIndex:0];
    NSRect closeButtonFrame = [closeButton frame];
    
    NSView *minimizeButton = [contentSuperViews objectAtIndex:2];
    NSRect minimizeButtonFrame = [minimizeButton frame];
    
    NSView *zoomButton = [contentSuperViews objectAtIndex:1];
    NSRect zoomButtonFrame = [zoomButton frame];
    
    [minimizeButton setFrame:NSMakeRect(closeButtonFrame.origin.x, closeButtonFrame.origin.y - 20.0, minimizeButtonFrame.size.width, minimizeButtonFrame.size.height)];
    [zoomButton setFrame:NSMakeRect(closeButtonFrame.origin.x, closeButtonFrame.origin.y - 40.0, zoomButtonFrame.size.width, zoomButtonFrame.size.height)];
}

@end
