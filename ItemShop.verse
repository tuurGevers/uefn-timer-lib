using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }

ItemShop:=class:
    var CurrentDailyItems: []string = array{}
    var CurrentWeeklyItems: []string = array{}
    var StartDate: Date = Date{Year:=2024, Month:=5, Day:=20, Hour:=0, Minute:=0, Second:=0, DayOfWeek:=1}

   
    RandomItems: []string = array{
        "Pickaxe", "Glider", "Skin", "Emote", "Backbling", "Wrap", "Music", 
        "LoadingScreen", "Spray", "Contrail", "Emoji", "Pet", "Toy", 
        "HarvestingTool", "Glider", "Outfit", "Backpack", "Wrap", 
        "Music", "LoadingScreen", "Spray", "Contrail", "Emoji", "Pet", "Toy"
    }
    var PlayerUi: [agent]ItemShopUI = map{}
    var timeManager: TimeManager

    FetchUI(Player:agent)<transacts>:?ItemShopUI=
        if (ui := PlayerUi[player[Player]]):
            return option{ui}
        else:
            if(set PlayerUi[player[Player]] = ItemShopUI{Player:=Player}):
                if (ui := PlayerUi[player[Player]]):
                    return option{ui}
        return false

    InitUI(Player:agent):void=
        if(UI:=FetchUI(Player)?):
            UI.Init()
            ShowUI(Player)

    UpdatePlayerUIs():void=
        for (Key->Value:PlayerUi):
            Value.UpdateUI(CurrentDailyItems, CurrentWeeklyItems)

    Init(_timeManager: TimeManager): void =
        set timeManager = _timeManager
        
        Self.UpdateDailyItems()
        Self.UpdateWeeklyItems(true)
        spawn. Self.StartCountdownLoop()

    UpdateDailyItems(): void =
        var dailySeed: int = timeManager.CurrentDate.GenerateDailySeed()
        set CurrentDailyItems = FetchDailyItems(dailySeed)
        UpdatePlayerUIs()

    UpdateWeeklyItems(initial:logic): void =
        if (timeManager.CurrentDate.IsMoreThanAWeekSince(StartDate)=true or initial=true):
            var weeklySeed: int = timeManager.CurrentDate.GenerateWeeklySeed()
            set CurrentWeeklyItems = FetchWeeklyItems(weeklySeed)
            UpdatePlayerUIs()

    FetchDailyItems(seed: int): []string =
        var dailyItems: []string = RandomItems
        var rng: SimpleRNG = SimpleRNG{}
        rng.Init(seed)

        var selectedItems: []string = array{}
        for (i:=0..3):
            if(set selectedItems += array{dailyItems[rng.SeededIntRange(0, dailyItems.Length - 1)]}){}
        return selectedItems

    FetchWeeklyItems(seed: int): []string =
        var weeklyItems: []string = RandomItems
        var rng: SimpleRNG = SimpleRNG{}
        rng.Init(seed)

        var selectedItems: []string = array{}
        for (i:=0..3):
            if(set selectedItems += array{weeklyItems[rng.SeededIntRange(0, weeklyItems.Length - 1)]}){}
        return selectedItems

    StartCountdownLoop()<suspends>: void =
        loop:
            Self.UpdateCountdownTimers()
            Sleep(1.0)

    UpdateCountdownTimers(): void =
        var now: Date = timeManager.CurrentDate
        
        # Calculate daily time remaining
        var daysSinceStart: int = now.Day - StartDate.Day
        Print("now dat {now.Day} start date {StartDate.Day} days since start {daysSinceStart}")
        if(NextDay:=Mod[now.DayOfWeek , 7] + 1, PrevDay:=Mod[daysSinceStart , 7]):
            var nextDay: Date = Date{Year := now.Year, Month := now.Month, Day := now.Day, Hour := 0, Minute := 0, Second := 0, DayOfWeek := NextDay}
            if (now.Hour >= StartDate.Hour):
                set nextDay.Day += 1
            var dailyTimeRemaining: tuple(int, int, int, int) = now.TimeUntil(nextDay)

            # Calculate weekly time remaining
            Print("prevDay: {PrevDay}")
            var daysToAdd: int = 7 - PrevDay
            if (daysToAdd = 0):
                set daysToAdd = 7
            var nextWeek: Date = Date{Year := now.Year, Month := now.Month, Day := now.Day + daysToAdd, Hour := 0, Minute := 0, Second := 0, DayOfWeek := StartDate.DayOfWeek}
            var weeklyTimeRemaining: tuple(int, int, int, int) = now.TimeUntil(nextWeek)

            # Update the UI with the remaining time
            for (Key -> Value: PlayerUi):
                Value.UpdateCountdown(dailyTimeRemaining, weeklyTimeRemaining)


    ShowUI(Player: agent): void =
        if (ui := FetchUI(Player)?):
            ui.ShowUI()

    RemoveUI(Player: agent): void =
        if(ui := FetchUI(Player)?):
            ui.RemoveUI()

