/*
 
 File: MyNSSliderCell.m
 
 Abstract: Code to manage our volume slider
 
 Version: <1.0>
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Computer, Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Computer,
 Inc. may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright © 2005 Apple Computer, Inc., All Rights Reserved
 
 */


#import "VolumeSliderCell.h"
#import "iTunes.h"

@implementation VolumeSliderCell

-(id)initWithValues:(NSTextField *)aTextField controller:(AppController *)aController
{
    if (self = [super init])
    {
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:12.0];
        attrs = [NSMutableDictionary dictionary];
        [attrs setObject:font forKey:NSFontAttributeName];
        [attrs setObject:[NSColor greenColor] forKey:NSBackgroundColorAttributeName];
        
        userIsDraggingSlider = NO;
        continuePlayingAfterDrag = NO;
        
        myController = aController;
        movieTimeStringBox = aTextField;
        
        previousStringRect = NSMakeRect(0,0,0,0);
    }
    
    return (self);
}

- (void)drawKnob:(NSRect)knobRect{
        
    [[self controlView] lockFocus];
    
    NSImage* knobImage = [NSImage imageNamed:@"volumeKnob.png" ];
    
    knobRect.size.width = 11;
    knobRect.size.height = 12;
    [self setKnobThickness:2];
    
    [knobImage compositeToPoint:NSMakePoint(knobRect.origin.x,knobRect.origin.y+(knobRect.size.height/2)+3) operation:NSCompositeSourceOver];
    //    [knobImage compositeToPoint:NSMakePoint(knobRect.origin.x+5,knobRect.origin.y+15) operation:NSCompositeSourceAtop];
    
    knobRectGlobal = knobRect;
    
    [[self controlView] unlockFocus];
}

- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped {
    rect.size.height = 7;
    
    NSImage* leftBarImage = [NSImage imageNamed:@"volumeSliderFull.png" ];
    NSImage* rightBarImage = [NSImage imageNamed:@"volumeSliderEmpty.png" ];
    
    NSImage* leftEndImage = [NSImage imageNamed:@"volumeSliderLeftEnd.png" ];
    NSImage* rightEndImage = [NSImage imageNamed:@"volumeSliderRightEnd.png" ];
    
    NSRect leftRect = rect;
    leftRect.origin.x=6;
    leftRect.origin.y=3;
    leftRect.size.width = knobRectGlobal.origin.x + (knobRectGlobal.size.width) + 10 - 6;
    [leftBarImage setSize:leftRect.size];
    [leftBarImage drawInRect:leftRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction:1];
    
    NSRect leftEndRect = rect;
    leftEndRect.origin.x=0;
    leftEndRect.origin.y=3;
    leftEndRect.size.width = 7;
    [leftEndImage setSize:leftEndRect.size];
    [leftEndImage drawInRect:leftEndRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction:1];
    
    NSRect rightRect = rect;
    rightRect.origin.y=3;
    rightRect.origin.x = knobRectGlobal.origin.x;
    rightRect.size.width = knobRectGlobal.size.width + 100;
    [rightBarImage setSize:rightRect.size];
    [rightBarImage drawInRect:rightRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction:1];
    
    NSRect rightEndRect = rect;
    rightEndRect.origin.x=55;
    rightEndRect.origin.y=3;
    rightEndRect.size.width = 7;
    [rightEndImage setSize:rightEndRect.size];
    [rightEndImage drawInRect:rightEndRect fromRect: NSZeroRect operation: NSCompositeSourceOver fraction:1];
    
}

- (NSRect)knobRectFlipped:(BOOL)flipped {
    NSImage* knobImage = [NSImage imageNamed:@"trackPositionTransparent.png" ];
    
    float KNOB_WIDTH = [knobImage size].width;
    float KNOB_HEIGHT = [knobImage size].height;
    CGFloat value = ([self doubleValue]  - [self minValue])/ ([self maxValue] - [self minValue]);
    NSRect defaultRect = [super knobRectFlipped:flipped];
    NSRect myRect = NSMakeRect(0, 0, 0, 0);
    if ([(NSSlider*) [self controlView] isVertical] == YES)
    {
        //...
    } else {
        myRect.size.width = KNOB_WIDTH;
        myRect.size.height = KNOB_HEIGHT;
        myRect.origin.x = value * ([[self controlView] frame].size.width - KNOB_WIDTH);
        myRect.origin.y = defaultRect.origin.y + defaultRect.size.height/2.0 - myRect.size.height/2.0; // Fixed the position
    }
    return myRect;
};


// NSCell invokes this method when tracking begins
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    
    [super startTrackingAt:startPoint inView:controlView];
    
    userIsDraggingSlider = YES;
    
    continuePlayingAfterDrag = NO;
    
    return (YES);
}

// NSCell invokes this method when the cursor has left the bounds
// of the receiver or the mouse button goes up (in which case flag is YES).
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
    
    userIsDraggingSlider = NO;
    
//    iTunesApplication* iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    NSInteger newVolume = lastPoint.x / 61 * 100;
    
    // Run an AppleScript to set the iTunes player position.
    NSAppleScript *setiTunesVolume = [[NSAppleScript alloc] initWithSource: [NSString stringWithFormat:@"tell application \"iTunes\" to set sound volume to %ld", newVolume ]];
    [setiTunesVolume executeAndReturnError:nil];
}

- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

// return YES if user is currently dragging the slider, NO
// if not
-(BOOL)isUserDraggingSlider
{
    
    return userIsDraggingSlider;
}


@end