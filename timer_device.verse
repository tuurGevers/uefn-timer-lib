
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

TimerTag:=class(tag){}
# A Verse-authored creative device that can be placed in a level
timer_deviceD := class(creative_device):

    @editable TimerProp:creative_prop=creative_prop{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        var TimeManagerInstance:TimeManager = TimeManager{TimerProp:=TimerProp}
        spawn. TimeManagerInstance.SetDateLoop()

        loop:
            Sleep(10.0) # Check every 10 seconds for demonstration purposes
            NextWeekDate := TimeManagerInstance.GetNextWeek()
            Print("\n Next Week - DD-MM-YYYY \n {NextWeekDate.Day}/{NextWeekDate.Month}/{NextWeekDate.Year} \n {NextWeekDate.Hour}:{NextWeekDate.Minute}:{NextWeekDate.Second}")
