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


  File:		YUIComponent.cc

  Author:	Stefan Hundhammer <sh@suse.de>

/-*/


#include <string.h>
#include <stdio.h>

#define YUILogComponent "ui-component"
#include <yui/YUILog.h>

#define y2log_component "ui-component"
#include <ycp/y2log.h>

#include <ycp/YCPValue.h>
#include <ycp/YCPVoid.h>

#include "YUIComponent.h"
#include "YUINamespace.h"
#include <yui/YUI.h>
#include <yui/YUILoader.h>
#include <yui/YUIException.h>
#include <yui/YSettings.h>

#include <yui/YMacro.h>
#include "YCPMacroRecorder.h"
#include "YCPMacroPlayer.h"


static void
yui_y2logger( YUILogLevel_t	logLevel,
	      const char *	logComponent,
	      const char *	sourceFileName,
	      int 	 	sourceLineNo,
	      const char * 	sourceFunctionName,
	      const char *	message );




// Most class variables are static so they can be accessed from static methods.

YUI *		YUIComponent::_ui		= 0;
YUIComponent *	YUIComponent::_uiComponent	= 0;
bool		YUIComponent::_useDummyUI	= false;


YUIComponent::YUIComponent( const string & name )
    : _requestedUIName( name )
    , _withThreads( false )
    , _macroFile( 0 )
    , _haveServerOptions( false )
    , _namespace( 0 )
    , _callbackComponent( 0 )
{
    if ( _uiComponent )
    {
	y2error( "UI component already created" );
	return;
    }

    _uiComponent = this;
}


YUIComponent::~YUIComponent()
{
    if ( _ui )
    {
	_ui->shutdownThreads(); // cannot be called in the UI's destructor
	delete _ui;
    }
}


void
YUIComponent::setRequestedUIName( const string & name )
{
    if ( ! name.empty() )
    {
	y2debug( "Setting requested UI name to \"%s\"", name.c_str() );
	_requestedUIName = name;
    }
}


YUIComponent *
YUIComponent::uiComponent()
{
    return _uiComponent;
}


Y2Namespace *
YUIComponent::import( const char* name )
{
    y2debug ("%s trying to import %s", this->name().c_str(), name);
    
    if ( strcmp (name, "UI") == 0)
    {
        if (_namespace == NULL)
        {
            _namespace = new YUINamespace(this);
	    y2debug ("Namespace created %p", _namespace);
        }

        return _namespace;
    }

    return NULL;
}


void
YUIComponent::createUI()
{
    if ( ! _haveServerOptions )
    {
	y2error( "createUI() called before setServerOptions() !" );
	return;
    }

    if ( _ui )
    {
	y2error( "Can't create multiple UIs!" );
	return;
    }

    if ( _useDummyUI )
    {
	y2warning( "Using dummy UI, NOT creating a UI" );
	return;
    }

    y2debug( "Creating UI" );
    
    YUILog::setLoggerFunction( yui_y2logger );
    YUILog::setEnableDebugLoggingHooks( set_log_debug,   // from y2log
					get_log_debug ); // from y2log

    try
    {
	if ( _requestedUIName.empty() )
	    YUILoader::loadUI( _withThreads );
	else
	    YUILoader::loadPlugin( _requestedUIName, _withThreads );

	_ui = YUI::ui();
        YSettings::setProgDir( YAST2DIR );
    
	YMacro::setRecorder( new YCPMacroRecorder() );
	YMacro::setPlayer  ( new YCPMacroPlayer()   );
    }
    catch ( YUIPluginPipeException & ex )
    {
	std::string pipe_err = "";

	YUI_CAUGHT( ex );

	pipe_err.append( "Can NOT setup UI-plugin properly. There was an error\n");
	pipe_err.append( "when finishing plugin-initialization by invoking\n" );
	pipe_err.append( "YUI::topmostConstructorHasFinished().\n\n" );
	pipe_err.append( "A YUIPluginPipeException() was thrown from there and\n" );
	pipe_err.append( "got rethrown from YUILoader::loadUI(). Message is:\n\n" );
	pipe_err.append( ex.asString() + "\n\n" );
	pipe_err.append( "Will call `exit( 2 );` now. <THIS IS EVIL !!!>" );

	y2error( pipe_err );

	/* THIS IS EVIL !!!
	   Taken from YUI::topmostConstructorHasFinished()
	   https://github.com/libyui/libyui/blob/master/src/YUI.cc#L182 */

	exit( 2 );
    }
    catch ( YUICantLoadAnyUIException & ex )
    {
	// Special case: Dummy UI (needed in test cases)

	YUI_CAUGHT( ex );
    }
}


YCPValue
YUIComponent::callBuiltin( void * function, int fn_argc, YCPValue fn_argv[] )
{
    if ( _useDummyUI )
	return YCPVoid();
    
    if ( ! _ui )
	createUI();

    return YCPNull();
}


void
YUIComponent::setServerOptions( int argc, char **argv )
{
    // Evaluate some command line arguments
	
    _withThreads = true;
    _macroFile	  = 0;

    for ( int i=0; i < argc; i++ )
    {
	if ( strcmp( argv[i], "--nothreads" ) == 0 )
	{
	    _withThreads = false;
	}
	else if ( strcmp( argv[i], "--macro" ) == 0 )
	{
	    if ( i+1 >= argc )
	    {
		y2error( "Missing arg for '--macro'" );
		fprintf( stderr, "y2base: Missing argument for --macro\n" );
		exit( 1 );
	    }
	    else
	    {
		_macroFile = argv[++i];
		y2milestone( "Playing macro '%s' from command line",
			     _macroFile ? _macroFile : "<NULL>" );
	    }
	}
    }

    _haveServerOptions = true;

    // For now, the values are only saved. The UI gets instantiated upon the
    // first call to YUIComponent::ui() which will usually happen when the
    // first UI builtin is due to be executed via the call handler (see
    // YUI_bindings.cc).
}


void
YUIComponent::result( const YCPValue & /*result*/ )
{
    if ( _ui )
    {
	_ui->shutdownThreads(); // cannot be called in the UI's destructor
	delete _ui;
	_ui = 0;
    }
}




static void
yui_y2logger( YUILogLevel_t	logLevel,
	      const char *	logComponent,
	      const char *	sourceFileName,
	      int 	 	sourceLineNo,
	      const char * 	sourceFunctionName,
	      const char *	message )
{
    loglevel_t y2logLevel = LOG_DEBUG;
    
    switch ( logLevel )
    {
	case YUI_LOG_DEBUG:	y2logLevel = LOG_DEBUG;		break;
	case YUI_LOG_MILESTONE:	y2logLevel = LOG_MILESTONE;	break;
	case YUI_LOG_WARNING:	y2logLevel = LOG_WARNING;	break;
	case YUI_LOG_ERROR:	y2logLevel = LOG_ERROR;		break;
    }

    if ( ! logComponent )
	logComponent = "??";

    if ( ! sourceFileName )
	sourceFileName = "??";

    if ( ! sourceFunctionName )
	sourceFunctionName = "??";

    if ( ! message )
	message = "";

    y2_logger( y2logLevel, logComponent,
	       sourceFileName, sourceLineNo, sourceFunctionName,
	       "%s", message );
}



// EOF
