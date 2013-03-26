//
//  NDPlayMovie.mm
//  dhlj
//
//  Created by zhangwq on 13-3-22.
//  Copyright (c) 2013Äê. All rights reserved.
//

#import <string>
#import <Foundation/NSThread.h>
#import "NDPlayMovie.h"
#import "SimpleAudioEngine.h"

CGFloat kMovieViewOffsetX = 0;//20.0;
CGFloat kMovieViewOffsetY = 0;//20.0;


@implementation NDPlayMovie;

@synthesize ownerView = _ownerView;
@synthesize overlay = _overlay;
@synthesize moviePlayerController = _moviePlayerController;


+(id) sharedObj
{
    static NDPlayMovie* s_obj;
    if (!s_obj)
    {
        s_obj = [[NDPlayMovie alloc] init];
    }
    return s_obj;
}

-(Boolean) check
{
    return self.ownerView != Nil;
}

-(void)playTest
{
    [self playMovieFile:[self localMovieURL]];
    [self onPlayMovieBegin];
}

/* Returns a URL to a local movie in the app bundle. */
-(NSURL *)localMovieURL
{
	NSURL *theMovieURL = nil;
	NSBundle *bundle = [NSBundle mainBundle];
	if (bundle)
	{
//		NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
//      NSString *moviePath = [bundle pathForResource:@"480_0" ofType:@"mp4"];
        
        NSString* tmp = @"/SimplifiedChineseRes/res/Video/480_0.mp4";
        NSString* moviePath = [[bundle resourcePath] stringByAppendingString : tmp];

		if (moviePath)
		{
			theMovieURL = [NSURL fileURLWithPath:moviePath];
		}
	}
    return theMovieURL;
}

/* Called soon after the Play Movie button is pressed to play the local movie. */
-(void)playMovieFile:(NSURL *)movieFileURL
{
    if ([self check])
    {
        [self createAndPlayMovieForURL:movieFileURL sourceType:MPMovieSourceTypeFile];
    }
}


/* Load and play the specified movie url with the given file type. */
-(void)createAndPlayMovieForURL:(NSURL *)movieURL
                     sourceType:(MPMovieSourceType)sourceType
{
    [self createAndConfigurePlayerWithURL:movieURL
                               sourceType:sourceType];
    
    /* Play the movie! */
    [[self moviePlayerController] play];
}


/*
 Create a MPMoviePlayerController movie object for the specified URL and add movie notification
 observers. Configure the movie object for the source type, scaling mode, control style, background
 color, background image, repeat mode and AirPlay mode. Add the view containing the movie content and
 controls to the existing view hierarchy.
 */
-(void)createAndConfigurePlayerWithURL:(NSURL *)movieURL
                            sourceType:(MPMovieSourceType)sourceType
{
    /* Create a new movie player object. */
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if (player)
    {
        /* Save the movie object. */
        self.moviePlayerController = player;
        
        /* Register the current object as an observer for the movie
         notifications. */
        [self installMovieNotificationObservers];
        
//        /* Specify the URL that points to the movie file. */
//        [player setContentURL:movieURL];
        
        /* If you specify the movie type before playing the movie it can result
         in faster load times. */
        [player setMovieSourceType:sourceType];
        
        /* Apply the user movie preference settings to the movie player object. */
        [self applyUserSettingsToMoviePlayer];
        
        
        /* Inset the movie frame in the parent view frame. */
        CGRect viewInsetRect = CGRectInset ([self.ownerView bounds],
                                            kMovieViewOffsetX,
                                            kMovieViewOffsetY );
        
        [[player view] setFrame:viewInsetRect];
        
        /* set view bgcolor */
        [player view].backgroundColor = [UIColor blackColor];

        
        /* To present a movie in your application, incorporate the view contained
         in a movie player¡¯s view property into your application¡¯s view hierarchy.
         Be sure to size the frame correctly. */
        [self.ownerView addSubview: [player view]];
    }
}

/* Handle movie load state changes. */
- (void)loadStateDidChange:(NSNotification *)notification
{
}

/* Called when the movie playback state has changed. */
- (void) moviePlayBackStateDidChange:(NSNotification*)notification
{
#if 0
	MPMoviePlayerController *player = notification.object;
    
	/* Playback is currently stopped. */
	if (player.playbackState == MPMoviePlaybackStateStopped)
	{
	}
	/*  Playback is currently under way. */
	else if (player.playbackState == MPMoviePlaybackStatePlaying)
	{
	}
	/* Playback is currently paused. */
	else if (player.playbackState == MPMoviePlaybackStatePaused)
	{
	}
	/* Playback is temporarily interrupted, perhaps because the buffer
	 ran out of content. */
	else if (player.playbackState == MPMoviePlaybackStateInterrupted)
	{
	}
#endif
}

