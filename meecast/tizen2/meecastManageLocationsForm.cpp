/* vim: set sw=4 ts=4 et: */
/*
 * This file is part of Meecast for Tizen2
 *
 * Copyright (C) 2013 Vlad Vasilyeu
 *     for the code
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU  General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  General Public License for more details.
 *
 * You should have received a copy of the GNU  General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
*/
/*******************************************************************************/
#include <FApp.h>
#include <FLocations.h>
#include <FSystem.h>
#include "meecastManageLocationsForm.h"
#include "meecastLocationManager.h"

using namespace Tizen::Base;
using namespace Tizen::App;
using namespace Tizen::Ui;
using namespace Tizen::Ui::Controls;
using namespace Tizen::Ui::Scenes;
using namespace Tizen::Graphics;
using namespace Tizen::Base::Collection;
using namespace Tizen::Locations;

static const int LIST_HEIGHT = 112;

meecastManageLocationsForm::meecastManageLocationsForm(void)
                    : __pListView(null),
                    __pLocationManagerThread(null)
{
}

meecastManageLocationsForm::~meecastManageLocationsForm(void)
{
}

bool
meecastManageLocationsForm::Initialize(void)
{
    Construct(L"MANAGE_LOCATIONS_FORM");
    return true;
}

result
meecastManageLocationsForm::OnInitializing(void)
{
    result r = E_SUCCESS;

    _config = ConfigTizen::Instance( std::string("config.xml"),
                                       Core::AbstractConfig::prefix+
                                       Core::AbstractConfig::schemaPath+
                                       "config.xsd");

    // Setup back event listener
    SetFormBackEventListener(this);

    Header* pHeader = GetHeader();
    pHeader->SetTitleText(_("Manage locations"));



    // Creates an instance of ListView
    __pListView = static_cast <ListView*> (GetControl(L"IDC_LISTVIEW"));
    __pListView->SetItemProvider(*this);
    __pListView->AddListViewItemEventListener(*this);
    __pListView->SetTextOfEmptyList(_("No locations are set up yet."));

    // Adds the list view to the form
    AddControl(*__pListView);

	GetStationsList();
    /* Footer */
    Footer* pFooter = GetFooter();

    pFooter->AddActionEventListener(*this);

    Tizen::Ui::Controls::FooterItem* addButton;
    addButton = new Tizen::Ui::Controls::FooterItem(); 
    addButton->Construct(0);
    addButton->SetText(_("Add"));
    pFooter->AddItem(*addButton);

 	__pLocationManagerThread =  new (std::nothrow) meecastLocationManager();
	r = __pLocationManagerThread->Construct(*this);
	if (IsFailed(r)){
		AppLog("Thread Construct failed.");
		return r;
	}

    return r;
}

result
meecastManageLocationsForm::OnTerminating(void)
{
    result r = E_SUCCESS;

    // TODO:
    // Add your termination code here
    return r;
}

void
meecastManageLocationsForm::OnActionPerformed(const Tizen::Ui::Control& source, int actionId)
{
    SceneManager* pSceneManager = SceneManager::GetInstance();
    AppAssert(pSceneManager);

    AppLog("Check Action");
            
    switch(actionId)
    {
    case 0:  
        pSceneManager->GoForward(SceneTransitionId(L"ID_SCNT_SOURCESSCENE"));
        break;
    default:
        break;
    }
}

void
meecastManageLocationsForm::OnFormBackRequested(Tizen::Ui::Controls::Form& source)
{
	SceneManager* pSceneManager = SceneManager::GetInstance();
	AppAssert(pSceneManager);
	pSceneManager->GoBackward(BackwardSceneTransition(SCENE_TRANSITION_ANIMATION_TYPE_RIGHT));

}

void
meecastManageLocationsForm::OnSceneActivatedN(const Tizen::Ui::Scenes::SceneId& previousSceneId,
                                          const Tizen::Ui::Scenes::SceneId& currentSceneId, Tizen::Base::Collection::IList* pArgs)
{
    // TODO:
    // Add your scene activate code here
    AppLog("OnSceneActivatedN ManageLocations");
}

void
meecastManageLocationsForm::OnSceneDeactivated(const Tizen::Ui::Scenes::SceneId& currentSceneId,
                                           const Tizen::Ui::Scenes::SceneId& nextSceneId)
{
    // TODO:
    // Add your scene deactivate code here
    AppLog("OnSceneDeactivated");
}

int
meecastManageLocationsForm::GetItemCount(void)
{
    return _config->stationsList().size() + 1;
}

bool
meecastManageLocationsForm::DeleteItem(int index, Tizen::Ui::Controls::ListItemBase* pItem, int itemWidth)
{
	delete pItem;
	return true;
}


