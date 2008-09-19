// Whirled contrib library - tools for developing whirled games
// http://www.whirled.com/code/contrib/asdocs
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Keith Irwin
//
// $Id$
//
// ClickAnimateFurniture - A class for making animated and/or clickable
// furniture.

package com.whirled.contrib.display {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/** This class creates a furniture item which can respond to clicks
    and be animated.
    The preferred way to use it is to extend it.
    Ideally you should write a new class which extends this one
    and its constructor should call super() with an array of images,
    set the animations, set any desired flags, and then call start.

    <p>Generally speaking, unless you know what you are doing, you should
    stick to the public methods and members and avoid the protected ones.
    There is a tutorial in the wiki on how to use this class which includes
    examples.</p> */    
public class ClickAnimateFurniture extends Sprite
{
    /** Holds onto the Sprites which represent the different
	animation frames. */
    private var views : Array;
    /** This records which frame is currently being displayed so
	that we can remove it when it comes time to put in a
	new frame. */
    private var lastView : int;
    /** This holds the array of animations.  This can only be set via the
	method which will vet them for correctness first. */
    private var animations : Array;
    /** This is used for keeping track of which animation ran last
	in the case that returnToBaseAnimation is enabled so that
	we can cycle through the different animations. */
    private var lastNonBaseAnimation : int;
    /** This is the current frame index within the animation. */
    private var currentFrame : int;
    /** This is the current animation index within the animations. */
    private var currentAnimation : int;
    /** This is a flag which represents whether or not there should
	be one base animation which gets returned to at the completion
	of each other animation or not.  It cannot be set directly,
	instead it must be set via the provided methods. */
    private var returnToBaseAnimation : Boolean;

    /** This is the furniture control. */
    protected var control : FurniControl;
    /** This is the timer.  If you want to temporarily stop or pause
	the animations, the easiest way is to stop the timer and then
	start it when you want things to resume. */
    protected var timer : Timer;
    /** This is a flag which indicates whether or not the change
	in animations should be randomized or serial.  By default
	it is false, indicating that the animations will be cycled
	through in order.  If you set it to true, they will instead
	be cycled through in random order.

	@default <code>false</code> */
    public var randomizeAnimations : Boolean;

    /** The constructor. 
	@param images An Array of DisplayObjects.  Should be non-null,
	non-empty, and all contains objects should be subclasses of
	DisplayObject */
    public function ClickAnimateFurniture (images : Array)
    {
	/* Vetting our inputs, hooray.  Too bad we don't have 
	   strong type checking. */
	if (images == null) {
	    trace("A null array of images was passed to the constructor.");
	    trace("That's really not going to work and bad things will "+
		  "probably happen now.");
	    return;
	}
	
	if (images.length == 0) {
	    trace("An empty array was passed to the constructor.");
	    trace("That's really not going to work and bad things will "+
		  "probably happen now.");
	    return;
	}

	for (var j:int = 0; j<images.length; j++) {
	    if (images[j] == null) {
		trace("One of the images in the array is null.");
		trace("That's really not going to work and bad things will "+
		      "probably happen now.");
		return;
	    } else if (!(images[j] is flash.display.DisplayObject)) {
		trace("One of the things in the image array is not a "+
		      "DisplayObject of any sort.");
		trace("That's really not going to work and bad things will "+
		      "probably happen now.");
		return;
	    }
	}

        /* It is important to listen for the unload event in order
	   to make sure that everything gets cleaned up. */
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        control = new FurniControl(this);

	/* Here we set up an array of all the views.  Each view
	   is a frame in the animation which might be used.
	   We also set up a mouse listener which listens for
	   clicks to any frame of the animation.  The listeners
	   will not trigger at this point, however, as no frames
	   are displayed, so they cannot be clicked on. */
	views = new Array( images.length );
	for (var i:int=0; i < images.length; i++) {
	    var tempButton:Sprite = new Sprite;
	    tempButton.addChild(images[i]);
	    views[i] = tempButton;
	    /* We use MOUSE_UP rather than CLICK because with fast
	       animations, it may be very difficult to click quickly
	       enough that the mouse down and up both target the
	       same frame.  I tried it with CLICK and it really
	       just didn't work. */
	    tempButton.addEventListener(MouseEvent.MOUSE_UP, handleClick);
	}

	/* Initially no animations of any sort are set up. */
	animations = null;

	/* We want to default to non-randomized animations. */
	randomizeAnimations = false;

	/* We want to default to cycling through animations rather
	   than returning to the base animation at the end of an
	   animation. */
	returnToBaseAnimation = false;

	/* This is used when random animations are off, but the
	   return to base animation is turned on. */
	lastNonBaseAnimation = 0;

	/* Set up the timer and add a listener, but do not begin it running
	   yet.  The initial timer value is arbitrary and will not be
	   user for anything. */
	timer = new Timer(100);
	timer.addEventListener(TimerEvent.TIMER,handleTimer);

	trace("Constructor Finished\n");
    }

    /** This function checks an individual animation array to
	ensure its correctness.  It is just a helper function for
	verifyAnimations to make the code cleaner. Generally, it is not
	expected that this routing will be used outside of this class,
	but it may be helpful for debugging if you are unsure which
	animation is not set up properly. 

	<p>If the input is not properly formatted, specific information
	about the error can be found in the flash log file. </p>

	@param anim A single animation Array.  That is an Array of
	frames.  Each frame is an array of two integers.

	@return Returns true is the animation is properly formatted.
	False otherwise. */
    public static function verifyAnimation(anim : Array) : Boolean {
	if (anim == null) {
	    trace("Supplied animations array contains a null value.");
	    return false;
	} else {
	    for (var i:int = 0; i<anim.length;i++) {
		if (!anim[i] is Array) {
		    trace("Supplied animations array contains an animation "+
			  "array which contains a null value.");
		    return false;
		} else if (anim[i].length != 2) {
		    trace("Supplied animations array contains an animation "+
			  "array which contains a frame array whose size "+
			  "is not 2.");
		    return false;
		} else if ((!anim[i][0] is int) ||
			   (!anim[i][1] is int)) {
		    trace("Supplied animations array contains an animation "+
			  "array which contains a frame array which contains "+
			  "something which is not a number.");
		    return false;
		} else if ((anim[i][0] < 0) || (anim[i][1] < 1)) {
		    trace("Supplied animations array contains an animation "+
			  "array which contains a frame array which contains "+
			  "an improper value.");
		    return false;
		}
	    }
	}
	return true;
    }

    /** This routine verifies that the thing being passed as an animation
	really is an animation.  If it does not conform to the description
	of an animation then this will be detected.  This is a sanity
	check measure meant to protect against users who do not understand
	what they are doing.  This would be unnecessary in a language with
	stronger typing.  This function will not usually be called outside
	of this class, but it may be helpful for debugging in some cases.

	<p>If the input is not properly formatted, specific information
	about the error can be found in the flash log file. </p>

	@param anims An array of animations.  Each animation is itself
	an array of frames.  Each frame is an arry of two integers.

	@output True is the Array of animations is properly formatted.
	False otherwise. */
    public static function verifyAnimations(anims : Array) : Boolean {
	if (anims == null) {
	    trace("Current animations value is null.");
	    return false;
	} else {
	    for (var i:int = 0;i<anims.length;i++) {
		if (!anims[i] is Array) {
		    trace("Supplied animations array contains something "+
			  "which is not an array.");
		    return false;
		} else if (!verifyAnimation(anims[i])) { //Not recursive.
		    return false;
		}
	    }
	}
	return true;
    }

    /** This creates a very simple default animation.
	This default animation is used in the event that no animation
	has been supplied or that the supplied animation was incorrectly
	formatter.  In the default animation, the first x pictures which
	have been supplied are shown in order each for one half of a second.

	<p>It is not generally recommended that users call this.
	It is primarily here so that the furniture will do something
	in the case that no animation (or no properly formatted 
	animation) is ever set.</p>

        @param x The number of frames to use.

	@output A single properly formated animation array.  Not an
	array of animations. */
    public static function makeSimpleAnimation(x : int) : Array {
    	var output : Array = new Array (x);
    	for (var i : int = 0; i<x; i++) {
	    // Show the given images in order, each for 1/5 of a second.
	    output[i]=new Array(i,500);
	}
	return output;
    }

    /** This function is used to start the furniture.  Prior to
	this function being called, nothing will be displayed and
	nothing will happen.  It should normally be called in the
	constructor of the superclass.

	<p>Before this function is called, setAnimation should be called
	and any behavior flags (randomizeAnimations, returnToBaseAnimation) 
	should be set.</p> 

	<p>When called, this function does several things,
	including begining the first animation and registering
	the listeners for several events such as mouse clicks,
	communication with other instances, and timer events.</p> */
    public function start () : void {

	/* We want to have a good default in case the user fails to
	   set up the animations. */
	if (!verifyAnimations(animations)) {
	    trace("No valid animation supplied before call to start.");
	    trace("Using default animation.");
	    animations = new Array(1);
	    animations[0] = makeSimpleAnimation(views.length);
	}

	/* Here we check to see if the object has an existing value
	   for its current animation.  If returnToBaseAnimation is
	   enabled, this lookup should fail.  If it fails otherwise,
	   the furniture is probably being used for the first time
	   or there's been an upgrade and either way, we write a 0. */
	currentAnimation = control.getMemory("currentAnimation",-1) as int;
	if (currentAnimation == -1 ) {
	   currentAnimation = 0;
	   if (!returnToBaseAnimation) {
	       control.setMemory("currentAnimation",currentAnimation);
	   }
	}

	/* Start at the beginning. */
	currentFrame = 0;
	
	var currentView : int = animations[currentAnimation][currentFrame][0];
	this.addChild(views[currentView]);
	lastView = currentView;

	/* We want all instances of this furniture to be synchronized, so
	   we use the memory as the means of doing this when
	   returnToBaseAnimation is disabled. */
	control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);
	
	/* When it is enabled, we use messages instead. */
	if (returnToBaseAnimation) {
	    control.addEventListener(ControlEvent.MESSAGE_RECEIVED, 
				      messageReceived);
	}

	/* Whenever we have more than one frame to our animation
	   or when we're only showing the animation once, we need
	   to use a timer. */
	if ((animations[currentAnimation].length != 1) || 
	    (returnToBaseAnimation && (currentAnimation != 0))) {
	    timer.delay = animations[currentAnimation][currentFrame][1];
	    timer.start();
	}
    }

    /** This function is used to set or reset the animations which
	will be used.  It should be called before start.

	@param anims The format for this input is somewhat complex, so
	bear with me.  It takes an array as input.  Each member of this
	array should be an animation.  An animation is also
	an array.  Each member of the animation array should
	be a frame.  A frame is also an array.  A frame is an
	Array of size 2.  The first element is the frame number.
	This should be the index that the frame has in the image
	array passed to the constructor.  The second element
	is the time in milliseconds for which the frame should
	be displayed.  So essentially, anims is an Array of Arrays
	of Arrays of integers.  If something other than this
	is given as input, errors will appear in the log and
	the default animation will be used instead. */
    public function setAnimations (anims:Array) : void {
	if (!verifyAnimations(anims)) {
	    trace ("Invalid animation given to setAnimations.")
	} else {
	    animations = anims;

	    /* If there's more than one animation, then we set
	       buttonMode to be true so that the cursor will
	       turn into a hand to let the user know that things
	       are clickable. */
	    if (animations.length > 1) {
		buttonMode = true;
	    } else {
		buttonMode = false;
	    }
	}
    }

    /** This gets called whenever things change.
        It changes which frame is being displayed and starts the
	timer for the new frame, if appropriate. */
    protected function updateDisplay () :void {
	/* This should never give an error because we keep our animations
	   member private and vet any changes. */
	var currentView : int = animations[currentAnimation][currentFrame][0];

	/* We have to remove the old frame and replace it with the
	    new one. */
	if (lastView != currentView) { 
	   this.removeChild(views[lastView]);
	   this.addChild(views[currentView]);
	   lastView = currentView;
	}

	timer.reset();

	/* Whenever we have more than one frame to our animation
	   or when we're only showing the animation once, we need
	   to use a timer. */
	if ((animations[currentAnimation].length != 1) || 
	    (returnToBaseAnimation && (currentAnimation != 0))) {
	    timer.delay = animations[currentAnimation][currentFrame][1];
	    timer.start();
	}
    }

    /** This function is the callback for updates to the memory.  It
	enables it to be the case that when one user clicks on the
	furniture, it changes which animation is being shown
	for everyone. */
    protected function memoryChanged (event :ControlEvent) :void {
	var lastAnimation : int = currentAnimation;
	if (event.name == "currentAnimation") {
	   currentAnimation = event.value as int;

	   /* If this doesn't actually seem like a change to
	      us, then don't worry about restarting the animation.
	      The consequence of this is that if two people click
	      to change the state near the same time, they won't both
	      start and then reset. */
	   if (lastAnimation != currentAnimation) {
	       currentFrame = 0;
	       updateDisplay();
	   }
	}
    }

    /** This function is the callback for messages.  It enables it to
	be the case that when one user clicks on the furniture, the
	same animation plays for everyone. */
    protected function messageReceived (event :ControlEvent) : void {
	if (event.name == "changeAnimation") {
	    currentAnimation = event.value as int;
	    currentFrame = 0;
	    updateDisplay();
	}
    }

    /** This is the callback for mouse clicks.  It handles
	changing the animations, notifying everyone else and
	where applicable, saving the change. */
    protected function handleClick (event :Event) :void {
	/* If we only have one animation, we cannot change it. */
	if (animations.length == 1) {
	    return;
	}
	/* Likewise, if we're returning to the base animation,
	   then if there is only one other animation, then
	   we have to just replay it from the start. */
	if (!returnToBaseAnimation && animations.length == 2) {
	    currentAnimation = 1;
	    currentFrame = 0;
	    control.sendMessage("changeAnimation",1);
	    updateDisplay();
	    return;
	}

	if (randomizeAnimations) {
	    var lastAnimation : int = currentAnimation;

	    /* The offset is used to ensure that animation number 0
	       will not be chosen when returnToBaseAnimation is enabled. */
	    var offset : int = returnToBaseAnimation ? 1 : 0;

	    /* The while loop makes sure that our new random animation
	       is not the same as our current one.  We have previously
	       special-cased the situations where there is only one 
	       animation to choose from and where there are only two
	       animations and returnToBaseAnimation is enabled so
	       as to avoid the potential infinite loop. */
	    while (lastAnimation == currentAnimation) {
		currentAnimation = Math.floor
		    ( Math.random() * (animations.length-offset)) + offset;
	    }
	} else if (returnToBaseAnimation) {
	    /* In this case, we want to cycle through all the
	       non-base animations (i.e. all but index 0).
	       However, we might either be in either the base
	       animation or a non-base animation, so we've
	       added a new member so we'll know which one we
	       did last regardless of whether or not the current
	       one has finished. */
	    currentAnimation = lastNonBaseAnimation %
		(animations.length - 1) + 1;
	    lastNonBaseAnimation = currentAnimation;
	} else {
	    /* This is the easy case. */
	    currentAnimation = (currentAnimation + 1) %
		animations.length;
	} 

	/* We use messages for the returnToBaseAnimation case
	   because there's no point in storing which animation
	   is in use if it resets at the end of a given
	   animation anyway, and this way we avoid using
	   database space unnecessarily. */
	if (returnToBaseAnimation) {
	    control.sendMessage("changeAnimation",currentAnimation);
	} else {
	    control.setMemory("currentAnimation",currentAnimation);
	}
	currentFrame = 0;
	updateDisplay();
    }

    /** This is the callback for the timer.  It advances the frame,
	looping if necessary.  If returnToBaseAnimation is true, it
	also detects when a given animation has finished and goes
	back to the base animation.  It does not synchronize the
	return to the base animation with other instances because if
	some instances are running slower than others, we would still
	like them to be able to see the complete animation. */
    protected function handleTimer (event :TimerEvent) : void {
	if (event.type == TimerEvent.TIMER) {
	    currentFrame = (currentFrame + 1) % 
		animations[currentAnimation].length;
	    if (returnToBaseAnimation) {
		if (currentFrame == 0) {
		    currentAnimation = 0;
		}
	    }
	    updateDisplay();
	}
    }

    /** This is the callback for when the furniture is unloaded.
	It handles clean-up. */
    protected function handleUnload (event :Event) :void {
        root.loaderInfo.removeEventListener(Event.UNLOAD, handleUnload);
	control.removeEventListener(ControlEvent.MEMORY_CHANGED,
		memoryChanged);
	if (returnToBaseAnimation) {
	    control.removeEventListener(ControlEvent.MESSAGE_RECEIVED, 
				      messageReceived);
	}
	for (var i:int=0; i < views.length; i++) {
	    views[i].removeEventListener(MouseEvent.MOUSE_UP, handleClick);
	}
	timer.stop();
	timer.removeEventListener(TimerEvent.TIMER,handleTimer);
    }

    /** This function is used to cause the furniture to always
	return to its basic animation state. 
	If this has been called, then the furniture item
	will carry out the first animation until it is clicked on.
	When clicked on, it will play another animation through
	once and then will return to the first animation.
	If randomization is enabled, the animation it plays
	will be random.  Otherwise, it will play the animations
	in order, one for each click. */
    public function enableReturnToBaseAnimation() : void {
	if (!returnToBaseAnimation) {
	    returnToBaseAnimation = true;
	    control.addEventListener(ControlEvent.MESSAGE_RECEIVED,
				     messageReceived);
	}
    }	

    /** This function restores the default behavior, which is that
	the furniture changes animation states every time it is 
	clicked.  When the furniture is clicked, it changes animations
	and then runs the new animation over and over until the
	next time it gets cicked.
	<p>By default, returning to the base animation is disabled.
	This function does not need to be called unless 
	enableReturnToBaseAnimation has been called.</p> */
    public function disableReturnToBaseAnimation() : void {
	if (returnToBaseAnimation) {
	    returnToBaseAnimation = false;
	    control.removeEventListener(ControlEvent.MESSAGE_RECEIVED,
					messageReceived);
	}
    }

}
}
