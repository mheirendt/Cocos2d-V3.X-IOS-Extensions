# Cocos2d-V3.X-IOS-Extensions
Customization for the cross-platform IOS game Development SDK Cocos2d V3.X.

AlertView

	-Concept: create a customizeable notification view to fit the style of the game that modally covers all background touches

	-Setup 1: Fork Repo or download zip. Add "Asset" folder to Spritebuilder. Add AlertView class to Xcode.

	-Setup 2: Add "#Import AlertView.h" to the header of any class you plan to use it with.  

	-Setup 3: Simply type [AlertView ShowAlert:@"ALERT" onLayer:self withOpt1:@"Okay" withOpt1Block:block andOpt2:nil withOpt2Block:nil];

	-setup 4: Button one is pre programmed to dismiss the alert and all its children.

	-NOTE: Alert view is not fully modal yet. You must disable background buttons and user interraction, then renable them with the option blocks
