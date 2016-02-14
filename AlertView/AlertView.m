//
//  AlertView.m
//
//  Created by : Michael Heirendt
//  Project    : Crush
//  Date       : 1/26/16
//
//  Copyright (c) 2016 Apportable.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import "AlertView.h"

// -----------------------------------------------------------------

#define kDialogTag 1234
#define kAnimationTime 0.4f
#define kDialogImg @"dialogBox.png"
#define kButtonImg @"dialogButton.png"
#define kFontName @"MarkerFelt-Thin"

// class that implements a black colored layer that will cover the whole screen
// and eats all touches except within the dialog box child
@interface CoverLayer : CCNode {
}
@end
@implementation CoverLayer
- (id)init {
    self = [super init];
    if (self) {
        CCSprite *overlay = [CCSprite spriteWithImageNamed:@"Assets/overlay.png"];
        overlay.anchorPoint = ccp(.5f,.5f);
        overlay.positionType = CCPositionTypeNormalized;
        overlay.position = ccp(.5f,.5f);
        [self addChild:overlay];
        self.userInteractionEnabled = FALSE;
    }
    return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView:touch.view];
    CCNode *dialogBox = [self getChildByName:@"kDialogTag" recursively:NO];
    // eat all touches outside of dialog box
    return !CGRectContainsPoint(dialogBox.boundingBox, touchLocation);
}
@end


@implementation AlertView

+ (void) CloseAlert: (CCSprite*) alertDialog onCoverLayer: (CCNode*) coverLayer executingBlock: (void(^)())block {
    // shrink dialog box
    [alertDialog runAction:[CCActionScaleTo actionWithDuration:kAnimationTime scale:0]];
    
    // in parallel, fadeout and remove cover layer and execute block
    // (note: you can't use CCFadeOut since we don't start at opacity 1!)
    [coverLayer runAction:[CCActionSequence actions:
                           [CCActionFadeTo actionWithDuration:kAnimationTime opacity:0],
                           [CCActionCallBlock actionWithBlock:^{
        [coverLayer removeFromParentAndCleanup:YES];
        if (block) block();
    }],
    nil]];
}
+ (void)ShowAlert: (NSString*) message onLayer: (CCNode *) layer
          withOpt1: (NSString*) opt1 withOpt1Block: (void(^)())opt1Block
           andOpt2: (NSString*) opt2 withOpt2Block: (void(^)())opt2Block {
    
    // create the cover layer that "hides" the current application
    CCNode *coverLayer = [CoverLayer new];
    [layer addChild:coverLayer z:INT_MAX]; // put to the very top to block application touches
    [coverLayer runAction:[CCActionFadeTo actionWithDuration:kAnimationTime opacity:80]]; // smooth fade-in to dim with semi-transparency
    
    // open the dialog
    CCSprite *dialog = [CCSprite spriteWithImageNamed:@"Assets/notificationBox.png"];
    dialog.name = @"1234";
    dialog.positionType = CCPositionTypeUIPoints;
    dialog.scaleType = CCScaleTypeScaled;
    dialog.anchorPoint  = ccp(.5f,.5f);
    dialog.position = ccp(280,160);
    dialog.exclusiveTouch = true;
    dialog.opacity = 220; // make it a bit transparent for a cooler look
    float fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?42:30;
    CCLabelTTF *dialogMsg = [CCLabelTTF labelWithString:message fontName:kFontName fontSize:fontSize dimensions:CGSizeMake(300,100)];
    dialogMsg.anchorPoint = ccp(0, 0);
    dialogMsg.position = ccp(dialog.contentSize.width*.1f, dialog.contentSize.height * 0.35f);
    dialogMsg.color = [CCColor colorWithCcColor3b:ccBLACK];
    [dialog addChild: dialogMsg];
    
    CCButton *opt1Button = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Assets/forward.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Assets/forwardPressed.png"] disabledSpriteFrame:nil];
    [opt1Button setBlock:^(id sender){
        ////close alert and call opt1block when first button is pressed
        [self CloseAlert:dialog onCoverLayer: coverLayer executingBlock:opt1Block];
    }];
    opt1Button.position = ccp(dialog.textureRect.size.width * (opt2 ? 0.27f:0.5f), opt1Button.contentSize.height * 0.8f);                                         //fontName:kFontName fontSize:fontSize];
    CCLabelTTF *opt1Label = [CCLabelTTF labelWithString:opt1 fontName:@"Helvetica" fontSize:18 dimensions:CGSizeMake(200.f, 0.f)];
    opt1Label.anchorPoint = ccp(0, 1);
    opt1Label.color = [CCColor colorWithCcColor3b:ccBLACK];
    [opt1Button addChild: opt1Label];
    
    // create second button, if requested
    CCButton *opt2Button = nil;
    if (opt2) {
        opt2Button = [CCButton buttonWithTitle:nil spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Assets/Back.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Assets/BackPressed.png"] disabledSpriteFrame:nil];
        
        opt2Button.position = ccp(dialog.textureRect.size.width * 0.73f, opt1Button.contentSize.height * 0.8f);
        CCLabelTTF *opt2Label = [CCLabelTTF labelWithString:opt2 fontName:@"Helvetica" fontSize:18];
        opt2Label.anchorPoint = ccp(0, 0.1);
                            
        opt2Label.color = [CCColor colorWithCcColor3b:ccBLACK];
        [opt2Button addChild: opt2Label];
    }
    
    opt1Button.positionType = CCPositionTypeNormalized;
    opt2Button.positionType = CCPositionTypeNormalized;
    opt1Button.position = ccp(.3f,.3f);
    opt2Button.position = ccp(.7f,.3f);
    
    [dialog addChild:opt1Button];
    //[dialog addChild:opt2Button];
    [coverLayer addChild:dialog];
    
    // open the dialog with a nice popup-effect
    dialog.scale = 0;
    [dialog runAction:[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:kAnimationTime scale:1.0]]];
}



+ (void) Ask: (NSString *) question onLayer: (CCNode *) layer yesBlock: (void(^)())yesBlock noBlock: (void(^)())noBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Yes" withOpt1Block:yesBlock andOpt2:@"No" withOpt2Block:noBlock];
}

+ (void) Confirm: (NSString *) question onLayer: (CCNode *) layer okBlock: (void(^)())okBlock cancelBlock: (void(^)())cancelBlock {
    [self ShowAlert:question onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:@"Cancel" withOpt2Block:cancelBlock];
}

+ (void) Tell: (NSString *) statement onLayer: (CCNode *) layer okBlock: (void(^)())okBlock {
    [self ShowAlert:statement onLayer:layer withOpt1:@"Ok" withOpt1Block: okBlock andOpt2:nil withOpt2Block:nil];
}

@end




