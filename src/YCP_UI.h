/****************************************************************************

Copyright (c) 2000 - 2010 Novell, Inc.
All Rights Reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of version 2 of the GNU General Public License as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, contact Novell, Inc.

To contact Novell about this file by physical or electronic mail,
you may find current contact information at www.novell.com

****************************************************************************


  File:		YCP_UI.cc

  Authors:	Stefan Hundhammer <shundhammer@suse.de>

/-*/


#ifndef YCP_UI_h
#define YCP_UI_h

#include <deque>

#include <ycp/YCPString.h>
#include <ycp/YCPVoid.h>
#include <ycp/YCPTerm.h>
#include <ycp/YCPInteger.h>
#include <ycp/YCPMap.h>
#include <ycp/YCPBoolean.h>


class YCP_UI
{
public:
    //
    // UI Built-ins. Each function directly corresponds to a YCP UI::Something() call.
    //
    // See the documentation at the function definitions for details
    //

    static YCPValue	AskForExistingDirectory		( const YCPString & startDir, const YCPString & headline );
    static YCPValue 	AskForExistingFile		( const YCPString & startDir, const YCPString & filter, const YCPString & headline );
    static YCPValue 	AskForSaveFileName		( const YCPString & startDir, const YCPString & filter, const YCPString & headline );
    static void         AskForWidgetStyle               ();
    static void 	BusyCursor			();
    static void 	Beep     			();
    static YCPValue 	ChangeWidget			( const YCPValue & widgetId, const YCPValue & property, const YCPValue & new_value );
    static void 	CheckShortcuts			();
    static YCPValue 	CloseDialog			();
    static void 	CloseUI				();
    static void 	DumpWidgetTree			();
    static void 	FakeUserInput			( const YCPValue & nextInput );
    static YCPMap 	GetDisplayInfo			();
    static YCPString 	GetLanguage			( const YCPBoolean & stripEncoding );
    static YCPString 	GetProductName			();
    static YCPString 	Glyph				( const YCPSymbol & symbol );
    static YCPValue 	HasSpecialWidget		( const YCPSymbol & widget );
    static void 	MakeScreenShot			( const YCPString & filename );
    static void 	NormalCursor			();
    static YCPBoolean 	OpenContextMenu			( const YCPTerm & term );
    static YCPBoolean 	OpenDialog			( const YCPTerm & opts, const YCPTerm & dialogTerm );
    static void 	OpenUI				();
    static void 	PlayMacro			( const YCPString & filename );
    static void 	PostponeShortcutCheck		();
    static YCPValue 	QueryWidget			( const YCPValue & widgetId, const YCPValue& property );
    static void 	RecalcLayout			();
    static YCPValue 	Recode				( const YCPString & fromEncoding, const YCPString & toEncoding, const YCPString & text );
    static void 	RecordMacro			( const YCPString & fileName );
    static void 	RedrawScreen			();
    static YCPBoolean 	ReplaceWidget			( const YCPValue & widgetId, const YCPTerm & term );
    static YCPValue 	RunPkgSelection			( const YCPValue & widgetId );
    static void 	SetConsoleFont			( const YCPString & magic,
							  const YCPString & font,
							  const YCPString & screen_map,
							  const YCPString & unicode_map,
							  const YCPString & encoding );

    static void 	SetKeyboard			();
    static YCPInteger 	RunInTerminal			( const YCPString & module);
    static YCPBoolean 	SetFocus			( const YCPValue & widgetId );
    static void 	SetFunctionKeys			( const YCPMap & functionKeyMap );
    static void 	SetLanguage			( const YCPString & lang, const YCPString & encoding = YCPNull() );
    static void 	SetProductName			( const YCPString & name );
    static void 	StopRecordMacro			();
    static YCPBoolean 	WidgetExists			( const YCPValue & widgetId );
    static YCPValue 	UserInput			();
    static YCPValue 	TimeoutUserInput		( const YCPInteger & timeout );
    static YCPValue 	WaitForEvent			( const YCPInteger & timeout = YCPNull() );
    static YCPValue 	WizardCommand			( const YCPTerm & command );
    static YCPValue 	PollInput			();
    static YCPBoolean	TextMode			();
    static YCPValue	SetReleaseNotes			( const YCPMap & relnotes );
    static YCPValue	SetProductLogo			( const YCPBoolean & show_logo);
    static YCPValue	SetApplicationIcon      	( const YCPString & icon);
    static YCPValue	SetApplicationTitle      	( const YCPString & text);



    /**
     * Not really a UI built-in: This implements the WFM or SCR callback command.
     **/
    static YCPValue	evaluateCallback		( const YCPTerm & term, bool to_wfm );

protected:

    /**
     * Mid-level handler for the user input related UI commands:
     *	   UserInput()
     *	   TimeoutUserInput()
     *	   WaitForEvent()
     *	   PollInput()
     *
     * 'builtin_name' is the name of the specific UI builtin command (to use
     * the correct name in the log file).
     *
     * 'timeout_millisec' is the timeout in milliseconds to use (0 for "wait
     * forever").
     *
     * 'wait' specifies if this should wait until an event is available if
     * there is none yet.
     *
     * 'detailed' specifies if a full-fledged event map is desired as return
     * value (WaitForEvent()) or one simple YCPValue (an ID).
     **/
    static YCPValue doUserInput( const char *	builtin_name,
				 long 		timeout_millisec,
				 bool 		wait,
				 bool 		detailed );

    //
    // Data members
    //

    /**
     * Queue for synthetic (faked) user input events.
     * Filled with FakeUserInput(), consumed with UserInput() and related.
     **/
    static std::deque<YCPValue> _fakeUserInputQueue;


private:
    YCP_UI() {}
    ~YCP_UI() {}
};

#endif // YCP_UI_h
