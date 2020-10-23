/****************************************************************************

Copyright (c) 2000 - 2010 Novell, Inc.
Copyright (c) 2019 - 2020  SUSE LLC
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

  File:		YCPPropertyHandler.h

		Widget property handlers for not-so-trivial properties.

  Author:	Stefan Hundhammer <shundhammer@suse.de>

/-*/


#ifndef YCPPropertyHandler_h
#define YCPPropertyHandler_h

#include <ycp/YCPValue.h>
#include <ycp/YCPMap.h>
#include <ycp/YCPTerm.h>
#include <string>
#include <yui/YItem.h>

using std::string;

class YCPItem;
class YWidget;
class YSelectionWidget;
class YMenuWidget;


/**
 * Get and set complex widget properties.
 *
 * Simple properties of types string, bool, int are set with
 * YWidget::setProperty() and retrieved with YWidget::getProperty().
 *
 * The functions here are needed for more complex cases, either because there
 * is no unambiguous conversion from a C++ data type to a YCPValue (or vice
 * versa) or for historical reasons to maintain backward compatibility with
 * existing YCP code.
 **/
class YCPPropertyHandler
{
public:
    /**
     * Set a complex property.
     *
     * Return 'true' on success, 'false' on failure.
     **/
    static bool setComplexProperty( YWidget *		widget,
				    const string &	propertyName,
				    const YCPValue &	val );

    /**
     * Set a complex property from a term (like `Item(`someID) )
     *
     * Return 'true' on success, 'false' on failure.
     **/
    static bool setComplexProperty( YWidget *		widget,
				    const YCPTerm &	propertyTerm,
				    const YCPValue &	val		);

    /**
     * Get a complex property.
     *
     * Return YCPNull upon failure, a non-null YCPValue (the result) upon success.
     **/
    static YCPValue getComplexProperty( YWidget *	widget,
					const string &	propertyName );

    /**
     * Get a complex property from a term (like `Item(`someID) )
     *
     * Return YCPNull upon failure, a non-null YCPValue (the result) upon success.
     **/
    static YCPValue getComplexProperty( YWidget *	widget,
					const YCPTerm &	propertyTerm );


protected:

    /**
     * All trySet..() functions try to dynamic_cast 'widget' to the expected
     * widget type and then set a property.
     *
     * They all return 'true' upon success and 'false' upon failure.
     **/
    static bool trySetCheckBoxValue			( YWidget * widget, const YCPValue & val );
    static bool trySetSelectionBoxValue			( YWidget * widget, const YCPValue & val );
    static bool trySetItemSelectorValue			( YWidget * widget, const YCPValue & val );
    static bool trySetTreeValue				( YWidget * widget, const YCPValue & val );
    static bool trySetTableValue			( YWidget * widget, const YCPValue & val );
    static bool trySetDumbTabValue			( YWidget * widget, const YCPValue & val );
    static bool trySetComboBoxValue			( YWidget * widget, const YCPValue & val );
    static bool trySetMenuWidgetItems			( YWidget * widget, const YCPValue & val );
    static bool trySetTreeItems				( YWidget * widget, const YCPValue & val );
    static bool trySetTableItems			( YWidget * widget, const YCPValue & val );
    static bool trySetTableCell				( YWidget * widget, const YCPTerm  & propTerm, const YCPValue & val );
    static bool trySetItemSelectorItems			( YWidget * widget, const YCPValue & val );
    static bool trySetSelectionWidgetItems		( YWidget * widget, const YCPValue & val );
    static bool trySetSelectionWidgetItemStatus		( YWidget * widget, const YCPValue & val );
    static bool trySetRadioButtonGroupCurrentButton	( YWidget * widget, const YCPValue & val );
    static bool trySetMultiSelectionBoxSelectedItems	( YWidget * widget, const YCPValue & val );
    static bool trySetItemSelectorSelectedItems		( YWidget * widget, const YCPValue & val );
    static bool trySetTableSelectedItems		( YWidget * widget, const YCPValue & val );
    static bool trySetTreeSelectedItems			( YWidget * widget, const YCPValue & val );
    static bool trySetMultiSelectionBoxCurrentItem	( YWidget * widget, const YCPValue & val );
    static bool trySetMultiProgressMeterValues		( YWidget * widget, const YCPValue & val );
    static bool trySetBarGraphValues			( YWidget * widget, const YCPValue & val );
    static bool trySetBarGraphLabels			( YWidget * widget, const YCPValue & val );
    static bool trySetMenuWidgetEnabledItems		( YWidget * widget, const YCPValue & val );