Tizen::Ui::Controls::ListItemBase*
meecastManageLocationsForm::CreateItem (int index, int itemWidth)
{
    CustomItem* pItem = new (std::nothrow) CustomItem();
    TryReturn(pItem != null, null, "Out of memory");

    pItem->Construct(Tizen::Graphics::Dimension(itemWidth, LIST_HEIGHT), LIST_ANNEX_STYLE_ONOFF_SLIDING);
    String* pStr;

    if (index == 0){
        pStr = new String (_("Find location via GPS"));
        pItem->AddElement(Tizen::Graphics::Rectangle(16, 32, 700, 50), 0, *pStr, 36,
                          Tizen::Graphics::Color(Color::GetColor(COLOR_ID_GREY)),
                          Tizen::Graphics::Color(Color::GetColor(COLOR_ID_GREY)),
                          Tizen::Graphics::Color(Color::GetColor(COLOR_ID_GREY)), true);
        if (_config->Gps())
            __pListView->SetItemChecked(index, true);
        else
            __pListView->SetItemChecked(index, false);
    }else{
        pStr = new String (_config->stationsList().at(index -1)->name().c_str()); 
        pItem->AddElement(Tizen::Graphics::Rectangle(16, 32, 700, 50), 0, *pStr, true);
        __pListView->SetItemChecked(index, true);
    }
	return pItem;
}


void
meecastManageLocationsForm::DeleteMessageBox(const Tizen::Base::String& Station, int index)
{
    MessageBox messageBox;
    messageBox.Construct(Station, L"Delete location?", MSGBOX_STYLE_YESNO, 30000);

    int modalResult = 0;

    // Calls ShowAndWait() : Draws and Shows itself and processes events
    messageBox.ShowAndWait(modalResult);
    switch (modalResult) {
        case MSGBOX_RESULT_YES: {
            _config->removeStation(index);
        }
        break;
        default:
            break;
    }
}
                                                                                     


void
meecastManageLocationsForm::OnListViewItemStateChanged(Tizen::Ui::Controls::ListView& listView, int index, int elementId, Tizen::Ui::Controls::ListItemStatus status){
    if (index == 0){
        if (status ==  LIST_ITEM_STATUS_UNCHECKED)
            _config->Gps(false);
        else{
            bool check;
            Tizen::System::SystemInfo::GetValue("http://tizen.org/feature/location", check); 
            if (check){
                _config->Gps(true);
                _config->saveConfig();
    	        __pLocationManagerThread->Start();
            }
            else{
                _config->Gps(false);
                _config->saveConfig();
            }
        }
        AppLog("Gps is changed ");
    }else{
        if (status ==  LIST_ITEM_STATUS_UNCHECKED){
            DeleteMessageBox(_config->stationsList().at(index-1)->name().c_str(), index-1);
            listView.UpdateList();
        }
    }
}
void
meecastManageLocationsForm::OnListViewItemSwept(Tizen::Ui::Controls::ListView& listView, int index, Tizen::Ui::Controls::SweepDirection direction){
}

void
meecastManageLocationsForm::OnListViewContextItemStateChanged(Tizen::Ui::Controls::ListView& listView, int index, int elementId, Tizen::Ui::Controls::ListContextItemStatus state){
}

void
meecastManageLocationsForm::OnItemReordered(Tizen::Ui::Controls::ListView& view, int oldIndex, int newIndex){
}

void
meecastManageLocationsForm::GetStationsList(void){
}


void
meecastManageLocationsForm::OnUserEventReceivedN(RequestId requestId, Tizen::Base::Collection::IList* pArgs){
	if (requestId == LOC_MGR_DRAW_SYNC_LOC_UPDATE){
        AppLog("Update List");
        __pListView = static_cast <ListView*> (GetControl(L"IDC_LISTVIEW"));
        __pListView->UpdateList();
	}else if(requestId == LOC_MGR_NOTIFY_ERROR){
		bool isSettingEnabled = CheckLocationSetting();
		if (!isSettingEnabled){
			LaunchLocationSettings();
		}
		else{
            int doModal;
            MessageBox messageBox;
            messageBox.Construct(_("Privacy protection"), _("Allow the MeeCast to use your location. You can change settings at Settings->Privacy."), MSGBOX_STYLE_OK, 0);
            messageBox.ShowAndWait(doModal);
		}
	}

	if(pArgs){
		pArgs->RemoveAll(true);
		delete pArgs;
	}

}

bool
meecastManageLocationsForm::CheckLocationSetting(void){
	bool hasPrivilege = false;
	bool gpsEnabled = true;
	bool wpsEnabled = true;

	result gps = Tizen::System::SettingInfo::GetValue(L"http://tizen.org/setting/location.gps", gpsEnabled);
	result wps = Tizen::System::SettingInfo::GetValue(L"http://tizen.org/setting/location.wps", wpsEnabled);

	hasPrivilege = gpsEnabled | wpsEnabled;
	if (gps != E_SUCCESS || wps != E_SUCCESS || hasPrivilege == false)
	{
		return false;
	}

	return true;
}

void
meecastManageLocationsForm::LaunchLocationSettings(void)
{
	int res;

	MessageBox messageBox;
	messageBox.Construct(L"Information", L"Location services are disabled. Enable them in location settings?", MSGBOX_STYLE_YESNO);
	messageBox.ShowAndWait(res);

	if (res == MSGBOX_RESULT_YES)
	{
		HashMap extraData;
		extraData.Construct();
		String categoryKey = L"category";
		String categoryVal = L"Location";
		extraData.Add(&categoryKey, &categoryVal);

		AppControl* pAc = AppManager::FindAppControlN(L"tizen.settings", L"http://tizen.org/appcontrol/operation/configure");

		if (pAc)
		{
			pAc->Start(null, null, &extraData, this);
			delete pAc;
		}
	}
	return;
}