/*  Notification called when the movie finished playing. */
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSNumber *reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	switch ([reason integerValue])
	{
            /* The end of the movie was reached. */
		case MPMovieFinishReasonPlaybackEnded:
            [self onPlayMovieEnd];
			break;
            
            /* An error was encountered during playback. */
		case MPMovieFinishReasonPlaybackError:
            NSLog(@"An error was encountered during playback");
            [self performSelectorOnMainThread:@selector(displayError:) withObject:[[notification userInfo] objectForKey:@"error"]
                                waitUntilDone:NO];
            [self onPlayMovieEnd];
			break;
            
            /* The user stopped playback. */
		case MPMovieFinishReasonUserExited:
            [self onPlayMovieEnd];
			break;
            
		default:
			break;
	}
}

/* Notifies observers of a change in the prepared-to-play state of an object
 conforming to the MPMediaPlayback protocol. */
- (void) mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:player];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieDurationAvailable:)
                                                 name:MPMovieDurationAvailableNotification
                                               object:player];    
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationHandlers
{
    MPMoviePlayerController *player = [self moviePlayerController];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerLoadStateDidChangeNotification
                                                 object:player];

    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:player];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMovieDurationAvailableNotification
                                                 object:player];
}

/* Delete the movie player object, and remove the movie notification observers. */
-(void)deletePlayerAndNotificationObservers
{
    [self removeMovieNotificationHandlers];
    [self setMoviePlayerController:nil];
}

#pragma mark Movie Settings

-(void)movieDurationAvailable:(NSNotification*)notification
{
    MPMoviePlayerController *player = [self moviePlayerController];
    if (player)
    {
        float duration = player.duration - 1.0f/24.0f;
        player.endPlaybackTime = duration;
        NSLog(@"@@ set movie end time to: %.1f", duration);
        
        // movie player can't be stopped normally, so we have to stop it manually.
        _myTimer_StopMovie = [NSTimer scheduledTimerWithTimeInterval:duration
                                                              target:self
                                                            selector:@selector(onTimerStopMovie)
                                                            userInfo:nil
                                                             repeats:NO];
    }
}

/* Apply user movie preference settings (these are set from the Settings: iPhone Settings->Movie Player)
 for scaling mode, control style, background color, repeat mode, application audio session, background
 image and AirPlay mode.
 */
-(void)applyUserSettingsToMoviePlayer
{
    MPMoviePlayerController *player = [self moviePlayerController];
    if (player)
    {
        player.scalingMode = MPMovieScalingModeNone;
        player.controlStyle = MPMovieControlStyleNone;
        player.backgroundView.backgroundColor = 0x0;
        player.repeatMode = MPMusicRepeatModeNone;
        player.useApplicationAudioSession = true;
        player.shouldAutoplay = false;
        player.allowsAirPlay = YES;
    }
}

-(void)onTimerStopMovie
{
    [self onTouchDown];
}

-(void)onPlayMovieBegin
{
    NSLog( @"@@ onPlayMovieBegin()\r\n");
    
    [self addOverlay];
    
    CocosDenshion::SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
    CocosDenshion::SimpleAudioEngine::sharedEngine()->stopAllEffects();    
}

-(void)onPlayMovieEnd
{
    NSLog( @"@@ onPlayMovieEnd()\r\n");
    
    // remove overlay
    if (self.overlay != nil)
    {
        [self.overlay removeFromSuperview];
        self.overlay = nil;
    }
    
    // remove movie view
    if (self.moviePlayerController != nil)
    {
        [self.moviePlayerController.view removeFromSuperview];
        self.moviePlayerController = nil;
    }
    
    // remove timer   
    if (_myTimer_StopMovie != nil)
    {
        [_myTimer_StopMovie invalidate];
        _myTimer_StopMovie = nil;
    }
    
    // remove observer
    [self deletePlayerAndNotificationObservers];
    
    // resume bkgnd music
    CocosDenshion::SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}


-(void) onTouchDown
{
    NSLog(@"@@ video overlay -- onTouchDown()\r\n");
    
    if (self.moviePlayerController != nil)
    {
        [self.moviePlayerController stop];
        [self onPlayMovieEnd];
    }
}

-(void) addOverlay
{
    self.overlay = [[UIControl alloc] initWithFrame:self.moviePlayerController.view.frame];

    [self.overlay addTarget:self
                     action:@selector(onTouchDown)
           forControlEvents:UIControlEventTouchDown];

    [self.ownerView addSubview:self.overlay];
    
    [self.ownerView bringSubviewToFront:self.overlay];
     
    [self.overlay autorelease];
}

-(Boolean)isPlaying
{
    if (self.moviePlayerController != nil
        && self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying)
    {
        return YES;
    }
    return NO;
}

//----------------------
// global function
//----------------------
void playVideoIos()
{
    [[NDPlayMovie sharedObj] playTest];
}

@end
