using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

TimerTag := class(tag) {}
# A Verse-authored creative device that can be placed in a level
timer_deviceD := class(creative_device):

    @editable TimerProp:creative_prop = creative_prop {}
    var FirstQuest:?Quest = false
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        var TimeManagerInstance:TimeManager = TimeManager{TimerProp:=TimerProp}
        spawn. TimeManagerInstance.SetDateLoop()
        Sleep(2.0)
        # InitQuest(TimeManagerInstance)
        # spawn. StartDateLoop(TimeManagerInstance)
        TestItemShop(TimeManagerInstance)

        
    CompleteQuest():void=
        Print("Quest Completed")
        
    InitQuest(TimeManagerInstance:TimeManager)<suspends>:void=
        if(Player:=GetPlayspace().GetPlayers()[0]):
            TestQuest := QuestGoal{Description:="This is a test", TargetCount:=1}
            TestQuest2 := QuestGoal{Description:="do a dance", TargetCount:=1}
            # Create the quest with both goals
            Sleep(2.0)
            TimeManagerInstance.CurrentDate.PrintCurrentDateTime()
            TargetDate:= TimeManagerInstance.CurrentDate.AddTime("", ?Days:=1)
            TargetDate.PrintCurrentDateTime()

            MyQuest := Quest{Player:=Player, Goals:=array{TestQuest, TestQuest2},TargetDate:=TargetDate, timeManager:=TimeManagerInstance }
            set FirstQuest = option{MyQuest}
            spawn. MyQuest.StartAndAwait(CompleteQuest)

    StartDateLoop(TimeManagerInstance:TimeManager)<suspends>:void=
        loop:
            Sleep(2.0) # Check every 10 seconds for demonstration purposes
            Print("Current Date:")
            TimeManagerInstance.CurrentDate.PrintCurrentDateTime()

        #     NextWeekDate := TimeManagerInstance.CurrentDate.GetNextWeek()
        #     Print("Next Week Date:")
        #     NextWeekDate.PrintCurrentDateTime()

        #     AddedTimeDate1 := TimeManagerInstance.CurrentDate.AddTime("", ?Days:=1)
        #     Print("Date After Adding 1 Day:")
        #     AddedTimeDate1.PrintCurrentDateTime()

        #     AddedTimeDate2 := TimeManagerInstance.CurrentDate.AddTime("", ?Months:=1)
        #     Print("Date After Adding 1 Month:")
        #     AddedTimeDate2.PrintCurrentDateTime()

        #     AddedTimeDate3 := TimeManagerInstance.CurrentDate.AddTime("", ?Years:=1)
        #     Print("Date After Adding 1 Year:")
        #     AddedTimeDate3.PrintCurrentDateTime()

        #     AddedTimeDate4 := TimeManagerInstance.CurrentDate.AddTime("", ?Hours:=5)
        #     Print("Date After Adding 5 Hours:")
        #     AddedTimeDate4.PrintCurrentDateTime()

        #     AddedTimeDate5 := TimeManagerInstance.CurrentDate.AddTime("", ?Minutes:=30)
        #     Print("Date After Adding 30 Minutes:")
        #     AddedTimeDate5.PrintCurrentDateTime()

        #     AddedTimeDate6 := TimeManagerInstance.CurrentDate.AddTime("", ?Seconds:=45)
        #     Print("Date After Adding 45 Seconds:")
        #     AddedTimeDate6.PrintCurrentDateTime()

    TestItemShop(TimeManagerInstance:TimeManager):void=
        var itemShop: ItemShop = ItemShop{timeManager:=TimeManagerInstance}
        itemShop.Init(TimeManagerInstance)

        for(Player:GetPlayspace().GetPlayers()):
            itemShop.InitUI(Player)
        spawn. UiUpdateLoop(itemShop)

        # Assume currentDate is an instance of Date with the current date and time
        var currentDate: Date = TimeManagerInstance.CurrentDate

        var dailySeed: int = currentDate.GenerateDailySeed()
        var weeklySeed: int = currentDate.GenerateWeeklySeed()

        var dailyItems: []string = itemShop.FetchDailyItems(dailySeed)
        var weeklyItems: []string = itemShop.FetchWeeklyItems(weeklySeed)

        # Print the fetched items for demonstration
        
        Print("Daily Items: {dailyItems.Join(", ")}")
        Print("Weekly Items: {weeklyItems.Join(", ")}")

    UiUpdateLoop(itemShop:ItemShop)<suspends>:void=
        loop:
            Sleep(5.0)
            itemShop.UpdateDailyItems()
            itemShop.UpdateWeeklyItems(false)
            