    /**
     * All tryGet..() functions try to dynamic_cast 'widget' to the expected
     * widget type and then retrieve a property.
     *
     * They all return YCPNull upon failure and a non-null YCPValue upon success.
     **/
    static YCPValue tryGetCheckBoxValue			( YWidget * widget );
    static YCPValue tryGetSelectionBoxValue		( YWidget * widget );
    static YCPValue tryGetItemSelectorValue		( YWidget * widget );
    static YCPValue tryGetTreeValue			( YWidget * widget );
    static YCPValue tryGetTableValue			( YWidget * widget );
    static YCPValue tryGetDumbTabValue			( YWidget * widget );
    static YCPValue tryGetComboBoxValue			( YWidget * widget );
    static YCPValue tryGetRadioButtonGroupCurrentButton	( YWidget * widget );
    static YCPValue tryGetMultiSelectionBoxSelectedItems( YWidget * widget );
    static YCPValue tryGetItemSelectorSelectedItems	( YWidget * widget );
    static YCPValue tryGetTableSelectedItems		( YWidget * widget );
    static YCPValue tryGetTreeSelectedItems		( YWidget * widget );
    static YCPValue tryGetMultiSelectionBoxCurrentItem	( YWidget * widget );
    static YCPValue tryGetOpenItems			( YWidget * widget );
    static YCPValue tryGetTreeCurrentBranch		( YWidget * widget );
    static YCPValue tryGetWizardCurrentItem		( YWidget * widget );
    static YCPValue tryGetTableCell			( YWidget * widget, const YCPTerm & propertyTerm );
    static YCPValue tryGetTableItem			( YWidget * widget, const YCPTerm & propertyTerm );
    static YCPValue tryGetTableItems			( YWidget * widget );
    static YCPValue tryGetTreeItems			( YWidget * widget );
    static YCPValue tryGetItemSelectorItems		( YWidget * widget );
    static YCPValue tryGetMenuWidgetItems		( YWidget * widget );
    static YCPValue tryGetSelectionWidgetItems		( YWidget * widget );
    static YCPValue tryGetSelectionWidgetItemStatus	( YWidget * widget );
    static YCPValue tryGetBarGraphValues		( YWidget * widget );
    static YCPValue tryGetBarGraphLabels		( YWidget * widget );
    static YCPValue tryGetTreeCurrentItem		( YWidget * widget );
    static YCPValue tryGetMenuWidgetEnabledItems        ( YWidget * widget );


    /**
     * Set the status of a widget's item to a new value.
     **/
    static bool setItemStatus	( YSelectionWidget *	widget,
				  const YCPValue &	itemId,
				  const YCPValue &	newStatus );

    /**
     * Enable or disable a menu item.
     **/
    static bool setItemEnabled	( YMenuWidget *		widget,
				  const YCPValue &	itemId,
				  const YCPValue &	newEnabled );

    /**
     * Helper function for tryGetOpenItems(): Get any open tree items
     * between iterators 'begin' and 'end' and add them to the 'openItems' map.
     **/
    static void getOpenItems( YCPMap &                  openItems,
                              YItemConstIterator	begin,
                              YItemConstIterator	end );

    /**
     * Helper function for tryGetMenuWidgetEnabledItems(): Get the enabled /
     * disabled status of items between iterators 'begin' and 'end' for all
     * items that have an ID and add them to the itemStatusMap.
     **/
    static void getMenuWidgetEnabledItems( YCPMap &		itemStatusMap,
                                           YItemConstIterator	begin,
                                           YItemConstIterator	end );
};


#endif // YCPPropertyHandler_h