ItemShopUI := class:
    var DailyItemsSlots: []InvSlot = array{}
    var WeeklyItemsSlots: []InvSlot = array{}
    var Canvas: canvas = canvas{}
    var DailyCountdownText: text_block = text_block{DefaultTextColor := color{R := 255.0, G := 255.0, B := 255.0}}
    var WeeklyCountdownText: text_block = text_block{DefaultTextColor := color{R := 255.0, G := 255.0, B := 255.0}}
    Player:agent
    
    Init(): void =
        Self.CreateUI()
    
    CreateUI(): void =
        Button:= button_regular{
            DefaultText := SetText("Close")
            }

        Button.OnClick().Subscribe(CloseUI)
        set Canvas =
            canvas: 
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                        Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X := 0.5, Y := 0.5}
                        Widget :=  
                             overlay: 
                                Slots := array: 
                                    overlay_slot:
                                        Widget := texture_block{
                                            DefaultImage := InvBackground_UI,
                                            DefaultDesiredSize := vector2{X := 1920.0, Y := 1080.0}}
                                    overlay_slot:
                                        Widget := stack_box:
                                            Orientation := orientation.Vertical
                                            Slots := array:
                                                stack_box_slot:
                                                    Widget := text_block{
                                                        DefaultText := SetText("Daily Items"),
                                                        DefaultTextColor := color{R := 255.0, G := 255.0, B := 255.0}}
                                                stack_box_slot:
                                                    Widget := Self.CreateDailyItemsUI()
                                                stack_box_slot:
                                                    Widget := DailyCountdownText
                                                stack_box_slot:
                                                    Widget := text_block{
                                                        DefaultText := SetText("Weekly Items"),
                                                        DefaultTextColor := color{R := 255.0, G := 255.0, B := 255.0}}
                                                stack_box_slot:
                                                    Widget := Self.CreateWeeklyItemsUI()
                                                stack_box_slot:
                                                    Widget := WeeklyCountdownText
                                                stack_box_slot:
                                                    Widget :=Button

    CreateDailyItemsUI(): stack_box =
        var Slots: []stack_box_slot = array{}
        for (i:=0..2):
            var slot: InvSlot = InvSlot{}
            set Slots += array{stack_box_slot{Widget:=slot.InitOverlay()}}
            set DailyItemsSlots += array{slot}
        return stack_box{Orientation:= orientation.Horizontal, Slots:= Slots}

    CreateWeeklyItemsUI(): stack_box =
        var Slots: []stack_box_slot = array{}
        for (i:=0..2):
            var slot: InvSlot = InvSlot{}
            set Slots += array{stack_box_slot{Widget:=slot.InitOverlay()}}
            set WeeklyItemsSlots += array{slot}
        return stack_box{Orientation:= orientation.Horizontal, Slots:= Slots}

    UpdateCountdown(dailyTimeRemaining: tuple(int, int, int, int), weeklyTimeRemaining: tuple(int, int, int, int)): void =
        DailyCountdownText.SetText(SetText("Daily Reset: {dailyTimeRemaining(0)}d {dailyTimeRemaining(1)}h {dailyTimeRemaining(2)}m {dailyTimeRemaining(3)}s"))
        WeeklyCountdownText.SetText(SetText("Weekly Reset: {weeklyTimeRemaining(0)}d {weeklyTimeRemaining(1)}h {weeklyTimeRemaining(2)}m {weeklyTimeRemaining(3)}s"))
    
    UpdateUI(dailyItems: []string, weeklyItems: []string): void =
        for (i:=0..dailyItems.Length-1):
            if (slot := DailyItemsSlots[i]):
                if(Item:=dailyItems[i]):
                    slot.ItemSlot.SetImage(GetItemImage(Item))
                    slot.ItemText.SetText(SetText(Item))

        for (i:=0..weeklyItems.Length-1):
            if (slot := WeeklyItemsSlots[i]):
                if(Item:=weeklyItems[i]):
                    slot.ItemSlot.SetImage(GetItemImage(Item))
                    slot.ItemText.SetText(SetText(Item))

    ShowUI(): void =
        if (PlayerUI := GetPlayerUI[player[Player]]):
            PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode:= ui_input_mode.All})

    RemoveUI(): void =
        if (PlayerUI := GetPlayerUI[player[Player]]):
            PlayerUI.RemoveWidget(Canvas)

    CloseUI(m:widget_message): void =
        RemoveUI()

GetItemImage(itemName: string): texture =
    # Implement a method to return the correct texture based on the item name
    return CoinsIcon

InvSlot := class:
    var EmptySlot: texture_block = texture_block{
        DefaultImage := empty,
        DefaultDesiredSize := vector2{X := 128.0, Y := 128.0} }
    var ItemSlot: texture_block = texture_block{
        DefaultImage := empty,
        DefaultDesiredSize := vector2{X := 64.0, Y := 64.0} }  
    var ItemText: text_block = text_block{DefaultTextColor := color{R := 255.0, G := 255.0, B := 255.0}}

    InitStackBox(): overlay =
        ItemText.SetText(SetText("0"))
        return overlay:
            Slots := array:
                overlay_slot:
                    Widget := EmptySlot
                overlay_slot:
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                Widget := ItemSlot
                            stack_box_slot:
                                Widget := ItemText

    InitOverlay(): overlay =
        return overlay:
            Slots := array:
                overlay_slot:
                    Widget := EmptySlot
                overlay_slot:
                    Widget := ItemSlot
                overlay_slot:
                    Widget := ItemText

    Clear(): void =
        ItemSlot.SetImage(empty)
        ItemText.SetText(SetText(""))