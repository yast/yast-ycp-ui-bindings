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


  File:		YCPItemParser.h

  Author:	Stefan Hundhammer <sh@suse.de>

/-*/


#include <ycp/YCPTerm.h>
#include <ycp/YCPBoolean.h>
#include <ycp/YCPInteger.h>

#include "YCPItemParser.h"
#include "YCP_UI_Exception.h"
#include <yui/YUISymbols.h>


YItemCollection
YCPItemParser::parseItemList( const YCPList & itemList )
{
    return parseItemListInternal( itemList,
                                  false ); // allowDescription
}


YItemCollection
YCPItemParser::parseDescribedItemList( const YCPList & itemList )
{
    return parseItemListInternal( itemList,
                                  true); // allowDescription
}


YItemCollection
YCPItemParser::parseItemListInternal( const YCPList & itemList, bool allowDescription )
{
    YItemCollection itemCollection;
    itemCollection.reserve( itemList.size() );

    try
    {
	for ( int i=0; i < itemList->size(); i++ )
	{
	    YCPItem * item = parseItem( itemList->value(i), allowDescription );
	    itemCollection.push_back( item );
	}
    }
    catch ( YUIException & exception )
    {
	// Delete all items created so far

	YItemIterator it = itemCollection.begin();

	while ( it != itemCollection.end() )
	{
	    YItem * item = *it;
	    ++it;
	    delete item;
	}

	throw;
    }

    return itemCollection;
}



YCPItem *
YCPItemParser::parseItem( const YCPValue & rawItem, bool allowDescription )
{
    YCPItem * item = 0;

    if ( rawItem->isString() )		// Simple case: just a string
    {
	YCPString label = rawItem->asString();
	item = new YCPItem( label );
    }
    else				// `item(...)
    {
	if ( rawItem->isTerm() &&
	     rawItem->asTerm()->name() == YUISymbol_item )	// `item(...)
	{
	    item = parseItem( rawItem->asTerm(), allowDescription );
	}
	else	// not `item(...)
	{
	    YUI_THROW( YCPDialogSyntaxErrorException( "Expected `item(...)", rawItem ) );
	}
    }

    return item;
}


YCPItem *
YCPItemParser::parseItem( const YCPTerm & itemTerm, bool allowDescription )
{
    YCPValue	id	        = YCPNull();
    YCPString	iconName        = YCPNull();
    YCPString	label	        = YCPNull();
    YCPString   description     = YCPNull();
    YCPBoolean  selected        = YCPNull();
    YCPInteger  status          = YCPNull();

    const char * usage =
	"Expected: `item(`id(`myID), `icon(\"MyIcon.png\"), \"MyItemText\", \"Description\", (bool|int) status )";


    for ( int i=0; i < itemTerm->size(); i++ )
    {
	YCPValue arg = itemTerm->value( i );

	if ( arg->isTerm() )	// `id(), `icon()
	{
	    YCPTerm term = arg->asTerm();

	    if ( term->size() != 1 )		// Both `id() and `icon() have 1 argument
		YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );

	    if ( term->name() == YUISymbol_id		// `id(...)
		 && id.isNull() )			// and don't have an ID yet
	    {
		id = term->value(0);
	    }
	    else if ( term->name() == YUISymbol_icon	// `icon(...)
		      && term->value(0)->isString()	// with a string argument
		      && iconName.isNull() )		// and don't have an icon name yet
	    {
		iconName = term->value(0)->asString();
	    }
	    else
	    {
		YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );
	    }
	}
	else if ( arg->isString() )             // label or description
        {
            if ( label.isNull() )		// No label yet?
            {
                label = arg->asString();
            }
            else if ( description.isNull() && allowDescription )
            {
                description = arg->asString();
            }
            else                                // One string too many
            {
                YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );
            }
        }
	else if ( arg->isBoolean() 		// Old syntax: Boolean "selected" flag
		  && status.isNull() )          // and don't have a status yet
	{
	    status = arg->asBoolean()->value() ? 1 : 0;
	}
	else if ( arg->isInteger()              // New syntax: Integer status
                  && status.isNull() )          // and don't have a status yet
        {
            status = arg->asInteger();
        }
	else
	{
	    YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );
	}
    }

    if ( label.isNull() )		// the label is required
	YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );

    if ( iconName.isNull() )
	iconName = YCPString( "" );

    if ( description.isNull() )
        description = YCPString( "" );

    if ( id.isNull() )			// no `id() ?
	id = label;			// use the label instead

    YCPItem * item = new YCPItem( id, label, description, iconName );
    YUI_CHECK_NEW( item );

    if ( ! status.isNull() )
	item->setStatus( status->value() );

    return item;
}
