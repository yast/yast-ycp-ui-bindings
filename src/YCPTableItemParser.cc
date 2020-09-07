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



  File:		YCPTableItemParser.h

  Author:	Stefan Hundhammer <shundhammer@suse.de>

/-*/


#include <ycp/YCPTerm.h>
#include <ycp/YCPBoolean.h>

#define y2log_component "ui"
#include <ycp/y2log.h>

#include "YCPTableItemParser.h"
#include "YCP_UI_Exception.h"
#include <yui/YUISymbols.h>

#define VERBOSE_PARSER	0


YItemCollection
YCPTableItemParser::parseTableItemList( const YCPList & itemList )
{
    YItemCollection itemCollection;
    itemCollection.reserve( itemList.size() );

    try
    {
	for ( int i=0; i < itemList->size(); i++ )
	{
	    YCPValue itemTerm = itemList->value(i);

	    if ( itemTerm->isTerm() &&
		 itemTerm->asTerm()->name() == YUISymbol_item )	// `item(...)
	    {
		YCPTableItem * item = parseTableItem( itemTerm->asTerm() );
		itemCollection.push_back( item );
	    }
	    else	// not `item(...)
	    {
		YUI_THROW( YCPDialogSyntaxErrorException( "Expected `item(...)", itemTerm ) );
	    }
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

#if VERBOSE_PARSER
    y2debug( "%d items", itemCollection.size() );
#endif

    return itemCollection;
}


YCPTableItem *
YCPTableItemParser::parseTableItem( const YCPTerm & itemTerm )
{
    YCPTableItem * item = new YCPTableItem();
    YUI_CHECK_NEW( item );
    YItemCollection children;

    const char * usage =
	"Expected: `item(`id(`myID), (\"MyLabelText\"|`cell(...)), ... )";

#if VERBOSE_PARSER
    y2debug( "Parsing: %s", itemTerm->toString().c_str() );
#endif

    try
    {
	for ( int i=0; i < itemTerm->size(); i++ )
	{
	    YCPValue arg = itemTerm->value(i);

#if VERBOSE_PARSER
	    y2debug( "Parsing term arg #%d: %s", i, arg->toString().c_str() );
#endif

	    if ( arg->isTerm() )			// `id(), `cell()
	    {
		YCPTerm term = arg->asTerm();

		if ( term->name() == YUISymbol_id	// `id(...)
		     && term->size() == 1
		     && ! item->hasId() )		// and don't have an ID yet
		{
		    item->setId( term->value(0) );
		}
		else if ( term->name() == YUISymbol_cell ) // `cell(...)
		{
		    parseTableCell( item, term );
		}
		else
		{
		    YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );
		}
	    }
	    else if ( arg->isString() )		// label (the user-visible text)
	    {
		item->addCell( arg->asString() );
	    }
	    else if ( arg->isInteger() )	// integer label (for backwards compatibility)
	    {
		item->addCell( arg->toString() );
	    }
	    else if ( arg->isVoid() )
	    {
		item->addCell( YCPString("") );
	    }
            else if ( arg->isList() )           // child items list
            {
                // A children list should be the next-to-last or the last
                // argument of the term, but it doesn't really matter where, so
                // let's just allow it anywhere. It is still best practice to
                // specifiy it at the end of the term, and better yet, it
                // should be followed by one of :open or :closed.

                children = parseTableItemList( arg->asList() );
            }
            else if ( arg->isSymbol()    &&     // :open  or  :closed
                      ( arg->asSymbol()->symbol() == YUISymbol_open   ||
                        arg->asSymbol()->symbol() == YUISymbol_closed    ) )
            {
                // This is a lot less strict than it could be, and this is
                // intentional:
                //
                // An application may specify :open or :closed anywhere in the
                // term, no matter if a children list was already specifed or
                // if there is one at all. If there are no children, setting
                // the item to open or closed does not do any harm.

                item->setOpen( arg->asSymbol()->symbol() == YUISymbol_open );
            }
	    else
	    {
		YUI_THROW( YCPDialogSyntaxErrorException( usage, itemTerm ) );
	    }
	}

	if ( ! item->hasId() )			// No ID specified?
	{
	    // Use the first non-empty cell label as ID for the entire item

	    for ( YTableCellConstIterator it = item->cellsBegin();
		  ! item->hasId() && it != item->cellsEnd();
		  ++it )
	    {
		if ( ! (*it)->label().empty() )
		    item->setId( YCPString( (*it)->label() ) );
	    }
	}
    }
    catch ( YUIException & exception )
    {
	delete item;
	throw;
    }


    // If there were any child items, add them to this item

    for ( YItemIterator it = children.begin(); it != children.end(); ++it )
        item->addChild( *it );

    return item;
}


void
YCPTableItemParser::parseTableCell( YCPTableItem * parent, const YCPTerm & cellTerm )
{
    YCPString label	= YCPNull();
    YCPString iconName	= YCPNull();
    YCPString sortKey	= YCPNull();

    const char * usage	= "Expected `cell(`icon(\"myicon.png\"), `sortKey(\"sda001\"), \"mylabel\")";

    if ( cellTerm->size() < 1 || cellTerm->size() > 3 )
	YUI_THROW( YCPDialogSyntaxErrorException( usage, cellTerm ) );

    for ( int i=0; i < cellTerm->size(); ++i )
    {
	YCPValue arg = cellTerm->value(i);

	if ( arg->isString() )		// label
	{
	    if ( ! label.isNull() )	// already have a label for this cell?
		YUI_THROW( YCPDialogSyntaxErrorException( usage, cellTerm ) );

	    label = arg->asString();
	}
	else if ( arg->isTerm() )	// `icon("myicon.png") or `sortKey("sda001")
	{
	    YCPTerm term = arg->asTerm();

	    if ( term->name() == YUISymbol_icon &&
		 term->size() == 1 &&
		 term->value(0)->isString() &&
		 iconName.isNull() )			// no icon name yet
	    {
		iconName = term->value(0)->asString();
	    }
	    else if ( term->name() == YUISymbol_sortKey &&
		      term->size() == 1 &&
		      term->value(0)->isString() &&
		      sortKey.isNull() )		// no sort key yet
	    {
		sortKey = term->value(0)->asString();
	    }
	    else
		YUI_THROW( YCPDialogSyntaxErrorException( usage, cellTerm ) );
        }
	else // other types
	{
	    YUI_THROW( YCPDialogSyntaxErrorException( usage, cellTerm ) );
	}
    }

    // Don't need to check if at least one of label or iconName found:
    // The cellTerm->size() check above and the other checks in the loop handle that.

    YUI_CHECK_PTR( parent );

    if ( label.isNull()    )
	label = YCPString( "" );

    if ( iconName.isNull() )
	iconName = YCPString( "" );

    if ( sortKey.isNull() )
	sortKey = YCPString( "" );

    parent->addCell( label, iconName, sortKey );
}
