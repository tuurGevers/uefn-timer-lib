using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Fortnite.com/AI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }

QuestGoal := class():
    var Description: string
    var TargetCount: int
    var CurrentCount: int = 0
    var IsComplete: logic = false
    var Q:?Quest =false

    Init(_Description: string, _TargetCount: int): void =
        set Self.Description = _Description
        set Self.TargetCount = _TargetCount
       

    IncrementProgress(?Increment: int = 1): void =
        if(Self.IsComplete = false):
            set Self.CurrentCount += Increment
            if (Self.CurrentCount >= Self.TargetCount):
                Self.Complete()
            if(MainQuest:=Q?):
                MainQuest.UpdateUI()

    SetProgress(NewValue: int): void =
        if ( Self.IsComplete = false ):
            set Self.CurrentCount = NewValue
            if (Self.CurrentCount >= Self.TargetCount):
                Self.Complete()
        if(MainQuest:=Q?):
            MainQuest.UpdateUI()

    Complete(): void =
        set Self.IsComplete = true

Quest := class():
    var Goals: []QuestGoal
    Player: agent
    var QuestComplete: logic = false
    var Canvas:canvas = canvas{}
    var GoalSlotsDesc : []text_block = array{}
    var GoalSlotsGOal : []text_block = array{}
    var IsAsigned:logic=false
    var TargetDate: Date
    var RemainingTimeText: text_block = text_block{DefaultTextColor := color{R:=255.0, G:=255.0, B:=255.0}}
    timeManager:TimeManager
    # var GoalTextureSlots : []texture_block = array{}

    AwaitCompletion(Callback():void)<suspends>:void=
        if(IsAsigned = false):
            set IsAsigned = true
                    loop:
                        Sleep(1.0)
                        Self.UpdateRemainingTime()
                        if(CheckCompletion[]):
                            Self.CompletionEvent(Callback)
                            return

    UpdateRemainingTime(): void =
        var now: Date = timeManager.CurrentDate # Assume GetCurrentDate gets the current date/time
        Time := now.TimeUntil(TargetDate)
        days:= Time(0)
        hours:= Time(1)
        minutes:= Time(2)
        seconds:= Time(3)
        
        RemainingTimeText.SetText(SetText("Time Remaining:\n {days}d {hours}h {minutes}m {seconds}s"))
        Self.UpdateUI()

    
    CheckCompletion()<decides><transacts>: void =
        var ShouldComplete:logic =true
        for(goal : Self.Goals):
            if(goal.IsComplete = false):
                set ShouldComplete = false
        ShouldComplete = true

    AddGoal(Goal: QuestGoal): void =
        set Self.Goals += array{Goal}
        set Goal.Q = option{Self}

    StartAndAwait(Callback():void)<suspends>: void =
        for(goal:Goals):
            set goal.Q = option{Self}
        SHowUiToPlayer()
        AwaitCompletion(Callback)

    CompletionEvent(Callback():void):void=
        Callback()
        RemoveUIFromPlayer()

    CreateGoalSlots():stack_box=
        set GoalSlotsDesc = array{}
        set GoalSlotsGOal = array{}

        var Slots:[]stack_box_slot = array{}
     
        for(goal:Self.Goals):
            if(goal.IsComplete = false):
                TextWidget:= text_block{DefaultTextColor := color{R:=255.0, G:=255.0, B:=255.0}}
                TextWidgetGoal:= text_block{DefaultTextColor := color{R:=255.0, G:=255.0, B:=255.0}}
                TextWidget.SetText(SetText("{goal.Description}"))
                TextWidgetGoal.SetText(SetText("{goal.CurrentCount}/{goal.TargetCount}"))
                set GoalSlotsDesc += array{TextWidget}
                set GoalSlotsGOal += array{TextWidgetGoal}

                set Slots+=array{
                    stack_box_slot:
                        Widget:=RemainingTimeText
                    }
                set Slots += array{
                    stack_box_slot:
                        Widget:=stack_box:
                            Orientation:=orientation.Horizontal
                            Slots:=array:
                                stack_box_slot:
                                    Widget:=  Widget:=TextWidget
                                stack_box_slot:
                                    Padding:=margin{Left:=20.0}
                                    Widget:=  Widget:=TextWidgetGoal
                }

        return stack_box:
            Orientation:=orientation.Vertical
            Slots:=array:
                stack_box_slot:
                    Widget:=overlay:
                        Slots:=array:
                            overlay_slot:
                                Widget:= texture_block{DefaultImage:= bg2, DefaultDesiredSize:=vector2{X:=512.0, Y:=384.0}}
                            overlay_slot:
                                Widget:=stack_box:
                                    Orientation:=orientation.Vertical
                                    Slots:=Slots

    CreateCanvas():void=
        set Canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.7, Y := 0.5}, Maximum := vector2{X := 1.0, Y := 0.5}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    Widget:=CreateGoalSlots()
        

    SHowUiToPlayer():void=
        CreateCanvas()
        if(PlayerUI:= GetPlayerUI[player[Player]]):
            PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode:= ui_input_mode.None})
              
    UpdateUI():void=
        for(I-> Slot:GoalSlotsDesc):
            if(Goal:= Self.Goals[I], Target:=GoalSlotsGOal[I],  Goal.IsComplete = false):
                Slot.SetText(SetText("{Goal.Description}"))
                Target.SetText(SetText("{Goal.CurrentCount}/{Goal.TargetCount}"))
            else:
                Slot.SetText(SetText(""))
                Slot.SetVisibility(widget_visibility.Collapsed)
                if(Goal:= GoalSlotsGOal[I]):
                    Goal.SetVisibility(widget_visibility.Collapsed)

    RemoveUIFromPlayer():void=
        if(PlayerUI:= GetPlayerUI[player[Player]]):
            PlayerUI.RemoveWidget(Canvas)


    
        