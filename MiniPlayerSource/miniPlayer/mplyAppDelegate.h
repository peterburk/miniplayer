//
//  mplyAppDelegate.h
//  miniPlayer
//
//  Created by Peter Burkimsher on 19/01/2014.
//  Copyright (c) 2014 Peter Burkimsher. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "TrackSlider.h"
#import "AVPanel.h"
#import "ScrollingTextView.h"
#import "VolumeSlider.h"

@interface mplyAppDelegate : NSObject <NSApplicationDelegate>
{
    NSTextField *_trackNameTextField;
    NSTextField *_trackArtistTextField;
    NSImageView *_lcdSection;
    NSTextField *_trackTimeTextField;
    NSTextField *_trackLengthTextField;
    NSButton *_playPauseButton;
    TrackSlider *_trackTimeSlider;
    NSTimer *refreshTimer;
    NSScrollView *_lcdView;
    NSView *_lcdViewContent;
    NSTextField *_aboutTextField;
}
@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)backButtonClicked:(NSButton *)sender;
- (IBAction)playButtonClicked:(NSButton *)sender;
- (IBAction)nextButtonClicked:(NSButton *)sender;
- (void)updateTrackInfo;
- (NSString *)timeFormatted:(NSInteger)totalSeconds;
- (IBAction)maximiseButtonClicked:(id)sender;
- (IBAction)volumeSliderClicked:(id)sender;
- (IBAction)trackTimeSliderClicked:(id)sender;
- (IBAction)revealButtonClicked:(id)sender;
- (IBAction)eqButtonClicked:(id)sender;

@property (strong) IBOutlet NSTextField *trackNameTextField;
@property (strong) IBOutlet NSTextField *trackArtistTextField;
@property (strong) IBOutlet NSImageView *lcdSection;
@property (strong) IBOutlet NSTextField *trackTimeTextField;
@property (strong) IBOutlet NSTextField *trackLengthTextField;
@property (strong) IBOutlet NSButton *playPauseButton;
@property (strong) IBOutlet TrackSlider *trackTimeSlider;
@property (strong) IBOutlet NSSlider *volumeSlider;
@property (strong) IBOutlet ScrollingTextView *artistTextView;
@property (strong) IBOutlet ScrollingTextView *titleTextView;


@property (strong) IBOutlet NSScrollView *lcdView;
@property (strong) IBOutlet NSView *lcdViewContent;
@property (strong) IBOutlet NSTextField *aboutTextField;
@end
