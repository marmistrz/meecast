import bb.cascades 1.0


NavigationPane {
    
    id: rootWindow
    // Create the initial screen
    Page {
        id: main
        property int screen_width : 1280
        property int screen_height : 768
        property int day: 0
        property bool current: false
        property string day_period: "day"


        function update_list(){
            forrecasts_list.dataModel.clear();
            for (var a = 0; a < Forecast_model.rowCount(); a++) {
                forrecasts_list.dataModel.insert(
                    {
                     "fulldate" : Forecast_model.getdata(a, "fulldate"),
                     "shortdate" : Forecast_model.getdata(a, "shortdate"),
                     "pict" : Config.iconspath + "/" + Config.iconset + "/" + Forecast_model.getdata(a, "pict"),
                     "temp_high" : Forecast_model.getdata(a, "temp_high"),
                     "temp_low" : Forecast_model.getdata(a, "temp_low"),
                     "bg_color" :  (a % 2 != 0) ? "#000000" : "#0f0f0f",
                     "hi_temp_color" :  main.getColor(Forecast_model.getdata(a, "temp_high")),
                     "number" : a
                    }
                )
            }
        }
        function update_current_data(){
            if (Current.getdata(0, "temp") == "N/A"){
                current_temp_text.text = ""
                if (Current.getdata(0, "temp_high") != "N/A")
                   current_temp_text.text = Current.getdata(0, "temp_high") + '°'
                if ((Current.getdata(0, "temp_low") != "N/A") && (Current.getdata(0, "temp_high") != "N/A"))
                if (Current.getdata(0, "temp_low") != "N/A")
                   current_temp_text.text = current_temp_text.text + ' / '+ Current.getdata(0, "temp_low") + '°'
                current_rect_back.background = Color.create(main.getColor(Current.getdata(0, "temp_high")));
            }else{
               current_temp_text.text = Current.getdata(0, "temp") + '°'
               current_rect_back.background = Color.create(main.getColor(Current.getdata(0, "temp")));
            }
        }

        function getColor(t) {
            var c1, c2, c3;
            if (Config.temperatureunit == "F"){
                t = (t - 32) * 5 / 9;
            }
            if (t >= 30){
                c2 = (t - 50)*(246/255-60/255)/(30-50) + 60/255;
                return Qt.rgba(1, c2, 0, 1);
            }else if (t < 30 && t >= 15){
                c1 = (t - 30)*(114/255-1)/(15-30) + 1;
                c2 = (t - 30)*(1-246/255)/(15-30) + 246/255;
                return Qt.rgba(c1, c2, 0, 1);
            }else if (t < 15 && t >= 0){
                c1 = (t - 15)*(1-114/255)/(0-15) + 144/255;
                c3 = (t - 15)*(1-0)/(0-15) + 0;
                return Qt.rgba(c1, 1, c3, 1);
            }else if (t < 0 && t >= -15){
                c1 = (t - 0)*(0-1)/(-15-0) + 1;
                c2 = (t - 0)*(216/255-1)/(-15-0) + 1;
                return Qt.rgba(c1, c2, 1, 1);
            }else if (t < -15 && t >= -30){
                c2 = (t - (-15))*(66/255-216/255)/(-30+15) + 216/255;
                //console.log(t+ " "+c2);
                return Qt.rgba(0, c2, 1, 1);
            }else if (t < -30){
                c1 = (t - (-30))*(132/255-0)/(-30+15) + 0;
                c2 = (t - (-30))*(0-66/255)/(-30+15) + 66/255;
                return Qt.rgba(c1, c2, 1, 1);
            }
        }
 
        function updatestationname(){
            console.log("updatestationname() ", Config.stationname );
            console.log(" pATH !!!! ", Config.imagespath);
            main.updatemodels();
            stationname.text = Config.stationname == "Unknown" ? "MeeCast" : Config.stationname
            left_arrow.visible = Config.prevstationname == "" ? false : true;
            right_arrow.visible = Config.nextstationname == "" ? false : true;
            sourceicon.visible = false;
            sourceicon.imageSource = Config.imagespath + "/" + Config.source + ".png";
            sourceicon.visible = true;
        }


        function onConfigChanged() {
            console.log("end update station name = "+Config.stationname);
            startview.visible = Config.stationname == "Unknown" ? true : false;
//            mainview.visible = Config.stationname == "Unknown" ? false : true;
            main.updatestationname();
            //isUpdate = false;
        }

        function updatemodels()
        {
            Current.reload_data(Config.filename);
            Current.update_model(0);
            Current_night.update_model(1);
            Forecast_model.update_model(2);
            Forecast_night_model.update_model(3);
            Forecast_hours_model.update_model(4);
            main.update_list();
            main.update_current_data();
            //list.height = 80 * Forecast_model.rowCount();
            console.debug ("Forecast_model.rowCount()", Forecast_model.rowCount(), Current.rowCount());
            //dataview.visible = (Forecast_model.rowCount() == 0 || Current.rowCount() == 0) ? true : false;
            current_rect.visible = Current.rowCount() == 0 ? false : true;
            //list.visible = (Forecast_model.rowCount() == 0) ? false : true;
        }

   
        content: Container {
            background: Color.Black

            onCreationCompleted: {
                 Config.configChanged.connect (main.onConfigChanged);
            }
            layout: AbsoluteLayout {}

            Container{
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0
                    positionY: 560
                }
                background: Color.Black
                preferredWidth: 768
                preferredHeight: 1000
            }

            Container{
                id: startview
                visible : Config.stationname == "Unknown" ? true : false;
                preferredWidth: 768
                background: Color.Black
                layout: AbsoluteLayout {
                }
                Container{
                    preferredWidth: 768
                    preferredHeight: 438
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 30
                    }
                    background: Color.White

                }
                ImageView {
                    imageSource: "asset:///share/images/mask_background.png"
                    preferredWidth: 768
                    preferredHeight: 438
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 30
                    }
                }
                Label {
                    text: Config.tr("No locations are set up yet.") 
                    horizontalAlignment: HorizontalAlignment.Center
                    preferredWidth: 768 
                    multiline: true
                    textStyle.textAlign: TextAlign.Center
                    textStyle {
                            base: SystemDefaults.TextStyles.BigText
                            color: Color.create("#999999")
                    }
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 400 
                    }
                }
            }
            Container{
                background: Color.Black
                preferredWidth: 768
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0
                    positionY: 95
                }
                onTouch: {
                    if (event.isDown()) {
                        main.day = 0;
                        main.day_period = "day";
                        main.current = true;
                        var newPage = fullpageDefinition.createObject();
                        rootWindow.push(newPage);
                    }
                }
                
                id: current_rect
                visible: Current.rowCount() == 0 ? false : true
                layout: AbsoluteLayout {
                }
                Container{
                    id: current_rect_back
                    preferredWidth: 768
                    preferredHeight: 438
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 30
                    }
                    background: Color.Red
                }
                ImageView {
                    imageSource: "asset:///share/images/mask_background_main.png"
                    preferredWidth: 768
                    preferredHeight: 438
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 30
                    }
                    visible: true
                }
                Container{
                    preferredWidth: 768
                    layout: DockLayout {}
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 50.0
                    }
                    Container{
                        horizontalAlignment: HorizontalAlignment.Left
                        preferredWidth: 768/2 - 128*1.6/2 
                        Label {
                            text: Current.getdata(0, "current") == true ? Config.tr("Now") : Config.tr("Today")
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.textAlign: TextAlign.Center
                            textStyle {
                                base: SystemDefaults.TextStyles.BigText
                                color: Color.White
                            }
                        }
                    }
                    Container{
                        id: current_temperature
                        horizontalAlignment: HorizontalAlignment.Right
                        preferredWidth: 768/2 - 128*1.6/2                   
                        Label {                 
                            id: current_temp_text
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            textStyle.textAlign: TextAlign.Center
                            textStyle {
                                base: SystemDefaults.TextStyles.BigText
                                color: Color.White
                            }
                            onCreationCompleted: {
                                main.update_current_data();
                            }
                        }    
                    }               
                }
                Container{
                    id: title
                    preferredWidth: 768
                    layout: DockLayout {}
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 165.0
                    }
                    Label {                 
                        text: Config.tr(Current.getdata(0, "description"));
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle {
                           base: SystemDefaults.TextStyles.BodyText
                           color: Color.White
                        }
                    }
                }
                Container{
                    id: humidity_and_wind_direction
                    preferredWidth: 768
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    layoutProperties: AbsoluteLayoutProperties {
                        positionY: 290.0
                    }
                    Container{
                        id: humidity
                        horizontalAlignment: HorizontalAlignment.Left
                        preferredWidth: 768/2
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        ImageView {
                            imageSource: "asset:///share/images/humidity.png"
                            preferredWidth: 30*1.6
                            preferredHeight: 30*1.6
                        }
                        Label {
                            text: Current.getdata(0, "humidity") + " %";
                            verticalAlignment: VerticalAlignment.Center
                            //horizontalAlignment: HorizontalAlignment.Left
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                                color: Color.White
                            }
                        }
                    }
                    Container{
                        id: wind_direction
                        function getAngle(s)
                        {
                            var a;
                            switch (s){
                            case 'S':
                                return 0;
                            case 'SSW':
                                return 22.5;
                            case 'SW':
                                return 45;
                            case 'WSW':
                                return (45+22.5);
                            case 'W':
                                return 90;
                            case 'WNW':
                                return (90+22.5);
                            case 'NW':
                                return (90+45);
                            case 'NNW':
                                return (180-22.5);
                            case 'N':
                                return 180;
                            case 'NNE':
                                return (180+22.5);
                            case 'NE':
                                return (180+45);
                            case 'ENE':
                                return (270-22.5);
                            case 'E':
                                return 270;
                            case 'ESE':
                                return (270+22.5);
                            case 'SE':
                                return (270+45);
                            case 'SSE':
                                return (360-22.5);

                            }
                        }

                        horizontalAlignment: HorizontalAlignment.Left
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        Container{
                            layout: AbsoluteLayout {
                            }
                            ImageView {
                                imageSource: "asset:///share/images/wind_direction_background.png"
                                preferredWidth: 30*1.6
                                preferredHeight: 30*1.6
                            }
                            ImageView {
                                imageSource: "asset:///share/images//wind_direction_arrow.png"
                                preferredWidth: 30*1.6
                                preferredHeight: 30*1.6
                                rotationZ: wind_direction.getAngle(Current.getdata(0, "wind_direction"))
                            }
                        }
                        Label {
                            text: Config.tr(Current.getdata(0, "wind_direction"));
                            textStyle {
                                base: SystemDefaults.TextStyles.BodyText
                                color: Color.White
                            }
                        }
                        }        
                    }
                    Container{
                        id: pressure_and_wind_speed
                        preferredWidth: 768
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        layoutProperties: AbsoluteLayoutProperties {
                            positionY: 390.0
                        }
                        Container{
                            id: pressure
                            horizontalAlignment: HorizontalAlignment.Left
                            preferredWidth: 768/2
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            ImageView {
                                imageSource: "asset:///share/images/pressure.png"
                                preferredWidth: 30*1.6 
                                preferredHeight: 30*1.6
                            }
                            Label {
                                text: Current.getdata(0, "pressure") + ' ' + Config.tr(Config.pressureunit) ;
                                //horizontalAlignment: HorizontalAlignment.Left
                                textStyle {
                                    base: SystemDefaults.TextStyles.BodyText
                                    color: Color.White
                                }
                            }
                        }
                        Container{
                            id: wind_speed
                            horizontalAlignment: HorizontalAlignment.Left
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            ImageView {
                                imageSource: "asset:///share/images/wind_speed.png"
                                preferredWidth: 30*1.6
                                preferredHeight: 30*1.6
                            }
                            Label {
                                text: Current.getdata(0, "wind_speed") + ' ' + Config.tr(Config.windspeedunit);
                                textStyle {
                                    base: SystemDefaults.TextStyles.BodyText
                                    color: Color.White
                                }
                            }
                        }        
                    }                   
                }
                Container{
                    preferredWidth: 768
                    layout: DockLayout {}
                    layoutProperties: AbsoluteLayoutProperties {
                        positionX: 0
                        positionY: 0
                    }
                    background: Color.Black
                    ImageButton {                 
                       id: left_arrow
                       visible: Config.prevstationname == "" ? false : true;
                       horizontalAlignment: HorizontalAlignment.Left
                       verticalAlignment: VerticalAlignment.Center
                       preferredWidth: 62*1.6
                       preferredHeight: 62*1.6
                       defaultImageSource: "asset:///share/images/arrow_left.png"
                       onClicked: {
                            Config.prevstation();
                            main.updatestationname();
                       }
                }
                Container{
                    layout: DockLayout {}
                    preferredWidth: 600 
                    horizontalAlignment: HorizontalAlignment.Center 
                    Label {                 
                        id: stationname
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle {
                            base: SystemDefaults.TextStyles.BigText
                            color: Color.White
                        }
                        onCreationCompleted: {
                            text = Config.stationname == "Unknown" ? "MeeCast" : Config.stationname 
                        }
                    }
                }
                ImageButton {                 
                   id: right_arrow
                   visible: Config.nextstationname == "" ? false : true;
                   verticalAlignment: VerticalAlignment.Center
                   horizontalAlignment: HorizontalAlignment.Right
                   defaultImageSource: "asset:///share/images/arrow_right.png"
                   preferredWidth: 62*1.6
                   preferredHeight: 62*1.6
                   onClicked: {
                            Config.nextstation();
                            main.updatestationname();
                   }
                }
            }
            ImageView {
                id: main_icon
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 768/2 - 64 *1.6
                    positionY: 80
                }
                preferredWidth: 128*1.6
                preferredHeight: 128*1.6
                imageSource: Config.iconspath + "/" + Config.iconset + "/" + Current.getdata(0, "pict")
                horizontalAlignment: HorizontalAlignment.Center
                overlapTouchPolicy: OverlapTouchPolicy.Allow
                touchPropagationMode: TouchPropagationMode.PassThrough
            } 
            Container{
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0
                    positionY: 560
                }
                preferredWidth: 768
                preferredHeight: 600
                ListView {
                    id: forrecasts_list
                    dataModel: GroupDataModel {
                        id: groupDataModel
                        sortingKeys: ["number"]
                        grouping: ItemGrouping.None
                    }
                    listItemComponents: [
                        ListItemComponent {
                            type: "item"
                            Container{
                                layout: DockLayout {
                                }
                                background: Color.create(ListItemData.bg_color)
                                preferredWidth: 768
                                Container{
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight
                                    }
                                    preferredWidth: 768/2
                                    verticalAlignment: VerticalAlignment.Center
                                    horizontalAlignment: HorizontalAlignment.Left
                                    Container{
                                        preferredWidth: 20
                                        maxWidth: 20
                                    }
                                    Label {
                                        verticalAlignment: VerticalAlignment.Center
                                        text: ListItemData.fulldate
                                        preferredWidth: 768/4.5
                                        textStyle {    
                                            base: SystemDefaults.TextStyles.BodyText
                                            color: Color.Gray
                                        }
                                    }
                                    Label {
                                        text: ListItemData.shortdate
                                        textStyle.textAlign: TextAlign.Right
                                        textStyle {
                                            base: SystemDefaults.TextStyles.BodyText
                                            color: Color.White
                                        }
                                    }
                                }
                                ImageView {
                                     imageSource: ListItemData.pict
                                     horizontalAlignment: HorizontalAlignment.Center                
                                }
                                Container{
                                    layout: StackLayout {
                                        orientation: LayoutOrientation.LeftToRight
                                    }
                                    
                                    horizontalAlignment: HorizontalAlignment.Right
                                    verticalAlignment: VerticalAlignment.Center
                                    Label {
                                        text: ListItemData.temp_high + '°'
                                        horizontalAlignment: HorizontalAlignment.Right
                                        preferredWidth: 100
                                        textStyle.textAlign: TextAlign.Right
                                        textStyle {
                                            base: SystemDefaults.TextStyles.BodyText
                                            color: Color.create(ListItemData.hi_temp_color)
                                        }
                                    }
                                    Label {
                                        text: ListItemData.temp_low + '°'
                                        horizontalAlignment: HorizontalAlignment.Right
                                        preferredWidth: 100
                                        textStyle.textAlign: TextAlign.Right
                                        textStyle {
                                            base: SystemDefaults.TextStyles.BodyText
                                            color: Color.create("#889397")
                                        }
                                    }
                                    Container{
                                        preferredWidth: 20
                                        maxWidth: 20
                                    }
                                }                                                                                                   
                            } 
                        }
                    ]
                	onTriggered: {             
                        console.log("Index ", groupDataModel.data(indexPath).number);
                        main.day = groupDataModel.data(indexPath).number;
                        main.day_period = "day";
                        main.current = false;
                        var newPage = fullpageDefinition.createObject();
                        rootWindow.push(newPage);
				    }

                    onCreationCompleted: {
                        main.update_list();
                    }
                }
            }
            Container{
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0 
                    positionY: 1140
                }
                preferredHeight: 2
                preferredWidth: 768
                background: Color.Gray    
            }
            Button {
                horizontalAlignment: HorizontalAlignment.Center
                preferredWidth: 768 
                visible : Config.stationname == "Unknown" ? true : false;
                text: Config.tr("Set locations")
                onClicked: {
                    var newPage = sourcepageDefinition.createObject();
                    rootWindow.push(newPage);
                }
                layoutProperties: AbsoluteLayoutProperties {
                    positionY: 800 
                }
            }

            Container{
                layoutProperties: AbsoluteLayoutProperties {
                    positionX: 0 
                    positionY: 1142
                }
                preferredWidth: 768 
                preferredHeight: 138 
                background: Color.create("#1f1f1f")
                Container{    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    Container{
                        preferredWidth: 20
                    }
                    ImageButton {
                        id: refreshicon
                        verticalAlignment: VerticalAlignment.Center
                        defaultImageSource: "asset:///button_icons/icon_refresh.png"
                        onClicked: {
                            Config.updatestations()
                        }
                    }
                    ImageView {
                        id: sourceicon
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: Config.stationname == "Unknown" ? "" : Config.imagespath + "/" + Config.source + ".png"                 
                        preferredWidth: 140*1.6
                        preferredHeight: 31*1.6
                        leftMargin: 220.0
                        onTouch: {
                            if (event.isDown()) {
                                Config.showweb();
                            }
                        }

                    }
                    
                    ImageButton {
                        id: settingsicon
                        verticalAlignment: VerticalAlignment.Center     
                        defaultImageSource: "asset:///button_icons/icon_settings.png"
                        leftMargin: 220.0
                        horizontalAlignment: HorizontalAlignment.Right
                        onClicked: {
                            var newPage = settingspageDefinition.createObject();
                            rootWindow.push(newPage);
                        }
                    }
                    Container{
                        preferredWidth: 20
                        preferredHeight: 138 
                    }
                }
            }
        }
         
        attachedObjects: [
            ComponentDefinition {
                id: settingspageDefinition
                source: "SettingsPage.qml"
            },
            ComponentDefinition {
                id: sourcepageDefinition
                source: "SourcePage.qml"
            },
            ComponentDefinition {
                id: fullpageDefinition
                source: "FullWeatherPage.qml"
            },
            ComponentDefinition {
                id: sboutpageDefinition
                source: "AboutPage.qml"
            }
        ]

    } // end of Page
}